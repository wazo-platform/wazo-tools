# expose alembic_squash.py in the path

if [ -z "$SQUASH_PROJECT_ROOT" ]; then
    exit 1
fi

source ./bootstrap.sh $SQUASH_PROJECT_ROOT

if [ -z "$SQUASH_VENV_PATH" ]; then
    echo "bootstrap.sh failed to set SQUASH_VENV_PATH"
    exit 1
fi

export PATH=$(realpath $(dirname $0)):$PATH # expose alembic_squash directory in the path
export SQUASH_PROJECT_ROOT
export SQUASH_VENV_PATH
cd $SQUASH_PROJECT_ROOT
echo "entering shell with virtual env $SQUASH_VENV_PATH"
echo "in $SQUASH_PROJECT_ROOT"