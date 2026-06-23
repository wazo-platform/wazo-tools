# sanitize-coredump

Extract and anonymize relevant Asterisk coredump snippets so they can be shared
in a public/upstream bug report without leaking customer-identifying data
(phone numbers, public IPs, hostnames, endpoint/trunk names, tenant UUIDs, ...).

It reads [`ast_coredumper`](https://github.com/asterisk/asterisk/blob/master/contrib/scripts/ast_coredumper)
output (`*-brief.txt`, `*-info.txt`) together with the Asterisk `full` log,
redacts sensitive tokens line-by-line, and writes:

- `sanitized-coredump-excerpts.md` — a curated report (deadlock threads,
  endpoint config evidence, log around the crash, system-state summary)
- `sanitized-info.txt` — the full `info.txt` with the same redaction applied

## Status: incident-specific template

This script was written for a specific incident (the 20XX-XX-XX customer upgrade
deadlock) and is **not** a general-purpose tool. Several things are hardcoded
and must be adapted before reuse:

- `prefix` — the `core-asterisk-<timestamp>` filename prefix (in `main()`)
- the thread LWPs of interest (`834925`, `816915`)
- the crash marker used to locate the log excerpt (`res_freeze_check ...
  failed to acquire`)
- customer-specific redaction patterns (`customer_trunk_*`,
  `instance*.voip*.customer.com`)

Keep it as a starting point: copy it, adjust the patterns and the extraction
logic to the coredump at hand, then run it.

## Usage

```sh
./sanitize-coredump.py [DIR]
```

`DIR` defaults to the current directory and must contain the
`ast_coredumper` output files (and optionally the
`instance-1-logs/instance-1-asterisk-logs/full` log).

Requires Python 3 only (standard library).

## Tests

`test_sanitize_coredump.py` asserts that every redaction pattern actually fires
on representative input — for a sanitizer a silent non-firing rule is a leak.
Run with `pytest` from this directory.

## Generalizing beyond this incident

The reusable core here is the line sanitizer. Turning it into a general-purpose
tool (config-driven customer literals, per-country phone handling, consistent
pseudonymization, a CLI) is designed in [`GENERALIZATION-PLAN.md`](./GENERALIZATION-PLAN.md).
