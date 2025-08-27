# Alembic Squash Tools Usage Instructions

## Overview

The alembic squash tools automate the process of squashing old Alembic database migrations in Wazo projects. This is useful for reducing the number of migration files that are used to setup the database in new deployments, and limit the maintenance burden of the python scripts.

## Prerequisites and Dependencies

### System Requirements

- **Python 3.9** (for compatibility with bullseye releases)
  - with python venv module (e.g. `python3-venv` on debian distros)
- **Docker** (for building and running database containers)
- **Git** (for repository operations)
- **Bash shell** (for shell scripts and operating the tools)

### Python Dependencies

The python dependencies are managed automatically by the [bootstrap.sh](./bootstrap.sh) script.

The tools require the following Python packages(see [`requirements.txt`](./requirements.txt)):

- `sh>=2.*.*` - Python subprocess interface library
- `migra` - Database schema comparison tool
- `alembic` - Database migration framework

Additionally, the target project's python dependencies are also required.

## Installation and Setup

1. Clone this repository locally and obtain all pre-requisite dependencies (see [System Requirements](#system-requirements))
  - ensure docker is available and usable for the current user (docker daemon is running, etc)
2. Ensure the projects on which to apply the squash procedure are available locally and are in a clean, safe state(no uncommitted pending changes, etc)

## Usage Workflow

Assuming a project "wazo-example" available at "~/wazo/wazo-example".

### Step 0: Setup a python virtual environment

The [bootstrap.sh](./bootstrap.sh) script can be used to setup a python virtual environment appropriate to perform the procedure.
This will create a virtual environment directory in the current working directory, named after the project, and will install both the alembic squash tools dependencies and the target project's python dependencies.

Alternatively, [shell.sh](./shell.sh) can be used to both bootstrap the virtual environment and start a bash shell in the target project's directory, with the virtual environment activated and the alembic squash tools available in the path.

### Step 1: Prepare the Squash Plan

Assuming the virtual environment is bootstrapped and a shell with the environment activated.

```bash
# Navigate to your target project directory
cd ~/wazo/wazo-project

# Run the plan command to create a squash plan
python ~/wazo/wazo-tools/alembic_squash/alembic_squash.py plan <target_tag>
# or
~/wazo/wazo-tools/alembic_squash/alembic_squash.py plan <target_tag>
# or if using shell.sh and the ~/wazo-tools/alembic_squash directory is in the path
alembic_squash.py plan <target_tag>
```

**Example:**

```bash
~/wazo/wazo-tools/alembic_squash/alembic_squash.py plan wazo-23.05
```

The command will explain its actions and ask for confirmations.
On success, expect a `.alembic_squash` directory containing a `squashplan` file.

### Step 2: Generate Baseline Schema Dump

```bash
# Generate the baseline SQL dump
~/wazo/wazo-tools/alembic_squash/alembic_squash.py dump-baseline
```
On success, expect a sql dump file to be created in the `.alembic_squash/` directory.

### Step 3: Execute the Squash

```bash
# Perform the actual squashing operation
~/wazo/wazo-tools/alembic_squash/alembic_squash.py squash
```
Confirmation will be asked on some steps.
On success, new commits will be created in the repository.
The squashed alembic migration will replace the existing revisions.

### Step 4: Verify the Results

```bash
# Compare pre and post-squashing schemas
~/wazo/wazo-tools/alembic_squash/alembic_squash.py verify
```
On success, the output will inform of any discrepancies found between the pre and post-squashing schemas.
Expect some insignificant differences in the way that some datatypes are represented(migra will suggest recreating affected constraints). 
Make sure no significant differences are found.

Run integration tests(or let the CI do it) to make sure the database is still working as expected.


## Scripts

### [alembic_squash.py](./alembic_squash.py)

This is a python script orchestrating and performing most of the tasks, calling out to other tools and scripts.
It is the only script that needs to be used to perform the squash procedure.

See `alembic_squash.py --help` for help on all available commands and options.

### [shell.sh](./shell.sh)

A bash script serving as a single-point-of-entry to bootstrap the working environment and start a shell in the target project's directory, with the environment setup with all required tools and dependencies.

The script will setup environment variables available in the resulting shell:

- `SQUASH_PROJECT_ROOT` - the path to the target project, can be read by [alembic_squash.py](./alembic_squash.py)
- `SQUASH_VENV_PATH` - the path to the virtual environment

Example usage:

```bash
# Start an interactive shell with the tools available
$ ~/wazo-tools/alembic_squash/shell.sh ~/wazo/wazo-example

# now in the ~/wazo/wazo-example directory with the virtual environment activated
# and the alembic squash tools available in the path

(.wazo-example_squash_venv) ~/wazo/wazo-example$ alembic_squash.py plan wazo-23.05
(.wazo-example_squash_venv) ~/wazo/wazo-example$ alembic_squash.py dump-baseline
(.wazo-example_squash_venv) ~/wazo/wazo-example$ alembic_squash.py squash
(.wazo-example_squash_venv) ~/wazo/wazo-example$ alembic_squash.py verify
```

### Using the Bootstrap Script

The [bootstrap.sh](./bootstrap.sh) script is used by [shell.sh](./shell.sh) and can be used independently to bootstrap a work environment for a target project, creating the virtual environment with the required python dependencies.

The script will export the following environment variables if sourced:
- `SQUASH_VENV_PATH` - the path to the virtual environment

```bash
~/wazo/wazo-tools/alembic_squash/bootstrap.sh ~/wazo/wazo-example
# Activate the virtual environment
source .wazo-project_squash_venv/bin/activate

# or 
source ~/wazo/wazo-tools/alembic_squash/bootstrap.sh ~/wazo/wazo-example

# Run the tools
~/wazo/wazo-tools/alembic_squash/alembic_squash.py plan wazo-23.05
```

### [generate_baseline_schema_dump.sh](./generate_baseline_schema_dump.sh)

This is a bash script taking care of generating a .sql schema dump appropriate for use in alembic migrations, using a database container built from a database image specified by a local dockerfile.

- extensions statements are not included
- ownership statements are not included
- the postgres schema `search_path` is left untouched

The script is called by [alembic_squash.py](./alembic_squash.py) to generate the baseline schema dump when using the `dump-baseline` command(using a specially-crafted dockerfile running only the alembic migrations to be squashed)

```bash
# Generate a schema dump manually
~/wazo/wazo-tools/alembic_squash/generate_baseline_schema_dump.sh -f ~/wazo/wazo-example/contribs/docker/Dockerfile-db
```

## Troubleshooting

### Common Issues

1. **"Repo is not clean"** - Commit or stash your changes first
2. **"Git head is on main branch"** - Create a feature branch first
3. **"Dockerfile not found"** - Ensure a `contribs/docker/Dockerfile-db` exists

### Debugging

- Use `--help` flag for command options
- Check the `.alembic_squash/` directory for generated files
- Review diff files generated during verification
