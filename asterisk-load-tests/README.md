# Asterisk load tests

A small Docker Compose harness for putting load on Asterisk (Wazo image) and a
reusable base for building load-test scenarios.

The **base** stack drives ARI + SIP traffic against an Asterisk container:

```text
┌──────────────┐    ARI HTTP     ┌─────────────────┐   SIP INVITE   ┌──────────┐
│ load-gen     │ ──────────────► │   Asterisk      │ ─────────────► │ SIPp UAS │
│ (ari-load.py)│  poll + dial    │  (Wazo image)   │  Dial() out    │ (answers)│
└──────────────┘ ◄────────────── └─────────────────┘ ◄───────────── └──────────┘
```

Three services (`docker-compose.yml`):

- **asterisk** — Wazo Asterisk with `gdb`/`gcore`, core dumps, and the
  `res_freeze_check` module.
- **sipp** — SIPp UAS answering the calls Asterisk dials out (`sipp/uas.xml`).
- **load-generator** — `ari-load.py`: concurrent ARI channel-variable pollers
  and call originators.

## Quick start

```bash
./run-test.sh            # base load for 600s (default)
./run-test.sh 120        # base load for 2 min
```

Results land in `results/load_result.json` and `results/loadtest_*.log`.
Core dumps (if Asterisk crashes) land in `cores/`. Previous result files are
backed up with a timestamp rather than overwritten.

Remove generated logs, results (including backups) and core dumps with:

```bash
make clean
```

## Configuration

The load generator is configured through environment variables (see
`docker-compose.yml` and `ari-load.py --help`):

| Variable | Default | Description |
| --- | --- | --- |
| `ASTERISK_TAG` | `wazo-26.03` | `wazoplatform/asterisk` image tag |
| `DURATION` | `600` | Test duration (seconds) |
| `POLLERS` | `30` | Concurrent ARI channel-variable pollers |
| `ORIGINATORS` | `10` | Concurrent call originators |
| `POLL_INTERVAL` | `0.005` | Seconds between poll cycles |
| `ORIGINATE_INTERVAL` | `0.02` | Seconds between originate attempts |
| `NUM_ENDPOINTS` | `3` | PJSIP endpoints to rotate through |
| `ARI_USER` / `ARI_PASS` | `loadtest` | ARI credentials |

```bash
POLLERS=50 ORIGINATORS=20 DURATION=300 ./run-test.sh
```

`NUM_ENDPOINTS` must not exceed the number of `[loadtest-N]` endpoints defined in
`asterisk-config/pjsip.conf` — add more blocks there to scale up.

## Layout

```text
asterisk-load-tests/
├── docker-compose.yml        # base stack
├── Dockerfile.asterisk       # Wazo Asterisk + debug tools (optional patched .deb)
├── Dockerfile.loadgen        # ari-load.py container
├── ari-load.py               # generic ARI load driver
├── run-test.sh               # base runner
├── requirements.txt
├── asterisk-config/          # ari / http / modules / pjsip / extensions
├── sipp/                     # reusable SIPp building blocks (uas, uac, register)
└── scenarios/
    └── deadlock/             # worked example: PJSIP_HEADER + ARI deadlock repro
```

## Authoring a scenario

A scenario is just a Compose override that layers on the base stack, plus whatever files that
override references. There is no plugin system — a scenario is a directory under `scenarios/`.

First decide what you are varying:

- **Only the load profile** (more pollers, faster origination, more endpoints) — you do not need
  a scenario. Set env vars on the base: `POLLERS=80 ORIGINATORS=30 NUM_ENDPOINTS=5 ./run-test.sh`.
- **Behaviour** (a custom driver, different dialplan/endpoints, extra SIP actors, a specific
  repro) — create `scenarios/<name>/` with a `docker-compose.override.yml`.

### Anatomy

```text
scenarios/<name>/
├── docker-compose.override.yml   # the only required file — layers on the base
├── README.md                     # what it does / how to run (convention)
├── run-test.sh                   # optional convenience runner
├── <driver>.py + loadgen-run.sh  # optional: a custom load driver
├── asterisk-config/*.conf        # optional: scenario-specific pjsip/extensions
└── *.xml                         # optional: scenario-specific SIPp scenarios
```

`scenarios/deadlock/` is the worked example and exercises every one of these.

### The override file

The base defines three services: `asterisk`, `sipp`, `load-generator`. Your override is merged
onto them — override only what differs. **Path gotcha:** with two `-f` files, relative paths
resolve from the *first* file's directory (the repo root), so write `./scenarios/<name>/...`.

**Replace an Asterisk config** — mount a different source at the same container path; the override
wins for that mount (ari/http/modules stay inherited unless you override them too):

```yaml
services:
  asterisk:
    volumes:
      - ./scenarios/myscn/asterisk-config/pjsip.conf:/etc/asterisk/pjsip.conf:ro
      - ./scenarios/myscn/asterisk-config/extensions.conf:/etc/asterisk/extensions.conf:ro
```

**Change SIP behaviour** — override the `sipp` command and mount the scenario it runs:

```yaml
  sipp:
    command: ["-sf", "/scenarios/uas-slow.xml", "-p", "5060", "-m", "1000000", "-l", "500"]
    volumes:
      - ./scenarios/myscn/uas-slow.xml:/scenarios/uas-slow.xml:ro
```

**Add a SIP actor** — declare a new service; reuse the building blocks in `sipp/`:

```yaml
  sipp-uac:
    image: ctaloi/sipp:latest
    depends_on: { asterisk: { condition: service_healthy } }
    command: ["-sf", "/scenarios/uac.xml", "-r", "10", "-d", "5000", "asterisk:5060"]
    volumes:
      - ./sipp/uac.xml:/scenarios/uac.xml:ro
```

**Choose the load driver** — either reuse the generic `ari-load.py` (just set env vars like
`ENDPOINT_PREFIX`, `CONTEXT`, `NUM_ENDPOINTS`), or mount a custom driver into the existing loadgen
image (it already has `aiohttp`) and override the command:

```yaml
  load-generator:
    environment: [CONTEXT=myscn, NUM_ENDPOINTS=5]
    volumes:
      - ./scenarios/myscn/my_driver.py:/app/my_driver.py:ro
      - ./scenarios/myscn/loadgen-run.sh:/app/loadgen-run.sh:ro
    command: ["bash", "/app/loadgen-run.sh"]
```

Keep a `load-generator` service and the runner's `--exit-code-from load-generator` plumbing works
unchanged: the whole stack stops when the driver finishes.

### Run it

```bash
docker compose -f docker-compose.yml \
  -f scenarios/<name>/docker-compose.override.yml up \
  --abort-on-container-exit --exit-code-from load-generator
```

Optionally add a `run-test.sh` (like the deadlock one) that `cd`s to the repo root, sets a
`COMPOSE=(-f ... -f ...)` array, and wraps any scenario-specific flow.

### Checklist

1. `mkdir scenarios/<name>/`
2. Write `docker-compose.override.yml`, overriding only what differs (use `./scenarios/<name>/...`).
3. Add scenario configs / SIPp XML / driver as needed; reuse `sipp/*` and `ari-load.py` where you
   can.
4. Add a `README.md`; optionally a `run-test.sh`.
5. Validate: `docker compose -f docker-compose.yml -f scenarios/<name>/docker-compose.override.yml
   config -q`.

See [`scenarios/deadlock/`](scenarios/deadlock/README.md) for a complete example.

## Testing a patched Asterisk

To validate a fix, drop a patched `asterisk*.deb` in `patch/` and build with
`--build-arg PATCH_DEB=1` (the deadlock scenario's runner does this via its
`patched` argument).

## Manual monitoring

```bash
docker logs -f loadtest-asterisk
docker exec loadtest-asterisk asterisk -rx "core show channels count"
```
