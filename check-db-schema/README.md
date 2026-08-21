# check-db-schema

This tool checks a service's database schema. It compares the SQLAlchemy
models to the alembic migrations. If the models and the migrations do not
agree, the check fails.

This check finds problems that a plain file diff cannot find, for example:
constraint names, nullable columns, default values, cascade rules, and
sequence ownership.

## When to use this tool

Use this tool only if the service meets both conditions:

- The service defines its schema with SQLAlchemy models. The models use
  `declarative_base()`. The base's `.metadata` attribute is the source of
  truth for `create_all()`.
- The service installs the same schema with alembic migrations. The first
  migration builds the full schema. The migrations do not start from an
  existing, non-empty database.

**Do not use this tool for xivo-manage-db or xivo-dao.** Their models and
migrations live in separate repositories. Their migrations do not start
from an empty database. Use `wazo-tools/compare-db` instead.

## How the tool works

The script `check-db-schema.py` builds two throwaway databases on the same
Postgres server:

- one database from the models, with `Base.metadata.create_all()`
- one database from the migrations, with `alembic upgrade head`

The tool stamps both databases to the same alembic revision. This step
makes sure the version table does not show up as a difference.

Then the tool compares the two databases with `migra`. Any difference
means the models and the migrations do not agree on the schema.

## Add a service

Follow these steps to add a new service to this check.

### Step 1: Add a config file

Add a config file to the service repository. The default path is
`check-db-schema.ini`, at the repository root.

```ini
[check-db-schema]
models = wazo_dird.database:Base
alembic-ini = alembic.ini
alembic-dir = alembic
```

The config fields are:

- `models`: the module path and the attribute name of the SQLAlchemy
  declarative base.
- `alembic-ini` and `alembic-dir`: the paths to the alembic config file and
  the migration scripts. The paths are relative to the service repository
  root. The default values are `alembic.ini` and `alembic`. wazo-dird,
  wazo-chatd, and wazo-webhookd use this default. Some services keep these
  files under a package directory, for example `wazo_call_logd/database/`.
  These services must set both fields.
- `extensions`: a comma-separated list of Postgres extensions. The tool
  creates these extensions before it runs the migrations. This field is
  optional. The default is `uuid-ossp,unaccent,hstore`, the set every Wazo
  service already uses. Set it only if a service needs a different set.

### Step 2: Add a tox environment

Add a tox environment to the service's own `tox.ini`. Zuul checks out
`wazo-tools` next to the service through `required-projects`. For local
use, clone `wazo-tools` next to the service repository.

```ini
[testenv:check-db-schema]
base_python = python3.11
use_develop = true
deps =
    -rrequirements.txt
    -r{toxinidir}/../wazo-tools/check-db-schema/requirements.txt
pass_env =
    CHECK_DB_SCHEMA_SERVER_URI
commands =
    python {toxinidir}/../wazo-tools/check-db-schema/check-db-schema.py \
        {env:CHECK_DB_SCHEMA_SERVER_URI:postgresql://postgres:postgres@localhost:5432}
```

### Step 3: Add the Zuul job

The shared `check-db-schema` job lives in `wazo-production-sf-jobs`,
in order to be inheritable by other wazo-platform projects.

Add the job to the service's `zuul.yaml`.

```yaml
- job:
    name: <service>-check-db-schema
    parent: check-db-schema

- project:
    wazo-check:
      jobs:
        - <service>-check-db-schema
    wazo-gate:
      jobs:
        - <service>-check-db-schema
```

### Step 4 (optional): Guard the alembic logging config

Some services call `fileConfig(config.config_file_name)` in
`alembic/env.py` with no condition. If your service does this, add a
guard. xivo-manage-db, wazo-auth, and wazo-call-logd already use this
guard:

```python
if config.get_main_option('configure_logging', 'true') == 'true':
    fileConfig(config.config_file_name)
```

This step is optional. The tool restores its own logger after each
alembic command, with or without the guard.

## Develop this tool

To test a change to this tool, run it directly against a real service.

Install this tool's dependencies and the target service in one virtualenv:

```sh
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt -e /path/to/wazo-dird
```

Start a throwaway Postgres server:

```sh
docker compose up -d
docker compose port postgres 5432
```

The second command prints a port number. Use this port number as
`<port>` in the next command.

Then run the script directly:

```sh
.venv/bin/python check-db-schema.py \
    --project-root /path/to/wazo-dird \
    postgresql://postgres:check-db-schema@127.0.0.1:<port>
```
