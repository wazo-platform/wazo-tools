# Scenario: PJSIP_HEADER + ARI deadlock

Reproduces the lock-ordering deadlock between ARI channel-variable reads and
PJSIP `Dial()` with `PJSIP_HEADER()` in an endpoint's `set_var`.

This is a worked example built on the base stack (`../../docker-compose.yml`).
It overrides the Asterisk config (endpoints with `PJSIP_HEADER` set_var + an
inbound SIPp trunk), swaps in a slow SIPp UAS to keep the serializer busy, adds
a SIPp UAC for inbound calls, and runs the deadlock-detecting driver
`deadlock_test.py` instead of the generic `ari-load.py`.

## Deadlock pattern

1. **Thread A** (ARI `GET /channels/{id}/variable`): acquires the channels
   container lock → tries to lock the individual channel.
2. **Thread B** (`Dial()` via `chan_pjsip_new`): holds the channel lock →
   `PJSIP_HEADER` triggers `func_write_header` → synchronous serializer
   `push_wait`.
3. **Thread C** (PJSIP serializer): needs the container lock → blocked by Thread A.

Circular: container_lock → channel_lock → serializer_wait → container_lock.

## Run

From the **repository root**:

```bash
scenarios/deadlock/run-test.sh                 # unpatched, 600s
scenarios/deadlock/run-test.sh unpatched 300   # unpatched, 5 min
scenarios/deadlock/run-test.sh patched 600     # patched .deb in ../../patch/
```

Or directly with Compose:

```bash
docker compose -f docker-compose.yml \
  -f scenarios/deadlock/docker-compose.override.yml up \
  --abort-on-container-exit --exit-code-from load-generator
```

### Tuning for deadlock probability

Fewer endpoints + more pollers + faster origination = higher probability.

```bash
POLLERS=50 ORIGINATORS=15 POLL_INTERVAL=0.002 NUM_ENDPOINTS=3 \
  scenarios/deadlock/run-test.sh
```

## Fix validation (before/after)

```bash
scenarios/deadlock/run-test.sh unpatched 600   # should deadlock
cp /path/to/asterisk_*-fixed.deb patch/         # repo-root patch/
scenarios/deadlock/run-test.sh patched 600     # should NOT deadlock
```

## Results & exit codes

- `results/test_result.json` — structured result with pass/fail and stats.
- `results/deadlock_*.log` — full test output.
- `cores/` — core dumps captured by `res_freeze_check` or `gcore`.

| Exit code | Meaning |
| --- | --- |
| 0 | No deadlock detected |
| 1 | Deadlock detected |
| 2 | Configuration error (e.g. missing patched .deb) |

## Analyzing a core dump

```bash
docker exec -it loadtest-asterisk gdb /usr/sbin/asterisk /var/spool/asterisk/cores/core.*
# (gdb) thread apply all bt
#
# Look for:
#  - a thread on __ast_pthread_mutex_lock in channelstorage_ao2_legacy.c (container lock)
#  - a thread on __ast_cond_wait in res_pjsip_header_funcs.c (serializer wait)
```

`monitor_deadlock.sh` watches Asterisk responsiveness and captures a core dump
on hang; it can be run inside the asterisk container.

## Files

- `deadlock_test.py` — load driver with deadlock detection (pollers vs originators).
- `loadgen-run.sh` — env-var wrapper used by the Compose override.
- `docker-compose.override.yml` — layers this scenario on the base stack.
- `asterisk-config/{pjsip,extensions}.conf` — endpoints with `PJSIP_HEADER` + inbound trunk.
- `sipp-uas-slow.xml` — slow UAS that keeps the serializer busy.
- `monitor_deadlock.sh` — responsiveness monitor + core-dump capture.
- `endpoints.csv` — endpoint list for SIPp registration runs.
