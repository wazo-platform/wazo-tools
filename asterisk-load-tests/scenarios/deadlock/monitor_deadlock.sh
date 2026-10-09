#!/bin/bash
# Monitor Asterisk for deadlock during test
# Usage: ./monitor_deadlock.sh [timeout_seconds]

TIMEOUT=${1:-30}
CHECK_INTERVAL=5
COREDUMP_DIR="/tmp/deadlock-test-cores"

mkdir -p "$COREDUMP_DIR"

echo "Deadlock Monitor Started"
echo "  CLI timeout: ${TIMEOUT}s"
echo "  Check interval: ${CHECK_INTERVAL}s"
echo "  Coredump dir: ${COREDUMP_DIR}"
echo ""

check_count=0
while true; do
    check_count=$((check_count + 1))

    # Try to run a simple CLI command with timeout
    start_time=$(date +%s.%N)

    if timeout "$TIMEOUT" asterisk -rx "core show channels count" > /dev/null 2>&1; then
        end_time=$(date +%s.%N)
        elapsed=$(echo "$end_time - $start_time" | bc)

        # Get channel count for reporting
        channels=$(asterisk -rx "core show channels count" 2>/dev/null | grep "active channels" | awk '{print $1}')

        if (( $(echo "$elapsed > 2" | bc -l) )); then
            echo "[CHECK $check_count] SLOW: ${elapsed}s (channels: ${channels:-?})"
        else
            echo "[CHECK $check_count] OK: ${elapsed}s (channels: ${channels:-?})"
        fi
    else
        echo ""
        echo "==========================================="
        echo "[CHECK $check_count] DEADLOCK DETECTED!"
        echo "  CLI command did not complete in ${TIMEOUT}s"
        echo "==========================================="
        echo ""

        # Get Asterisk PID
        ast_pid=$(pidof asterisk)

        if [ -n "$ast_pid" ]; then
            echo "Asterisk PID: $ast_pid"

            # Capture coredump
            coredump_file="${COREDUMP_DIR}/core.deadlock.${ast_pid}.$(date +%Y%m%d-%H%M%S)"
            echo "Generating coredump: $coredump_file"

            if command -v gcore &> /dev/null; then
                sudo gcore -o "$coredump_file" "$ast_pid" 2>/dev/null
                echo "Coredump saved to: ${coredump_file}.${ast_pid}"
            else
                echo "gcore not available - install gdb package"
            fi

            # Show thread states
            echo ""
            echo "Thread states (top 20 blocked):"
            sudo cat /proc/"$ast_pid"/task/*/wchan 2>/dev/null | sort | uniq -c | sort -rn | head -20

            # Try to get lock info via CLI (may hang)
            echo ""
            echo "Attempting to get lock info (may timeout)..."
            timeout 5 asterisk -rx "core show locks" 2>/dev/null || echo "  (timed out)"
        else
            echo "Asterisk process not found"
        fi

        echo ""
        echo "Test should be stopped. Deadlock confirmed."
        exit 1
    fi

    sleep "$CHECK_INTERVAL"
done
