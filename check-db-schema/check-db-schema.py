#!/usr/bin/env python3
# Copyright 2026 The Wazo Authors  (see the AUTHORS file)
# SPDX-License-Identifier: GPL-3.0-or-later
"""Compare a service's SQLAlchemy models against its own alembic migrations.

The tool builds the schema in two ways:
- from the models, with `Base.metadata.create_all()`
- from the migrations, with `alembic upgrade head`

Then it compares the two schemas. If they differ, the tool prints the
difference and exits with an error.

For the full setup steps, read check-db-schema/README.md.

Usage:
    python check-db-schema.py <server-uri>
    python check-db-schema.py --project-root <path> --config <path> <server-uri>

Example:
    python check-db-schema.py postgresql://postgres:postgres@localhost:5432
"""

from __future__ import annotations

import argparse
import importlib
import logging
import logging.config
import os
import sys
from configparser import ConfigParser

import sqlalchemy as sa
from alembic import command as alembic_command  # type: ignore[attr-defined]
from alembic.config import Config as AlembicConfig
from migra import Migration

LOGGER_NAME = 'check_db_schema'
LOGGING_CONFIG = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {'default': {'format': '%(levelname)-5.5s [%(name)s] %(message)s'}},
    'handlers': {'console': {'class': 'logging.StreamHandler', 'formatter': 'default'}},
    'loggers': {
        LOGGER_NAME: {'level': 'INFO', 'handlers': ['console'], 'propagate': False}
    },
}
log = logging.getLogger(LOGGER_NAME).info


def configure_logging() -> None:
    # A service's alembic/env.py calls fileConfig(alembic.ini) on every
    # alembic command run here, which disables this logger since that ini
    # does not list it; call this again after each alembic command to
    # restore it.
    logging.config.dictConfig(LOGGING_CONFIG)


def main() -> int:
    configure_logging()

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        'server_uri',
        help=(
            'URI of a Postgres server with no database name, '
            'e.g. postgresql://postgres:postgres@localhost:5432'
        ),
    )
    parser.add_argument(
        '--project-root',
        default=os.getcwd(),
        help='Root of the service repository being checked (default: cwd)',
    )
    parser.add_argument(
        '--config',
        default='check-db-schema.ini',
        help='Path to the service config file, relative to --project-root',
    )
    args = parser.parse_args()

    project_root = os.path.abspath(args.project_root)
    config = ConfigParser()
    config_path = os.path.join(project_root, args.config)
    if not config.read(config_path):
        parser.error(f'no such config file: {config_path}')
    section = config['check-db-schema']

    models_module_name, _, models_attr = section['models'].partition(':')
    base = getattr(importlib.import_module(models_module_name), models_attr)

    alembic_ini = os.path.join(project_root, section.get('alembic-ini', 'alembic.ini'))
    alembic_dir = os.path.join(project_root, section.get('alembic-dir', 'alembic'))
    extensions = tuple(
        e.strip() for e in section.get('extensions', '').split(',') if e.strip()
    )
    db_prefix = section.get('db-prefix') or models_module_name.split('.')[0]

    installed_uri = f'{args.server_uri}/{db_prefix}_installed'
    migrated_uri = f'{args.server_uri}/{db_prefix}_migrated'

    log('Building the schema from the models...')
    build_installed_database(installed_uri, base, alembic_ini, alembic_dir, extensions)
    log('Building the schema from the migrations...')
    build_migrated_database(migrated_uri, alembic_ini, alembic_dir, extensions)

    log('Comparing the two schemas...')
    differences = compare(installed_uri, migrated_uri)

    if differences:
        log(
            'The models describe a schema that differs from the one the '
            'migrations install. Statements below would migrate the model '
            'schema to match the installed one; update the models '
            'to match instead of applying them:\n' + differences
        )
        return 1

    log('No difference found.')
    return 0


def build_installed_database(
    db_uri: str, base, alembic_ini: str, alembic_dir: str, extensions: tuple[str, ...]
) -> None:
    reset_database(db_uri, extensions)
    engine = sa.create_engine(db_uri)
    try:
        base.metadata.create_all(bind=engine)
    finally:
        engine.dispose()
    # No migration ever runs against this database, but it must be stamped
    # to the same revision as the migrated one so the version table itself
    # does not show up as a difference.
    alembic_command.stamp(
        build_alembic_config(db_uri, alembic_ini, alembic_dir), 'head'
    )
    configure_logging()


def build_migrated_database(
    db_uri: str, alembic_ini: str, alembic_dir: str, extensions: tuple[str, ...]
) -> None:
    reset_database(db_uri, extensions)
    alembic_command.upgrade(
        build_alembic_config(db_uri, alembic_ini, alembic_dir), 'head'
    )
    configure_logging()


def reset_database(db_uri: str, extensions: tuple[str, ...]) -> None:
    server_uri, _, db_name = db_uri.rpartition('/')
    engine = sa.create_engine(f'{server_uri}/postgres', isolation_level='AUTOCOMMIT')
    try:
        with engine.connect() as connection:
            connection.execute(sa.text(f'DROP DATABASE IF EXISTS "{db_name}"'))
            connection.execute(sa.text(f'CREATE DATABASE "{db_name}"'))
    finally:
        engine.dispose()

    if not extensions:
        return

    engine = sa.create_engine(db_uri, isolation_level='AUTOCOMMIT')
    try:
        with engine.connect() as connection:
            for extension in extensions:
                connection.execute(
                    sa.text(f'CREATE EXTENSION IF NOT EXISTS "{extension}"')
                )
    finally:
        engine.dispose()


def build_alembic_config(
    db_uri: str, alembic_ini: str, alembic_dir: str
) -> AlembicConfig:
    # env.py's run_migrations_online() reads this ahead of sqlalchemy.url.
    os.environ['ALEMBIC_DB_URI'] = db_uri
    alembic_cfg = AlembicConfig(alembic_ini)
    alembic_cfg.set_main_option('script_location', alembic_dir)
    alembic_cfg.set_main_option('sqlalchemy.url', db_uri)
    return alembic_cfg


def compare(installed_uri: str, migrated_uri: str) -> str:
    installed_engine = sa.create_engine(installed_uri)
    migrated_engine = sa.create_engine(migrated_uri)
    try:
        with (
            installed_engine.connect() as installed,
            migrated_engine.connect() as migrated,
        ):
            migration = Migration(installed, migrated)
            migration.set_safety(False)
            migration.add_all_changes()
            return migration.sql
    finally:
        installed_engine.dispose()
        migrated_engine.dispose()


if __name__ == '__main__':
    sys.exit(main())
