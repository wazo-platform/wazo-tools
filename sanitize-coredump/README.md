# sanitize-coredump

Sanitize Asterisk coredump / log excerpts so they can be shared in a
public/upstream bug report without leaking customer-identifying data (phone
numbers, public IPs, hostnames, endpoint/trunk names, tenant ids, UUIDs, ...).

It works on [`ast_coredumper`](https://github.com/asterisk/asterisk/blob/master/contrib/scripts/ast_coredumper)
output (`*-brief.txt`, `*-info.txt`) and Asterisk logs.

## How it redacts

Two layers:

- a **built-in structural ruleset** for generic Asterisk/Wazo identifiers and
  PII (endpoints, channels, MWI subscriptions, tenant/group ids, UUIDs, SIP
  contacts, E.164 phone numbers, public IPv4/IPv6 addresses, ...) — always on
  (loopback/private IPv4 and loopback/link-local/ULA IPv6 are preserved);
- **caller-supplied literals** from `--config` (brand names, vanity domains,
  tenant slugs, custom SIP headers). These cannot be inferred from shape alone,
  so without a config they are **not** redacted — the tool warns loudly on
  stderr when run without one (pass `--structural-only` to acknowledge).

Sensitive values are replaced with stable counter-based tokens (`ENDPOINT_1`,
`UUID_2`, ...) rather than blanked out, so correlation survives sanitization:
the same endpoint keeps the same token across threads. The reverse
token→value map (the de-anonymization key) is written **only** to
`--mapping-out`, never to the sanitized output — keep it private.

## Usage

```sh
# sanitize a file or stdin (stream filter)
./sanitize-coredump.py --config customer.json filter core-info.txt > clean-info.txt
cat core-brief.txt | ./sanitize-coredump.py --structural-only filter

# extract & sanitize specific thread backtraces by LWP
./sanitize-coredump.py --config customer.json thread core-brief.txt --lwp 834925 --lwp 816915

# extract & sanitize log lines around a marker
./sanitize-coredump.py --config customer.json log full \
    --marker 'res_freeze_check.*failed to acquire' --before 5 --after 5

# sanitized system-state summary from info.txt
./sanitize-coredump.py --config customer.json summary core-info.txt

# keep the de-anonymization key for your own later reference
./sanitize-coredump.py --config customer.json --mapping-out key.json filter core-info.txt
```

Global options: `--config FILE`, `--mapping-out FILE`, `--structural-only`,
`-o/--output FILE`. Requires Python 3 only (standard library).

### Config file (JSON)

```json
{
  "literals": ["acmecorp"],
  "domains": ["instance1.voip2.acmecorp.com"],
  "headers": ["X-CUSTOMER-ID"],
  "phone_country": "FR",
  "patterns": [{"pattern": "secret-\\d+", "replacement": "REDACTED"}]
}
```

- `literals` / `domains` — strings redacted everywhere (consistent tokens).
- `headers` — the value of these PJSIP headers (in gdb arg dumps) is redacted.
- `phone_country` — opt into a per-country national-number pattern (`FR`,
  `UK`). National numbers are otherwise not caught; see design notes below.
- `patterns` — raw regex→replacement escape hatch, applied last.

## Tests

`test_sanitize_coredump.py` asserts that every redaction pattern actually fires
on representative input (a silent non-firing rule is a leak), plus token
consistency/distinctness, idempotency (generated tokens are never re-matched),
config-literal redaction, and the CLI's config-gate warning and mapping
handling. Run with `pytest` from this directory.

## Design notes & open items

- **National phone numbers** are redacted only when `phone_country` is set,
  because a single national regex is not generic — number plans differ per
  country (length, leading digits, trunk prefix). E.164 numbers and the
  `callerid`/`value=` context rules are always covered; do not assume bare
  national numbers are caught otherwise. Future options: more per-country
  patterns, context-aware detection, or a vetted library (`phonenumbers`).
- **Pseudonymization is counter-based, not hashed**, on purpose: a
  phone-number / numeric-id space is trivially brute-forced and a leaked salt
  would de-anonymize everything. The reverse map stays out of published output
  by construction (only `--mapping-out`).
- **Robust to real coredump data**: non-UTF-8 bytes are replaced rather than
  crashing the run; configured `domains` also match gdb-truncated fragments
  (`instance1.voip3.bo"...`); UUID-shaped ids are matched with a loose tail so
  non-standard/truncated trunk UUIDs are caught. Verified against real coredumps
  from several deployments (RFC 5737 `192.0.2.0/24` documentation IPs are kept).
- **Endpoint/trunk/context names** are redacted structurally in the standard
  Asterisk positions — `PJSIP/<ep>`, `pjsip/{options,outsess,outreg}/<ep>`,
  `Local/<ep>`, `stasis/p:endpoint:PJSIP/<ep>`, `<slug>_trunk_<id>`,
  `ctx-<tenant>` — and cover names that are hex UUIDs *or* human/business
  names (e.g. `dstny_trunk_ChapelleTrucksServices`, `ALLIANZ_ANNE_BAILLET_UNYC`,
  `ctx-CABINETOPH`). Standard Wazo names with underscores (`wazo_wait`,
  `WAZO_USER`) and C/C++ backtrace symbols (`ast_channel_lock`, `basic_string`)
  are deliberately **not** matched — underscore-bearing names are only redacted
  in those anchored contexts, never globally.
- **Deployment-specific naming** that appears outside the anchored contexts
  (e.g. an endpoint name after `@` in a dial string, where it shares the
  position with `@wazo_wait`) cannot be inferred structurally. Redact it with a
  `--config` `patterns` entry keyed on the deployment's stable marker, e.g.
  `{"patterns": [{"pattern": "[A-Za-z0-9_]+_UNYC", "replacement": "ENDPOINT"}]}`.

The earlier incident-specific report builder (the 20XX-XX-XX customer deadlock
narrative, frame selection, `res_freeze_check` marker) was intentionally
dropped here; it remains in git history (commits `d2dad71` / `f8e7885`).
