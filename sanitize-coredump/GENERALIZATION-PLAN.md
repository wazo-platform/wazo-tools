# sanitize-coredump — generalization plan

`sanitize-coredump.py` is currently an incident-specific template (the
2026-02-04 bonline deadlock). This document captures how to turn its reusable
core into a general-purpose sanitizer, to be implemented later. It is the
design record only — no code here.

## Guiding principle

For a sanitizer the cardinal failure is the **false negative (a leak)**, not
the false positive — publishing sanitized output is irreversible. Therefore:

- Bias generic patterns toward **over**-redaction. Over-redacting hurts
  readability (recoverable); under-redacting leaks (fatal).
- **Every pattern needs a test proving it fires** on representative input.
  Tests are the safety property, not DoD box-ticking. A redaction that looks
  present but silently never runs is the worst case — exactly the
  `SIP_DISPLAY_NAME` dead-code bug already fixed in this codebase.
- Any reverse-mapping / de-anonymization data must stay **out of published
  output by construction**.

## Decomposition

The script conflates two concerns on different reuse axes:

- **(A) Line sanitization** — `anonymize_line` + the pattern set. *Reusable.*
  This becomes the tool.
- **(B) Incident report extraction** — the deadlock narrative, frame #7–10
  picking, the `res_freeze_check` marker, specific thread LWPs, hardcoded
  dump paths. *Inherently per-incident.* Keep this out of the shared tool;
  leave it as a documented template or a throwaway per-incident script.

## Pattern buckets

### Customer-specific — must come from config, cannot be inferred

- `CUSTOMER_TRUNK` (`bonline_trunk_*`)
- `CUSTOMER_HOST` (`instance*.voip*.bonline.com`)
- `CUSTOMER_ID_VAL` / `HEADER_VAL` (the `X-CUSTOMER-ID` header)

Shape-based patterns structurally cannot know a brand string, tenant slug, or
vanity domain. The backbone of the generalized tool is therefore:
**built-in structural ruleset + mandatory caller-supplied literals**
(brand name, domain(s), tenant id(s), custom header names) redacted everywhere.

### Incident-specific — drop from the shared tool

- hardcoded `prefix` timestamp, thread LWPs, frame-range selection
- `res_freeze_check ... failed to acquire` log marker
- hardcoded `instance-1-logs/.../full` path
- the Thread A / Thread B report structure

At most these become CLI parameters (`--extract-thread LWP`,
`--context-marker REGEX --before/--after`), not baked-in logic.

### Generic / reusable — the built-in default ruleset

- `PUBLIC_IP` (keep RFC1918 / loopback / TEST-NET exclusions), `SIP_CONTACT`,
  `BRIDGE_UUID`, `PHONE_E164`
- Wazo/Asterisk structural identifiers: `WAZO_APP`, `WAZO_DIAL_MOBILE`,
  `DIAL_MOBILE`, `MWI_SUB`, `GRP_ID`, `CTX_ID`, and the endpoint/channel
  token patterns (`PJSIP_*`, `TP_ENDPOINT`, `LOCAL_CHAN_ENDPOINT`)
- the `[A-Za-z0-9]{6,10}` endpoint heuristic is acceptable here: it is
  anchored to channel-name contexts and errs toward redacting
- `extract_thread` and `extract_system_summary` are generic and worth keeping

## Open design items

### Phone numbers need context-aware / per-country handling

`PHONE_NATIONAL` is FR-shaped and currently misses canonical 10-digit national
numbers (tracked by an `xfail` test). A single national regex is **not**
generic — number plans differ per country (length, leading digits, trunk
prefix). Options to evaluate:

- per-country pattern set selectable via config (`PHONE_NATIONAL_FR`,
  `PHONE_NATIONAL_UK`, ...), and/or
- a context-aware approach keying on SIP/dialplan context rather than the bare
  digit shape, and/or
- a vetted library (e.g. `phonenumbers`) for detection.

Until resolved, rely on `PHONE_E164` plus the `callerid`/`value=` context
patterns; do not assume bare national numbers are caught.

### Consistent pseudonymization (preserve correlation)

Blanket `XXXX` destroys the correlation an analyst needs (e.g. "the same
endpoint appears in Thread A and Thread B"). Replace with stable per-token
placeholders so structure survives while identity is removed.

- Use **counter-based** tokens (`ENDPOINT_1`, `TRUNK_2`), **not** salted
  hashes — a phone-number / numeric-id space is trivially brute-forced, and a
  leaked salt de-anonymizes everything.
- Optional private reverse-mapping output, never part of the published file.

### CLI shape

- argparse; act as a stream filter (stdin → stdout) and/or take input files
- `--config FILE` for the mandatory customer literals + per-country phone set
- optional extraction helpers: `--extract-thread LWP` (repeatable),
  `--context-marker REGEX --before N --after N`
