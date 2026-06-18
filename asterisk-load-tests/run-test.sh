#!/bin/bash
# Run the base Asterisk load test.
# Usage: ./run-test.sh [duration_seconds]
#
# Tuning is done through environment variables (see README.md), e.g.:
#   POLLERS=50 ORIGINATORS=20 DURATION=300 ./run-test.sh
#
# Scenarios layer an override on top of this stack; see scenarios/*/README.md.

set -e
set -u
set -o pipefail

DURATION=${1:-${DURATION:-600}}
ASTERISK_TAG=${ASTERISK_TAG:-wazo-26.03}

cleanup() {
    echo
    echo "Tearing down containers..."
    docker compose down
}
trap cleanup EXIT

mkdir -p cores results

echo "============================================"
echo "Asterisk load test"
echo "  Duration:     ${DURATION}s"
echo "  Asterisk tag: ${ASTERISK_TAG}"
echo "============================================"

ASTERISK_TAG="$ASTERISK_TAG" docker compose build

DURATION="$DURATION" ASTERISK_TAG="$ASTERISK_TAG" docker compose up \
    --abort-on-container-exit \
    --exit-code-from load-generator \
    2>&1 | tee "results/loadtest_$(date +%Y%m%d-%H%M%S).log"
