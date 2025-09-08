#!/bin/bash

export SQUASH_TOOL_DIR=$(realpath $(dirname $0))
export SQUASH_PROJECT_ROOT=$1
bash --init-file "$(dirname $0)/shell-init.sh"