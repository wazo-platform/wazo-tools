#!/usr/bin/env bash

target_project_dir=$1


VENV_PATH="$PWD/.$(basename $target_project_dir)_squash_venv"
if [ ! -d $VENV_PATH ]; then
    python3.9 -m venv $VENV_PATH
    source $VENV_PATH/bin/activate
    pip install -r $target_project_dir/requirements.txt -r ./requirements.txt
else
    source $VENV_PATH/bin/activate
fi
trap "deactivate" EXIT

# expose alembic_squash.py in the path
export PATH=$(realpath $(dirname $0)):$PATH
export SQUASH_PROJECT_ROOT=$target_project_dir
cd $target_project_dir
echo "entering shell with virtual env $VENV_PATH"
echo "in $target_project_dir"
export PS1="$target_project_dir $PS1"
bash --noprofile --norc