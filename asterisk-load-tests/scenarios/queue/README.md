# Scenario: queue calls

Puts load on Asterisk's `app_queue` by funnelling originated calls through a
`Queue()` to a pool of PJSIP queue members.

The queue is configured with **`shared_lastcall = yes`** and two queues
(`loadtest-1` / `loadtest-2`) sharing the **same** `agent-N` members. With
shared lastcall, a call event in one queue forces app_queue to update the
member's counters in the other queue too — the cross-queue member locking that
has caused deadlocks. This setup is what exercises that path.

Built on the base stack (`../../docker-compose.yml`). It overrides the Asterisk
config only — the generic `ari-load.py` driver is reused unchanged, just pointed
at the queue dialplan via environment variables.

## Call flow

```text
ari-load.py ──originate──► PJSIP/queue-caller-N ──answered──► [queues] s
                                                                  │
                                                        Queue(loadtest-{1,2})
                                                                  │  rrmemory
                                                                  ▼
                                              PJSIP/agent-0..7 ──► SIPp UAS (answers) ──► bridge
```

- **queue-caller-N** — the leg the load generator originates; its static
  contact is the SIPp UAS, so the caller leg answers, then runs
  `Queue(loadtest-{1,2})` (queue chosen at random in the dialplan).
- **agent-0..7** — queue members (`queues.conf`), shared by both queues; app_queue
  dials them to deliver queued callers. Their contact is also the SIPp UAS, so
  delivery answers and bridges.

Both legs terminate at the SIPp UAS, which answers unlimited calls.

## Run

From the **repository root**:

```bash
scenarios/queue/run-test.sh            # 600s (default)
scenarios/queue/run-test.sh 300        # 5 min
```

Or directly with Compose:

```bash
docker compose -f docker-compose.yml \
  -f scenarios/queue/docker-compose.override.yml up \
  --abort-on-container-exit --exit-code-from load-generator
```

## Tuning

Standard base load knobs apply (`POLLERS`, `ORIGINATORS`, `ORIGINATE_INTERVAL`,
`NUM_ENDPOINTS`). `NUM_ENDPOINTS` is the number of **caller** endpoints and must
not exceed the `queue-caller-N` blocks in `asterisk-config/pjsip.conf`.

```bash
ORIGINATORS=20 ORIGINATE_INTERVAL=0.01 NUM_ENDPOINTS=5 \
  scenarios/queue/run-test.sh 300
```

Two regimes, switched in `asterisk-config/queues.conf`:

- **High call rate (default)** — `ringinuse = yes` lets app_queue keep dialing
  busy members, so calls bridge and churn quickly. Exercises member dialing,
  bridging, and CDR.
- **Queue waiting / MOH** — set `ringinuse = no` and/or trim the `member =>`
  list so callers park until a member frees up. Exercises queue position
  tracking, hold music, and the `timeout`/`retry` path.

To scale members, add `agent-N` endpoints in `pjsip.conf` and matching
`member => PJSIP/agent-N` lines in `queues.conf`.

## Results

- `results/load_result.json` — originate/poll stats from `ari-load.py`.
- `results/queue_*.log` — full test output.
- `cores/` — core dumps if Asterisk crashes.

Inspect live queue state while running:

```bash
docker exec loadtest-asterisk asterisk -rx "queue show loadtest-1"
docker exec loadtest-asterisk asterisk -rx "queue show loadtest-2"
docker exec loadtest-asterisk asterisk -rx "core show channels count"
```

## Files

- `docker-compose.override.yml` — layers this scenario on the base stack.
- `asterisk-config/pjsip.conf` — caller (`queue-caller-N`) + member (`agent-N`) endpoints.
- `asterisk-config/extensions.conf` — `[queues]` context running `Queue(loadtest-{1,2})`.
- `asterisk-config/queues.conf` — `shared_lastcall`, the two queues, and their shared members.
- `run-test.sh` — convenience runner.
