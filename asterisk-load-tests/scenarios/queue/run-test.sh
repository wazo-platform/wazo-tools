#!/bin/bash
# Queue call load test runner.
# Usage: ./run-test.sh [duration_seconds]
#
# Examples:
#   scenarios/queue/run-test.sh        # 600s (default)
#   scenarios/queue/run-test.sh 300    # 5 min

set -e
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$ROOT_DIR"

DURATION=${1:-600}
ASTERISK_TAG=${ASTERISK_TAG:-wazo-26.06}

COMPOSE=(-f docker-compose.yml -f scenarios/queue/docker-compose.override.yml)

# shellcheck disable=SC2329  # invoked indirectly via 'trap cleanup EXIT'
cleanup() {
    echo
    echo "Tearing down containers..."
    docker compose "${COMPOSE[@]}" down
}
trap cleanup EXIT

echo "============================================"
echo "Queue call load test"
echo "  Duration:     ${DURATION}s"
echo "  Asterisk tag: $ASTERISK_TAG"
echo "============================================"

mkdir -p cores results

# Back up any previous result instead of overwriting it (cleaned by `make clean`).
if [ -f results/load_result.json ]; then
    mv results/load_result.json "results/load_result.$(date +%Y%m%d-%H%M%S).json"
fi

docker compose "${COMPOSE[@]}" build asterisk
docker compose "${COMPOSE[@]}" build load-generator

DURATION="$DURATION" ASTERISK_TAG="$ASTERISK_TAG" docker compose "${COMPOSE[@]}" up \
    --abort-on-container-exit \
    --exit-code-from load-generator \
    2>&1 | tee "results/queue_$(date +%Y%m%d-%H%M%S).log"

EXIT_CODE=${PIPESTATUS[0]}

echo
echo "============================================"
echo "Test complete"
echo "============================================"
if [ -f results/load_result.json ]; then
    echo "Stats:"
    jq '.stats' results/load_result.json 2>/dev/null || cat results/load_result.json
else
    echo "Result: NO RESULT FILE (test may have crashed)"
fi

echo "Logs:   results/queue_*.log"
echo "Cores:  cores/"
echo "Result: results/load_result.json"

exit "$EXIT_CODE"
