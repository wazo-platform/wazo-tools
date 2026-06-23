#!/usr/bin/env python3
"""Sanitize Asterisk coredump / log excerpts for public sharing.

Redacts PII and customer-identifying tokens (phone numbers, public IPs,
hostnames, endpoint/trunk names, tenant ids, UUIDs, ...) from ast_coredumper
output and Asterisk logs before they go into an upstream/public bug report.

Two layers of redaction:

- a built-in structural ruleset for generic Asterisk/Wazo identifiers and PII
  (always on);
- caller-supplied literals from --config (brand names, vanity domains, tenant
  ids, custom SIP headers) which CANNOT be inferred from shape alone.

Sensitive values are replaced with stable counter-based tokens (ENDPOINT_1,
UUID_2, ...) so that correlation survives sanitization — the same endpoint
keeps the same token across threads — while identity is removed. The reverse
mapping is the de-anonymization key; it is written only to --mapping-out,
never to the sanitized output.

The original incident-specific report builder (deadlock narrative, frame
selection, res_freeze_check marker) was intentionally dropped in this
generalization; it remains in git history (commits d2dad71 / f8e7885).
"""

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Callable

# A redaction rule: a compiled pattern and a replacement (str or match->str).
Replacement = Callable[[re.Match], str] | str
Rule = tuple[re.Pattern, Replacement]

# Per-country national number plans (opt-in via config phone_country). A single
# national regex is not generic; bare national numbers are NOT redacted unless a
# country is configured. Rely otherwise on PHONE_E164 and the callerid/value=
# context rules.
NATIONAL_PHONE_PATTERNS = {
    'FR': re.compile(r'\b0[1-9]\d{8}\b'),
}


class Pseudonymizer:
    """Maps each distinct sensitive value to a stable counter-based token.

    Counter-based (not hashed) on purpose: a phone-number / numeric-id space is
    trivially brute-forced, and a leaked salt would de-anonymize everything.
    """

    def __init__(self) -> None:
        self._counters: dict[str, int] = {}
        self._tokens: dict[tuple[str, str], str] = {}

    def token(self, tag: str, value: str) -> str:
        key = (tag, value)
        token = self._tokens.get(key)
        if token is None:
            count = self._counters.get(tag, 0) + 1
            self._counters[tag] = count
            token = f'{tag}_{count}'
            self._tokens[key] = token
        return token

    def mapping(self) -> dict[str, str]:
        """Reverse map token -> original value (the de-anonymization key)."""
        return {token: value for (_, value), token in self._tokens.items()}


class Sanitizer:
    def __init__(
        self,
        pseudo: Pseudonymizer | None = None,
        literals: tuple[str, ...] = (),
        domains: tuple[str, ...] = (),
        headers: tuple[str, ...] = (),
        extra_patterns: tuple[tuple[str, str], ...] = (),
        phone_country: str | None = None,
    ) -> None:
        self.pseudo = pseudo or Pseudonymizer()
        self._rules = self._build_rules(
            literals, domains, headers, extra_patterns, phone_country
        )

    def _build_rules(
        self,
        literals: tuple[str, ...],
        domains: tuple[str, ...],
        headers: tuple[str, ...],
        extra_patterns: tuple[tuple[str, str], ...],
        phone_country: str | None,
    ) -> list[Rule]:
        tok = self.pseudo.token
        rules: list[Rule] = []

        # --- caller-supplied literals (longest first to avoid partial shadowing)
        for domain in sorted(set(domains), key=len, reverse=True):
            rules.append(
                (re.compile(re.escape(domain)), lambda m: tok('HOST', m.group(0)))
            )
        for literal in sorted(set(literals), key=len, reverse=True):
            rules.append(
                (re.compile(re.escape(literal)), lambda m: tok('LITERAL', m.group(0)))
            )
        for header in headers:
            rx = re.compile(
                r'("PJSIP_HEADER\([^,]+,'
                + re.escape(header)
                + r'\)", value=0x[0-9a-f]+ )"([^"]*)"'
            )
            rules.append(
                (rx, lambda m: m.group(1) + '"' + tok('HEADERVAL', m.group(2)) + '"')
            )

        # --- built-in structural ruleset (order is load-bearing) ---
        rules += [
            (
                re.compile(r'"([A-Z][a-z]+ [A-Z][a-z]+)"'),
                lambda m: '"' + tok('NAME', m.group(1)) + '"',
            ),
            (
                re.compile(r'(callerid=0x[0-9a-f]+ )"\+?(\d{10,15})"'),
                lambda m: m.group(1) + '"' + tok('PHONE', m.group(2)) + '"',
            ),
            (
                re.compile(r'(value=[^ ]+ )"(\d{6,})"'),
                lambda m: m.group(1) + '"' + tok('CUSTID', m.group(2)) + '"',
            ),
            (
                re.compile(r'(PJSIP/)([A-Za-z0-9]{6,10})(@|/|-)'),
                lambda m: m.group(1) + tok('ENDPOINT', m.group(2)) + m.group(3),
            ),
            (
                re.compile(r'(stasis/p:mwi:all/)(\d+@\S+)'),
                lambda m: m.group(1) + tok('MWISUB', m.group(2)),
            ),
            (
                re.compile(r'(ctx-ID)(\d+)'),
                lambda m: m.group(1) + tok('TENANT', m.group(2)),
            ),
            (
                re.compile(r'(wazo-app-)([0-9a-f-]+)'),
                lambda m: m.group(1) + tok('UUID', m.group(2)),
            ),
            (
                re.compile(r'(pjsip/(?:options|outsess)/)([A-Za-z0-9]{6,10})(-)'),
                lambda m: m.group(1) + tok('ENDPOINT', m.group(2)) + m.group(3),
            ),
            (
                re.compile(r'(Local/)([A-Za-z0-9]{6,10})(@)'),
                lambda m: m.group(1) + tok('ENDPOINT', m.group(2)) + m.group(3),
            ),
            (
                re.compile(r'(PJSIP/)([A-Za-z0-9]{6,10})(-[0-9a-f]+)'),
                lambda m: m.group(1) + tok('ENDPOINT', m.group(2)) + m.group(3),
            ),
            (
                re.compile(r'grp-ID\d+-[0-9a-f-]+'),
                lambda m: tok('GRP', m.group(0)),
            ),
            (
                re.compile(r'(dial_mobile,\w+,)([A-Za-z0-9]{6,10})\b'),
                lambda m: m.group(1) + tok('ENDPOINT', m.group(2)),
            ),
            (
                re.compile(r'sip:[A-Za-z0-9]+@[\d.]+:\d+[^)\s]*'),
                lambda m: tok('CONTACT', m.group(0)),
            ),
            (
                re.compile(r'wazo-dial-mobile-[0-9a-f-]+'),
                lambda m: tok('WAZODIAL', m.group(0)),
            ),
        ]

        if phone_country:
            national = NATIONAL_PHONE_PATTERNS.get(phone_country)
            if national is None:
                raise ValueError(
                    f'unknown phone_country {phone_country!r}; known: '
                    f'{sorted(NATIONAL_PHONE_PATTERNS)}'
                )
            rules.append((national, lambda m: tok('PHONE', m.group(0))))

        rules += [
            (re.compile(r'\+\d{10,15}'), lambda m: tok('PHONE', m.group(0))),
            (
                re.compile(
                    r'\b(?!10\.)(?!172\.(?:1[6-9]|2\d|3[01])\.)(?!192\.168\.)'
                    r'(?!127\.)(?!192\.0\.2\.)'
                    r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b'
                ),
                lambda m: tok('IP', m.group(1)),
            ),
            (
                re.compile(
                    r'\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-'
                    r'[0-9a-f]{4}-[0-9a-f]{12}\b'
                ),
                lambda m: tok('UUID', m.group(0)),
            ),
        ]

        # --- caller-supplied raw regex escape hatch (applied last) ---
        rules += [(re.compile(pat), repl) for pat, repl in extra_patterns]

        return rules

    def line(self, text: str) -> str:
        for pattern, repl in self._rules:
            text = pattern.sub(repl, text)
        return text


def anonymize_line(text: str) -> str:
    """Structural-only sanitization of a single line (no caller config)."""
    return Sanitizer().line(text)


def extract_thread(lines: list[str], lwp: int) -> list[str]:
    """Extract a single thread's backtrace from brief.txt lines by LWP."""
    result = []
    in_thread = False
    for line in lines:
        if f'LWP {lwp})' in line and line.startswith('Thread '):
            in_thread = True
        elif in_thread and line.startswith('Thread '):
            break
        if in_thread:
            result.append(line)
    return result


def extract_system_summary(info_path: Path, sanitizer: Sanitizer) -> str:
    """Extract a sanitized system-state summary from an info.txt."""
    lines = info_path.read_text().splitlines()
    summary: list[str] = []

    for line in lines[2:7]:  # header: version, build, uptime
        summary.append(sanitizer.line(line))

    for line in lines:
        if line.startswith('TaskProcessors ('):
            summary += ['', line]
            break

    for line in lines:
        if line.startswith('Processor'):
            summary += ['', line]
            break

    safe_prefixes = (
        'app_voicemail',
        'ast_msg_queue',
        'CCSS_core',
        'dns_system',
        'hep_queue_tp',
        'iax2_transmit',
        'pjsip/distributor',
        'pjsip/exten_state',
        'pjsip/messaging',
        'pjsip/mwi',
    )
    for line in lines:
        if line.startswith(safe_prefixes):
            summary.append(line)

    tp_lines = [
        ln for ln in lines if not ln.startswith('Processor') and not ln.startswith('!')
    ]
    categories: dict[str, list[str]] = {
        'pjsip/options': [],
        'pjsip/outsess': [],
        'stasis/m:ari:application': [],
        'stasis/p:mwi:all': [],
        'stasis (other)': [],
    }
    for line in tp_lines:
        stripped = line.strip()
        if stripped.startswith('pjsip/options/'):
            categories['pjsip/options'].append(stripped)
        elif stripped.startswith('pjsip/outsess/'):
            categories['pjsip/outsess'].append(stripped)
        elif stripped.startswith('stasis/m:ari:application/'):
            categories['stasis/m:ari:application'].append(stripped)
        elif stripped.startswith('stasis/p:mwi:all/'):
            categories['stasis/p:mwi:all'].append(stripped)
        elif stripped.startswith('stasis/'):
            categories['stasis (other)'].append(stripped)

    summary += ['', 'Taskprocessor categories (names anonymized):']
    for cat, cat_lines in categories.items():
        if not cat_lines:
            continue
        queued_total = 0
        max_depth = 0
        for cl in cat_lines:
            parts = cl.split()
            if len(parts) >= 4:
                try:
                    queued_total += int(parts[-4])
                    max_depth = max(max_depth, int(parts[-3]))
                except (ValueError, IndexError):
                    pass
        summary.append(
            f'  {cat}: {len(cat_lines)} taskprocessors, '
            f'{queued_total} total in queue, max depth {max_depth}'
        )

    summary.append('')
    for line in lines:
        if line.startswith('Channels (') or line.startswith('Bridges ('):
            summary.append(line)

    return '\n'.join(summary)


def load_config(path: Path) -> dict:
    config = json.loads(path.read_text())
    if not isinstance(config, dict):
        raise ValueError('config must be a JSON object')
    return config


def build_sanitizer(config: dict | None) -> Sanitizer:
    config = config or {}
    extra = tuple(
        (entry['pattern'], entry['replacement']) for entry in config.get('patterns', [])
    )
    return Sanitizer(
        literals=tuple(config.get('literals', [])),
        domains=tuple(config.get('domains', [])),
        headers=tuple(config.get('headers', [])),
        extra_patterns=extra,
        phone_country=config.get('phone_country'),
    )


def _emit(text: str, output: str | None) -> None:
    if output:
        Path(output).write_text(text + '\n' if text else '')
    else:
        sys.stdout.write(text + '\n' if text else '')


def _cmd_filter(args: argparse.Namespace, sanitizer: Sanitizer) -> None:
    files = args.files or ['-']
    out_lines = []
    for name in files:
        handle = sys.stdin if name == '-' else open(name, encoding='utf-8')
        try:
            for line in handle:
                out_lines.append(sanitizer.line(line.rstrip('\n')))
        finally:
            if handle is not sys.stdin:
                handle.close()
    _emit('\n'.join(out_lines), args.output)


def _cmd_thread(args: argparse.Namespace, sanitizer: Sanitizer) -> None:
    lines = Path(args.brief).read_text().splitlines()
    out: list[str] = []
    for lwp in args.lwp:
        out += [sanitizer.line(line) for line in extract_thread(lines, lwp)]
    _emit('\n'.join(out), args.output)


def _cmd_log(args: argparse.Namespace, sanitizer: Sanitizer) -> None:
    lines = Path(args.logfile).read_text().splitlines()
    marker = re.compile(args.marker)
    idx = next((i for i, line in enumerate(lines) if marker.search(line)), None)
    if idx is None:
        sys.exit(f'marker {args.marker!r} not found in {args.logfile}')
    start = max(0, idx - args.before)
    end = min(len(lines), idx + args.after + 1)
    _emit('\n'.join(sanitizer.line(line) for line in lines[start:end]), args.output)


def _cmd_summary(args: argparse.Namespace, sanitizer: Sanitizer) -> None:
    _emit(extract_system_summary(Path(args.info), sanitizer), args.output)


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=(__doc__ or '').splitlines()[0])
    parser.add_argument('--config', type=Path, help='JSON config of caller literals')
    parser.add_argument(
        '--mapping-out',
        type=Path,
        help='write the token->value de-anonymization key here (keep private)',
    )
    parser.add_argument(
        '--structural-only',
        action='store_true',
        help='acknowledge running without caller literals (suppresses warning)',
    )
    parser.add_argument('-o', '--output', help='write to file instead of stdout')

    sub = parser.add_subparsers(dest='cmd', required=True)

    p_filter = sub.add_parser('filter', help='sanitize lines from files or stdin')
    p_filter.add_argument('files', nargs='*', help='input files (default: stdin)')
    p_filter.set_defaults(func=_cmd_filter)

    p_thread = sub.add_parser('thread', help='extract & sanitize thread(s) by LWP')
    p_thread.add_argument('brief', help='ast_coredumper brief.txt')
    p_thread.add_argument(
        '--lwp',
        type=int,
        action='append',
        required=True,
        help='thread LWP (repeatable)',
    )
    p_thread.set_defaults(func=_cmd_thread)

    p_log = sub.add_parser('log', help='extract & sanitize log lines around a marker')
    p_log.add_argument('logfile')
    p_log.add_argument(
        '--marker', required=True, help='regex marking the line of interest'
    )
    p_log.add_argument('--before', type=int, default=5)
    p_log.add_argument('--after', type=int, default=5)
    p_log.set_defaults(func=_cmd_log)

    p_summary = sub.add_parser('summary', help='sanitized system-state summary')
    p_summary.add_argument('info', help='ast_coredumper info.txt')
    p_summary.set_defaults(func=_cmd_summary)

    return parser


def main(argv: list[str] | None = None) -> None:
    args = _build_parser().parse_args(argv)
    config = load_config(args.config) if args.config else None

    has_literals = bool(
        config
        and (config.get('literals') or config.get('domains') or config.get('headers'))
    )
    if not has_literals and not args.structural_only:
        print(
            'WARNING: no caller literals configured (--config). Brand names, '
            'vanity hostnames, tenant slugs and custom header values will NOT '
            'be redacted — only generic structural patterns. Pass --config or '
            '--structural-only to acknowledge.',
            file=sys.stderr,
        )

    sanitizer = build_sanitizer(config)
    args.func(args, sanitizer)

    if args.mapping_out:
        args.mapping_out.write_text(json.dumps(sanitizer.pseudo.mapping(), indent=2))


if __name__ == '__main__':
    main()
