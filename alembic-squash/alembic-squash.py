#!/usr/bin/env python3
"""
script and utilities to automate and support
the squashing of old alembic migrations in wazo projects.
"""
from __future__ import annotations

import argparse
import fileinput
import os
import re
import shutil
import sys
import time
from contextlib import contextmanager
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from traceback import format_exc

import sh
from alembic.config import Config
from alembic.script import ScriptDirectory
from alembic.script.revision import Revision
from setuptools import find_packages
from sh.contrib import git


def print_error(message: str):
    print(f"ERROR: {message}", file=sys.stderr)


def print_message(message: str):
    print(f"MESSAGE: {message}", file=sys.stderr)


def print_warning(message: str):
    print(f"WARNING: {message}", file=sys.stderr)


def get_alembic_config(project_root: Path, alembic_ini_path: Path | None = None):
    if alembic_ini_path is None:
        alembic_ini_path = next(project_root.rglob("alembic.ini"), None)
        assert alembic_ini_path and alembic_ini_path.is_file(), f"{alembic_ini_path} is not a file"

    if not alembic_ini_path.exists():
        raise FileNotFoundError(f"Alembic configuration not found at {alembic_ini_path}")

    alembic_ini_path = alembic_ini_path.resolve()
    print_message(f"✓ Alembic configuration found at {alembic_ini_path}")
    config = Config(str(alembic_ini_path))
    return config


def get_script_directory(config: Config):
    """Get the Alembic script directory."""
    return ScriptDirectory.from_config(config)


@dataclass
class SquashPlan:
    target_tag: str
    squash_revisions: list[Revision]

    @property
    def squash_head(self) -> Revision:
        return self.squash_revisions[0]


def read_squashplan(script_dir: ScriptDirectory) -> SquashPlan:
    with open(".alembic_squash/squashplan", "r") as f:
        lines = f.readlines()
    target_tag = next(
        line.strip().removeprefix("tag:").strip() for line in lines if line.startswith("tag:")
    )
    assert target_tag
    squash_revisions = [
        script_dir.get_revision(line.strip().split(":", 1)[1])
        for line in lines
        if line.startswith("rev:")
    ]
    assert squash_revisions
    squash_head = next(line.strip().split(":", 1)[1] for line in lines if line.startswith("head:"))
    assert squash_head and squash_head == squash_revisions[0].revision
    return SquashPlan(target_tag=target_tag, squash_revisions=squash_revisions)


@dataclass
class Context:
    tool_dir: Path
    script_dir: ScriptDirectory
    squash_dir: Path
    project_root: Path
    project_name: str
    database_name: str
    alembic_config: Config
    db_username: str
    db_password: str
    dockerfile_db: Path

    def update_script_dir(self) -> None:
        self.script_dir = ScriptDirectory.from_config(self.alembic_config)


def find_revisions_to_squash(
    target_tag: str, script_dir: ScriptDirectory
) -> list[tuple[Revision, tuple[str, str, str]]]:
    squash_list = []

    revisions = script_dir.walk_revisions()
    for rev in revisions:
        original_commit: str = git.log(
            "--pretty=format:%H - %s", "--diff-filter=A", target_tag, "--", rev.path
        ).strip()
        assert "\n" not in original_commit
        if not original_commit:
            # no commit responsible for this revision reachable from target_tag, skip it
            continue

        commit_id, commit_message = original_commit.split(" - ", 1)
        release_tag = git.describe("--contains", commit_id).strip()
        assert "\n" not in release_tag
        squash_list.append((rev, (commit_id, commit_message, release_tag)))

    if not squash_list:
        print_error(
            f"No revisions to squash found for target tag {target_tag} "
            "from current git checkout, aborting"
        )
        sys.exit(1)

    revset = set(rev.revision for rev, _ in squash_list)

    # check that all down revisions from the squash head are marked for squashing
    for rev in script_dir.walk_revisions(head=squash_list[0][0].revision):
        assert rev.revision in revset, f"revision {rev.revision} ({rev.path}) not in squash_list"

    return squash_list


def prepare_squashplan(context: Context, target_tag: str) -> None:
    git.show("--oneline", target_tag, _out=sys.stderr)
    with open(context.squash_dir / "squashplan", "w") as f:
        f.write(f"tag:{target_tag}\n")

    squash_list = find_revisions_to_squash(target_tag, context.script_dir)
    with open(context.squash_dir / "squashplan", "a") as f:
        for rev, (commit_id, commit_message, release_tag) in squash_list:
            print_message(f"revision {rev.revision} ({rev.path}) marked for squashing")
            print_message(rev)
            print_message(f"\toriginal_commit: {commit_id} {commit_message} {release_tag}")
            f.write(f"rev:{rev.revision}\n")

    squash_head = squash_list[0][0]
    print_message(f"squash head revision: {squash_head}")
    with open(context.squash_dir / "squashplan", "a") as f:
        f.write(f"head:{squash_head.revision}\n")

    print_message(f"✓ Squash plan written to {context.squash_dir / 'squashplan'}")


def ask_confirm() -> bool:
    try:
        confirm = input("ok? (Y/n)")
    except KeyboardInterrupt:
        print_message("Aborted")
        sys.exit(1)
    if confirm and confirm.lower() != "y":
        print_message("Aborted")
        sys.exit(1)
    return True


def squash(context: Context) -> None:
    squashplan = read_squashplan(context.script_dir)

    release_version = squashplan.target_tag.replace("wazo-", "").replace(".", "")
    baseline_dump_path = Path(context.squash_dir) / f"baseline-{release_version}.sql"
    if not baseline_dump_path.exists():
        print_error(
            f"Baseline SQL dump not found at {baseline_dump_path}, "
            "ensure previous steps are run first"
        )
        sys.exit(1)

    alembic_versions_dir = Path(context.script_dir.dir) / "versions"

    print_message(f"✓ Baseline SQL dump found at {baseline_dump_path.absolute()}")
    squashlist = "\n    ".join(str(rev) for rev in squashplan.squash_revisions)
    print_message(
        f"""
    The following squashplan will be followed:
    - baseline target tag is {squashplan.target_tag}
    - baseline sql dump {baseline_dump_path} will be moved to {alembic_versions_dir}
    - revisions introduced prior to target tag will be squashed:
    {squashlist}
    - revision {squashplan.squash_head.revision} will become the new base revision
    - new base revision {squashplan.squash_head.revision} will use sql dump file
      {alembic_versions_dir / baseline_dump_path.name}
    - squashed revisions files will be removed
    """
    )
    # given a chance to read the plan and approve
    assert ask_confirm()

    # copy the baseline sql dump to the alembic versions directory
    new_baseline_dump_path = shutil.copyfile(
        baseline_dump_path, alembic_versions_dir / baseline_dump_path.name
    )

    print_message(f"✓ Baseline SQL dump moved to {new_baseline_dump_path.absolute()}")

    new_script = context.script_dir.generate_revision(
        revid=squashplan.squash_head.revision,
        message=f"squashed baseline {squashplan.target_tag}",
        head="base",
        depends_on=None,
        splice=True,
        # script.py.mako template args
        # mind the formatting of the string, necessary for proper indentation
        imports="import os",
        upgrades=f"""# Read and execute the SQL dump file
    versions_dir_path = os.path.dirname(__file__)
    sql_file_path = os.path.join(versions_dir_path, '{new_baseline_dump_path.name}')

    with open(sql_file_path) as f:
        sql_content = f.read()

    # Execute the SQL content
    op.execute(sql_content)""",
    )
    # remove unused import, avoid tripping linters
    sh.sed("-i", "/import sqlalchemy as sa/d", new_script.path, _err=sys.stderr)
    print_message(f"✓ New revision generated: {new_script}")
    assert new_script.is_base

    git.rm("--", *(rev.path for rev in squashplan.squash_revisions))

    # alembic ScriptDirectory state is out-of-date, need to recreate
    context.update_script_dir()

    base_revision = context.script_dir.get_base()
    assert base_revision
    assert (
        base_revision == squashplan.squash_head.revision
    ), f"base revision {base_revision} != squash head {squashplan.squash_head.revision}"
    git.add(new_script.path, new_baseline_dump_path, _err=sys.stderr)
    print_warning("Please review the diff and commit before continuing")
    git.diff("--staged", _fg=True)
    print_message("example commit message:")
    print_message(f"alembic: squashed baseline {release_version}")


def dump_baseline(context: Context) -> None:
    # we need a docker db image with only squash revisions applied
    dockerfile_db = context.dockerfile_db
    squashplan = read_squashplan(context.script_dir)
    print_message(f"Target tag: {squashplan.target_tag}")
    print_message(
        "Will generate a dockerfile that will build a database "
        f"to revision {squashplan.squash_head}"
    )
    new_dockerfile_db = context.squash_dir / f"Dockerfile-db-baseline-{squashplan.target_tag}"
    sh.sed(
        f"s/upgrade head/upgrade {squashplan.squash_head.revision}/",
        dockerfile_db,
        _out=new_dockerfile_db,
        _err=sys.stderr,
    )
    print_message(f"✓ {new_dockerfile_db} created")

    release_version = squashplan.target_tag.replace("wazo-", "").replace(".", "")
    dump_path = context.squash_dir / f"baseline-{release_version}.sql"
    sh.bash(
        context.tool_dir / "generate-baseline-schema-dump.sh",
        "-f",
        new_dockerfile_db,
        dump_path,
        _err=sys.stderr,
        _env={"SQUASH_TOOL_DIR": str(context.tool_dir)},
    )
    print_message(f"✓ Baseline SQL dump generated at {dump_path}")
    if insert_lines := sh.grep("-n", "-e", "^INSERT", dump_path, _ok_code=[0, 1]):
        print_warning(
            "! Baseline SQL dump contains INSERT statements which probably need modifications, "
            "please review"
        )
        for line in insert_lines.strip().split("\n"):
            if line.strip():
                print_warning(f"\t {line}")


def build_docker(dockerfile: Path, build_context_dir: Path, *flags) -> str:
    return sh.docker.build(
        "-q", "-f", dockerfile, *flags, build_context_dir, _err=sys.stderr
    ).strip()


@contextmanager
def spawn_container(image_id_or_tag: str, *flags: str):
    container_id = None
    command = sh.docker.run.bake(
        "-d",
        "--rm",
        *flags,
        image_id_or_tag,
        _err=sys.stderr,
    )
    print_message(f"Running container: {command}")
    try:
        container_id = command().strip()
        yield container_id
    except sh.ErrorReturnCode:
        print_error(f"Error while running container {command}")
        print_error(format_exc())
        sys.exit(1)
    finally:
        if container_id:
            sh.docker.stop(container_id, _ok_code=[0, 1])


def dump_schema_info(context: Context, schema_tag: str) -> None:
    # use Dockerfile-db database to get \dS+ output
    db_image_id = build_docker(context.dockerfile_db, context.project_root)
    assert db_image_id
    with open(context.squash_dir / f"{schema_tag}_db_image_id", "w") as f:
        f.write(db_image_id)
    print_message(f"✓ Database image id: {db_image_id}")

    with spawn_container(db_image_id) as container_id:
        time.sleep(2)
        sh.docker.exec(
            container_id,
            "psql",
            "-U",
            "postgres",
            "-d",
            context.database_name,
            "-c",
            "\\dS+ public.*",
            _out=context.squash_dir / f"{schema_tag}_schema_info.txt",
        )
    print_message(
        f"✓ Schema info dumped to {context.squash_dir / f'{schema_tag}_schema_info.txt'}"
    )


def dump_data(context: Context, image_id: str, dump_tag: str) -> Path:
    # import env.py file
    env_py = Path(context.script_dir.dir) / "env.py"
    alembic_version_table = env_py.read_text().split("VERSION_TABLE = ")[1].split("'")[1]
    print_message(f"✓ Alembic version table: {alembic_version_table}")

    pg_dump_flags = [
        "-d",
        context.database_name,
        "-a",
        f"--exclude-table={alembic_version_table}",
        "--no-owner",
        "--inserts",
    ]
    dump_path = context.squash_dir / f"{dump_tag}_data.txt"
    with spawn_container(image_id) as container_id:
        time.sleep(2)
        sh.docker.exec(
            container_id,
            "pg_dump",
            *pg_dump_flags,
            _out=dump_path,
        )
    print_message(f"✓ Data dumped to {dump_path}")
    return dump_path


def verify_schema_info(context: Context) -> None:
    unsquashed_schema_info = context.squash_dir / "unsquashed_schema_info.txt"
    squashed_schema_info = context.squash_dir / "squashed_schema_info.txt"
    assert (
        unsquashed_schema_info.exists()
    ), "missing unsquashed schema info at {unsquashed_schema_info}"
    assert squashed_schema_info.exists(), "missing squashed schema info at {squashed_schema_info}"

    diff_path = context.squash_dir / "schema_info.diff"
    sh.diff(unsquashed_schema_info, squashed_schema_info, _out=diff_path, _ok_code=[0, 1])
    print_message(f"✓ Schema info diff stored at {diff_path}, please review")
    if difflines := diff_path.read_text().splitlines():
        print_warning(f"! {len(difflines)} lines of difference in schema info dumps, please check")
    else:
        print_message("✓ No schema info diff found")


def verify_live_schemas(context: Context) -> None:
    unsquashed_image_id = (context.squash_dir / "unsquashed_db_image_id").read_text()
    assert unsquashed_image_id
    squashed_image_id = (context.squash_dir / "squashed_db_image_id").read_text()
    assert squashed_image_id

    database_name = context.database_name
    with spawn_container(unsquashed_image_id, "-p", "5432") as unsquashed_container_id:
        unsquashed_port = sh.docker.port(unsquashed_container_id, "5432").strip().split(":")[-1]
        unsquashed_uri = (
            f"postgresql://{context.db_username}:{context.db_password}@"
            f"localhost:{unsquashed_port}/{database_name}"
        )
        with spawn_container(squashed_image_id, "-p", "5432") as squashed_container_id:
            squashed_port = sh.docker.port(squashed_container_id, "5432").strip().split(":")[-1]
            squashed_uri = (
                f"postgresql://{context.db_username}:{context.db_password}"
                f"@localhost:{squashed_port}/{database_name}"
            )
            time.sleep(2)  # wait for database to be ready

            sh.migra(
                "--unsafe",
                unsquashed_uri,
                squashed_uri,
                _out=context.squash_dir / "migra.txt",
                _ok_code=[0, 2],
            )
            print_message(f"✓ Migra diff stored at {context.squash_dir / 'migra.txt'}")
            if difflines := (context.squash_dir / "migra.txt").read_text().splitlines():
                print_warning(
                    f"! {len(difflines)} lines of difference in migra diff, please check"
                )
            else:
                print_message("✓ No migra diff")


def verify_data(context: Context) -> None:
    unsquashed_image_id = (context.squash_dir / "unsquashed_db_image_id").read_text()
    squashed_image_id = (context.squash_dir / "squashed_db_image_id").read_text()
    unsquashed_data_path = dump_data(context, unsquashed_image_id, "unsquashed")
    squashed_data_path = dump_data(context, squashed_image_id, "squashed")

    diff_path = context.squash_dir / "data.diff"

    diff_cmd = sh.diff(
        unsquashed_data_path,
        squashed_data_path,
        _out=diff_path,
        _ok_code=[0, 1],
        _return_cmd=True,
    )
    print_message(f"✓ Data diff stored at {diff_path}")
    if diff_cmd.exit_code == 0:
        print_message("✓ No data diff found")
    else:
        diff_length = len([line for line in diff_path.read_text().splitlines() if line.strip()])
        print_warning(f"! {diff_length} lines of data diff found, please review")


def verify(context: Context) -> None:
    # first check the schema info dumps
    verify_schema_info(context)

    # now compare data of live databases using migra
    verify_live_schemas(context)

    # now verify data
    verify_data(context)


def check_repo_state() -> None:
    if git.status("--porcelain", "-u", "no").strip():
        print_error("! Repo is not clean, please commit or stash changes")
        sys.exit(1)
    print_message("✓ Repo is clean")

    head_info = git("rev-parse", "--abbrev-ref", "HEAD").strip()
    print_message(f"Git head: {head_info}")
    if head_info in ("master", "main"):
        print_warning(
            "! Git head is on a main branch, you should create a dedicated branch first!"
        )
        sys.exit(1)
    print_message("✓ Git head is not master or main")
    print_message("Confirm you're okay with that branch, else create a new branch")
    assert ask_confirm()


def update_packaging(context: Context) -> None:
    # might need to update packaging to include sql baseline in alembic files

    # first check if alembic is part of the python packaging
    alembic_package = next((pkg for pkg in find_packages() if pkg.endswith(".alembic")), None)
    if alembic_package:
        print_message("✓ alembic part of the python packaging")
        # we must ensure the sql baseline is included in the package data files
        # first find the package_data line in setup.py
        setup_py = context.project_root / "setup.py"
        if not setup_py.exists():
            print_error(f"setup.py not found at {setup_py}")
            sys.exit(1)

        package_data_entry = f'"{alembic_package}": ["versions/*.sql"]'
        updated = False
        with fileinput.input(files=(setup_py,), inplace=True) as setup_content:
            for line in setup_content:
                if "package_data=" in line:
                    new_line = re.sub(
                        r"package_data={(.*)},",
                        f"package_data={{\\1, {package_data_entry}}},",
                        line,
                    )
                    if line != new_line:
                        updated = True
                        line = new_line
                print(line, end="")

        if not updated:
            print_warning("! Failed to update setup.py package_data entry, please do it manually")
            ask_confirm()
            sh.edit("--debug", setup_py, _fg=True)

        print_message(
            f"✓ setup.py updated with package_data entry "
            f"for sql baseline files in {alembic_package} package"
        )
        git.add(setup_py)
        print_warning("! Please review the diff and commit before continuing")
        git.diff("--staged", _fg=True)
        print_message("example commit message:")
        print_message("packaging: add alembic sql files to package data")
    else:
        print_message("alembic not part of python packaging")
        # alembic not part of python packaging, let's check debian config

        # conditions: check if alembic managed by debian install
        debian_dir = context.project_root / "debian"
        if not debian_dir.exists():
            print_message("✓ Debian directory not found, skipping packaging update")
            return

        # get {project_name}.install file
        install_file = debian_dir / f"{context.project_name}.install"
        if not install_file.exists():
            print_message("✓ Install file not found, skipping packaging update")
            return

        if "alembic" in install_file.read_text():
            print_message("✓ alembic directory is managed explicitly by debian .install config")
        else:
            print_warning(
                "! alembic directory is not managed explicitly by debian .install config"
            )
            print_warning(
                "Make sure the debian packaging properly handles sql files in alembic directory"
            )


def git_ignore_squashdir(context: Context) -> None:
    gitdir = context.project_root / ".git"
    if not gitdir.exists():
        print_error(f"Git directory not found at {gitdir}")
        sys.exit(1)

    exclude_file = gitdir / "info" / "exclude"
    if not exclude_file.exists():
        print_error(f"Git exclude file not found at {exclude_file}")
        sys.exit(1)

    if ".alembic_squash" in exclude_file.read_text():
        print_message("✓ .alembic_squash is already excluded from git")
        return

    with open(exclude_file, "a") as f:
        f.write(".alembic_squash\n")

    print_message("✓ .alembic_squash added to git exclude")


class COMMANDS(str, Enum):
    PLAN = "plan"
    SQUASH = "squash"
    DUMP_BASELINE = "dump-baseline"
    VERIFY = "verify"
    DUMP_SCHEMA_INFO = "dump-schema-info"
    UPDATE_PACKAGING = "update-packaging"

    def __str__(self):
        return self.value


def parse_args():
    parser = argparse.ArgumentParser(description="Alembic squashing tool")
    parser.add_argument(
        "--project-root",
        type=lambda x: Path(x).expanduser(),
        default=os.getenv("SQUASH_PROJECT_ROOT", Path.cwd()),
        help="Path to project root, defaults to current working directory",
    )
    parser.add_argument(
        "--alembic-ini-path",
        type=Path,
        default=os.getenv("SQUASH_ALEMBIC_INI_PATH", None),
        help="Path to alembic.ini file, defaults to autodiscovery",
    )
    parser.add_argument(
        "--db-password",
        type=str,
        default=os.getenv("SQUASH_DB_PASSWORD", "Secr7t"),
        help="Database password used in database dockerfile",
    )
    subparsers = parser.add_subparsers(dest="command")

    prepare_squashplan_parser = subparsers.add_parser(
        COMMANDS.PLAN,
        help="Prepare the squash plan for the target tag and perform any preparatory tasks",
    )
    prepare_squashplan_parser.add_argument(
        "target_tag", action="store", type=str, help="Target tag for squashing"
    )

    _ = subparsers.add_parser(COMMANDS.SQUASH, help="Perform squashing of alembic revisions")

    _ = subparsers.add_parser(
        COMMANDS.DUMP_BASELINE,
        help="Generate the baseline schema dump for the target tag "
        "for use in squashed alembic migration",
    )

    _ = subparsers.add_parser(
        COMMANDS.VERIFY,
        help="Verify that the squashed database schema is compatible "
        "with the unsquashed database schema",
    )

    _ = subparsers.add_parser(
        COMMANDS.UPDATE_PACKAGING,
        help="ensure project packaging properly handles sql baseline files",
    )

    dump_schema_info_parser = subparsers.add_parser(
        COMMANDS.DUMP_SCHEMA_INFO,
        help="Dump schema info from a build of the current database schema",
    )
    dump_schema_info_parser.add_argument(
        "schema_tag",
        action="store",
        type=str,
        help="string to use as part of schema info dump file name",
    )

    return parser.parse_args()


def main():
    args = parse_args()
    print_message(f"Project root: {args.project_root}")
    if os.getcwd() != args.project_root:
        os.chdir(args.project_root)
        print_message(f"✓ Changed working directory to {args.project_root}")

    config = get_alembic_config(
        project_root=args.project_root, alembic_ini_path=args.alembic_ini_path
    )
    print_message(f"✓ Loaded Alembic configuration from {config.config_file_name}")

    assert args.project_root == Path.cwd()

    script_dir = ScriptDirectory.from_config(config)
    print_message(f"Script directory: {script_dir.dir}")

    contrib_docker_dir = args.project_root / "contribs" / "docker"
    dockerfile_db = None
    for path in (
        contrib_docker_dir / "Dockerfile-db",
        contrib_docker_dir / f"{args.project_root.name}-db.Dockerfile",
    ):
        if path.exists():
            print_message(f"✓ Found db dockerfile at {path}")
            dockerfile_db = path
            break

    if not dockerfile_db:
        print_error(f"No Dockerfile-db found in {contrib_docker_dir}")
        sys.exit(1)

    context = Context(
        script_dir=script_dir,
        squash_dir=args.project_root / ".alembic_squash",
        project_root=args.project_root,
        project_name=args.project_root.name,
        database_name=args.project_root.name,
        alembic_config=config,
        db_username=args.project_root.name,
        db_password=args.db_password,
        tool_dir=Path(__file__).parent,
        dockerfile_db=dockerfile_db,
    )

    if not context.squash_dir.exists():
        context.squash_dir.mkdir()
        print_message(f"✓ Created utility directory at {context.squash_dir}")

    if args.command == COMMANDS.PLAN:
        target_tag = args.target_tag
        print_message(f"Target tag: {target_tag}")
        check_repo_state()
        git_ignore_squashdir(context)
        prepare_squashplan(context, target_tag)
        dump_schema_info(context, "unsquashed")
        print_message("Now run dump-baseline subcommand to get the baseline sql dump")
        sys.exit(0)
    elif args.command == COMMANDS.DUMP_SCHEMA_INFO:
        dump_schema_info(context, args.schema_tag)
        sys.exit(0)
    elif args.command == COMMANDS.DUMP_BASELINE:
        dump_baseline(context)
        print_message(
            "When ready run the `squash` subcommand "
            "to generate the squashed baseline alembic revision"
        )
        sys.exit(0)
    elif args.command == COMMANDS.SQUASH:
        squash(context)
        print_message(
            "Now you can run the verify subcommand to compare the pre-squashing "
            "and post-squashing schemas "
            "and the update-packaging subcommand to ensure the sql files are properly packaged"
        )
        sys.exit(0)
    elif args.command == COMMANDS.VERIFY:
        try:
            dump_schema_info(context, "squashed")
        except Exception:
            print_error("Failed to dump schema info with squashed migrations")
            print_error(
                "You can run 'dump-schema-info squashed' subcommand manually "
                "after resolving the error"
            )
            raise
        verify(context)
        sys.exit(0)
    elif args.command == COMMANDS.UPDATE_PACKAGING:
        update_packaging(context)
        sys.exit(0)
    else:
        print_error(f"Unknown subcommand: {args.command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
