#!/bin/bash
# Wrapper that runs the deadlock-detecting driver with env-var configuration.
exec python3 /app/deadlock_test.py \
    --ari-url "${ARI_URL:-http://asterisk:8088/ari}" \
    --ari-user "${ARI_USER:-loadtest}" \
    --ari-pass "${ARI_PASS:-loadtest}" \
    --endpoint "${ENDPOINT:-PJSIP/deadlock-test}" \
    --context "${CONTEXT:-deadlock-test}" \
    --duration "${DURATION:-600}" \
    --pollers "${POLLERS:-30}" \
    --originators "${ORIGINATORS:-10}" \
    --poll-interval "${POLL_INTERVAL:-0.005}" \
    --originate-interval "${ORIGINATE_INTERVAL:-0.02}" \
    --num-endpoints "${NUM_ENDPOINTS:-5}" \
    --result-dir "${RESULT_DIR:-/results}"
