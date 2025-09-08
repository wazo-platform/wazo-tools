#!/usr/bin/env bash

target_project_dir=$1
if [ -z "$target_project_dir" ]; then
    echo "Usage: $0 <target_project_dir>"
    exit 1
fi

export SQUASH_VENV_PATH="$PWD/.$(basename $target_project_dir)_squash_venv"
if [ ! -d $SQUASH_VENV_PATH ]; then
    echo "Setting up virtual environment in $SQUASH_VENV_PATH"
    python3.9 -m venv $SQUASH_VENV_PATH
fi
source $SQUASH_VENV_PATH/bin/activate
trap "deactivate" EXIT

pip install --require-virtualenv -r $target_project_dir/requirements.txt -r ./requirements.txt $target_project_dir
