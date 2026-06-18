#!/bin/bash
# Deadlock reproduction test runner.
# Usage: ./run-test.sh [unpatched|patched] [duration_seconds]
#
# For the patched run, place a patched asterisk*.deb in <repo>/patch/.
#
# Examples:
#   scenarios/deadlock/run-test.sh                 # unpatched, 600s
#   scenarios/deadlock/run-test.sh unpatched 300   # unpatched, 5 min
#   scenarios/deadlock/run-test.sh patched 600     # patched, 10 min

set -e
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$ROOT_DIR"

VERSION=${1:-unpatched}
DURATION=${2:-600}
ASTERISK_TAG=${ASTERISK_TAG:-wazo-26.06}

COMPOSE=(-f docker-compose.yml -f scenarios/deadlock/docker-compose.override.yml)

# shellcheck disable=SC2329  # invoked indirectly via 'trap cleanup EXIT'
cleanup() {
    echo
    echo "Tearing down containers..."
    docker compose "${COMPOSE[@]}" down
}
trap cleanup EXIT

echo "============================================"
echo "Deadlock reproduction test"
echo "  Version:      $VERSION"
echo "  Duration:     ${DURATION}s"
echo "  Asterisk tag: $ASTERISK_TAG"
echo "============================================"

mkdir -p cores results patch

BUILD_ARGS=(--build-arg "TAG=$ASTERISK_TAG")
if [ "$VERSION" = "patched" ]; then
    if ! ls patch/asterisk*.deb 1>/dev/null 2>&1; then
        echo "ERROR: no asterisk*.deb found in ./patch/" >&2
        echo "Place the patched .deb there and retry." >&2
        exit 2
    fi
    BUILD_ARGS+=(--build-arg PATCH_DEB=1)
    echo "Using patched Asterisk from ./patch/"
fi

# Back up any previous result instead of overwriting it (cleaned by `make clean`).
if [ -f results/test_result.json ]; then
    mv results/test_result.json "results/test_result.$(date +%Y%m%d-%H%M%S).json"
fi

docker compose "${COMPOSE[@]}" build "${BUILD_ARGS[@]}" asterisk
docker compose "${COMPOSE[@]}" build load-generator

DURATION="$DURATION" ASTERISK_TAG="$ASTERISK_TAG" docker compose "${COMPOSE[@]}" up \
    --abort-on-container-exit \
    --exit-code-from load-generator \
    2>&1 | tee "results/deadlock_${VERSION}_$(date +%Y%m%d-%H%M%S).log"

EXIT_CODE=${PIPESTATUS[0]}

echo
echo "============================================"
echo "Test complete"
echo "============================================"
if [ -f results/test_result.json ]; then
    RESULT=$(jq -r '.result' results/test_result.json 2>/dev/null || echo "UNKNOWN")
    echo "Result:  $RESULT"
    echo "Version: $VERSION"
    if [ "$RESULT" = "DEADLOCK_DETECTED" ]; then
        DETECTION_TIME=$(jq -r '.detection_time_seconds' results/test_result.json 2>/dev/null || echo "?")
        echo "Deadlock detected after: ${DETECTION_TIME}s"
    fi
else
    echo "Result: NO RESULT FILE (test may have crashed)"
fi

echo "Logs:   results/deadlock_${VERSION}_*.log"
echo "Cores:  cores/"
echo "Result: results/test_result.json"

exit "$EXIT_CODE"
