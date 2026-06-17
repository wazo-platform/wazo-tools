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

## Building a scenario

A scenario layers a Compose override on top of the base stack and may add its own
driver, SIPp scenarios, or Asterisk config. Run it from this directory:

```bash
docker compose -f docker-compose.yml \
  -f scenarios/<name>/docker-compose.override.yml up \
  --abort-on-container-exit --exit-code-from load-generator
```

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
