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
ari-load.py ─originate─► PJSIP/queue-caller-N ─► [queues] s
                          (caller UAS: sipp)        │
                                            Queue(loadtest-{1,2})
                                                    │  rrmemory
                                                    ▼
                          PJSIP/agent-0..7 ─► sipp-agent UAS ─► bridge ─► talk 2s ─► agent BYE
```

- **queue-caller-N** — the leg the load generator originates; its contact is the
  base **`sipp`** UAS, so the caller leg answers, then runs `Queue(loadtest-{1,2})`
  (queue chosen at random in the dialplan). That UAS just waits for Asterisk's BYE.
- **agent-0..7** — queue members (`queues.conf`), shared by both queues. Their
  contact is a **separate `sipp-agent` UAS** that answers, holds for a ~2s talk
  time, then **hangs up itself** (`sipp-agent-uas.xml`). That release is what
  frees the member so the queue connects the next caller and `Completed`/talktime
  actually advance — with a single shared UAS that never hangs up, members latch
  to "In use" and the queue stalls (callers answered but never serviced).

Adjust the talk time via the `<pause milliseconds="2000"/>` in
`sipp-agent-uas.xml`. Service capacity is roughly `members / talk_time`; raise it
by adding `agent-N` endpoints + `member =>` lines or shortening the talk time.

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

### Loading the agent path

To actually saturate agents (rather than the queue-waiting path), three things matter:

- **`autofill = yes`** in `queues.conf` `[general]` — **required**. Asterisk
  defaults it to `no`, which serves callers strictly one at a time even with
  many free agents, so the queue dials only a trickle of members and stalls
  under load. With `yes`, waiting callers are distributed to free agents in
  parallel.
- **A `Queue()` timeout** (5th arg, e.g. `Queue(q,,,,20)` in `extensions.conf`)
  bounds the waiting backlog — unserved callers abandon at 20s instead of piling
  to the channel ceiling and starving the connect path.
- **Raised `nofile`** on both `sipp` and `sipp-agent` (override) — the agent UAS
  handles the bulk of short, churning calls; at 1024 fds it caps out and stops
  answering after a few dozen calls.

Reference run — 50 members, 500 ms talk, `Queue(,,,,20)`, ORIGINATORS=80: ~2,100
calls serviced by agents in 120 s (~18/s, evenly spread 30–51 per agent), 0
abandons, holdtime ~0 s, Asterisk healthy. Without `autofill = yes` the same
config completes ~40 calls then stalls with tens of thousands abandoning.

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
- `sipp-agent-uas.xml` — agent-side UAS: answers, talks ~2s, then sends BYE (frees the member).
- `run-test.sh` — convenience runner.
