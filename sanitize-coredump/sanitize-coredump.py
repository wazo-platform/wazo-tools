#!/usr/bin/env python3
"""Extract and anonymize relevant coredump snippets for upstream bug report.

Reads ast_coredumper output files (brief.txt, info.txt) and Asterisk logs,
then produces sanitized excerpts suitable for public sharing.
"""

import re
import sys
from pathlib import Path

# Patterns to redact
PHONE_E164 = re.compile(r'\+\d{10,15}')
PHONE_NATIONAL = re.compile(r'\b0[1-9]\d{9,10}\b')
# Customer-identifying trunk/endpoint names: customer_trunk_<uuid>
CUSTOMER_TRUNK = re.compile(r'customer_trunk_[0-9a-f-]+')
# Short endpoint tokens (8-char alphanum used as PJSIP endpoint names)
# Only match when in PJSIP context to avoid false positives
PJSIP_ENDPOINT = re.compile(r'(PJSIP/)([A-Za-z0-9]{6,10})(@|/|-)')
# Customer ID values (numeric, in X-CUSTOMER-ID context)
CUSTOMER_ID_VAL = re.compile(
    r'("PJSIP_HEADER\(add,X-CUSTOMER-ID\)", value=0x[0-9a-f]+ )"[0-9]+"'
)
HEADER_VAL = re.compile(r'(data=0x[0-9a-f]+ "add", value=0x[0-9a-f]+ )"[0-9]+"')
# Bare numeric string values (customer IDs etc.) in value= arguments
VALUE_NUMERIC = re.compile(r'(value=[^ ]+ )"(\d{6,})"')
# Hostname
CUSTOMER_HOST = re.compile(r'instance\d+\.voip\d+\.customer\.com')
# Public IPs (not RFC1918, not loopback, not documentation range)
PUBLIC_IP = re.compile(
    r'\b(?!10\.)(?!172\.(?:1[6-9]|2\d|3[01])\.)(?!192\.168\.)(?!127\.)(?!192\.0\.2\.)(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b'
)
# Personal names in SIP From display names won't appear in brief.txt thread excerpts
# but guard against them anyway
SIP_DISPLAY_NAME = re.compile(r'"([A-Z][a-z]+ [A-Z][a-z]+)"')
# callerid in ast_spawn_extension
CALLERID_ARG = re.compile(r'(callerid=0x[0-9a-f]+ )"\+?\d{10,15}"')
# Context names with tenant IDs
CTX_ID = re.compile(r'ctx-ID\d+-')
# Wazo app UUIDs
WAZO_APP = re.compile(r'wazo-app-[0-9a-f-]+')
# Endpoint tokens in taskprocessor/channel names (8-char alphanum)
# e.g. pjsip/options/ABcD1234-00000040, pjsip/outsess/ABcD1234-00000040
TP_ENDPOINT = re.compile(r'(pjsip/(?:options|outsess)/)([A-Za-z0-9]{6,10})(-)')
# stasis/p:mwi:all/<ext>@<context>-<tp_hex>
# Formats: <num>@ctx-ID<num>-internal-<hex>-<hex>-<tp>
#          <num>@default-internal-<token>-<tp>
#          <num>@ctx-<token>-internal-<hex>-<hex>-<tp>
MWI_SUB = re.compile(r'(stasis/p:mwi:all/)\d+@\S+')
# Local channel with endpoint token: Local/<token>@context
LOCAL_CHAN_ENDPOINT = re.compile(r'(Local/)[A-Za-z0-9]{6,10}(@)')
# PJSIP channel names: PJSIP/<endpoint>-<hex>
PJSIP_CHAN = re.compile(r'(PJSIP/)([A-Za-z0-9]{6,10})(-[0-9a-f]+)')
# Bridge UUIDs (standalone UUID pattern in bridge/channel table)
BRIDGE_UUID = re.compile(
    r'\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b'
)
# grp-ID<num>-<uuid> group identifiers
GRP_ID = re.compile(r'grp-ID\d+-[0-9a-f-]+')
# dial_mobile data: dial_mobile,<action>,<endpoint>
DIAL_MOBILE = re.compile(r'(dial_mobile,\w+,)[A-Za-z0-9]{6,10}')
# Dial string with SIP contact URI: sip:<user>@<ip>:<port>
SIP_CONTACT = re.compile(r'sip:[A-Za-z0-9]+@[\d.]+:\d+[^)\s]*')
# wazo-dial-mobile-<uuid>
WAZO_DIAL_MOBILE = re.compile(r'wazo-dial-mobile-[0-9a-f-]+')


def anonymize_line(line: str) -> str:
    line = CUSTOMER_TRUNK.sub(
        'example_trunk_XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX', line
    )
    line = CUSTOMER_HOST.sub('sip.example.com', line)
    line = CUSTOMER_ID_VAL.sub(r'\1"XXXXXXXX"', line)
    line = HEADER_VAL.sub(r'\1"XXXXXXXX"', line)
    line = VALUE_NUMERIC.sub(r'\1"XXXXXXXX"', line)
    line = CALLERID_ARG.sub(r'\1"+XXXXXXXXXXXX"', line)
    line = PJSIP_ENDPOINT.sub(r'\1ENDPOINT\3', line)
    line = MWI_SUB.sub(r'\1XXXXXXX@XXXXX-XXXXX', line)
    line = CTX_ID.sub('ctx-IDXXXXXXXX-', line)
    line = WAZO_APP.sub('wazo-app-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX', line)
    line = TP_ENDPOINT.sub(r'\1ENDPOINT\3', line)
    line = LOCAL_CHAN_ENDPOINT.sub(r'\1ENDPOINT\2', line)
    line = PJSIP_CHAN.sub(r'\1ENDPOINT\3', line)
    line = GRP_ID.sub('grp-IDXXXXXXXX-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX', line)
    line = DIAL_MOBILE.sub(r'\1ENDPOINT', line)
    line = SIP_CONTACT.sub('sip:XXXXX@X.X.X.X:XXXXX', line)
    line = WAZO_DIAL_MOBILE.sub(
        'wazo-dial-mobile-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX', line
    )
    line = PHONE_E164.sub('+XXXXXXXXXXXX', line)
    line = PHONE_NATIONAL.sub('0XXXXXXXXXX', line)
    line = PUBLIC_IP.sub('X.X.X.X', line)
    line = BRIDGE_UUID.sub('XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX', line)
    return line


def extract_thread(lines: list[str], lwp: int) -> list[str]:
    """Extract a single thread's backtrace from brief.txt lines."""
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


def extract_system_summary(info_path: Path) -> str:
    """Extract anonymized system state summary from info.txt."""
    text = info_path.read_text()
    lines = text.splitlines()

    summary_lines = []

    # Header (version, build, uptime)
    for line in lines[2:7]:
        summary_lines.append(anonymize_line(line))

    # TaskProcessors total
    for line in lines:
        if line.startswith('TaskProcessors ('):
            summary_lines.append('')
            summary_lines.append(line)
            break

    # Table header
    for line in lines:
        if line.startswith('Processor'):
            summary_lines.append('')
            summary_lines.append(line)
            break

    # Non-sensitive taskprocessors: list individually
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
        for pfx in safe_prefixes:
            if line.startswith(pfx):
                summary_lines.append(line)
                break

    # Summarize categories with counts
    tp_lines = [
        ln for ln in lines if not ln.startswith('Processor') and not ln.startswith('!')
    ]
    categories = {
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

    summary_lines.append('')
    summary_lines.append('Taskprocessor categories (names anonymized):')
    for cat, cat_lines in categories.items():
        if not cat_lines:
            continue
        # Parse numeric columns for aggregate stats
        queued_total = 0
        max_depth_max = 0
        for cl in cat_lines:
            parts = cl.split()
            if len(parts) >= 4:
                try:
                    queued_total += int(parts[-4])
                    max_depth_max = max(max_depth_max, int(parts[-3]))
                except (ValueError, IndexError):
                    pass
        summary_lines.append(
            f'  {cat}: {len(cat_lines)} taskprocessors, '
            f'{queued_total} total in queue, '
            f'max depth {max_depth_max}'
        )

    # Channels and bridges count
    summary_lines.append('')
    for line in lines:
        if line.startswith('Channels (') or line.startswith('Bridges ('):
            summary_lines.append(line)

    return '\n'.join(summary_lines)


def extract_log_around_crash(
    log_path: Path, before: int = 5, after: int = 5
) -> list[str]:
    """Extract log lines around the crash timestamp."""
    lines = log_path.read_text().splitlines()
    # Find the freeze_check error line
    crash_idx = None
    for i, line in enumerate(lines):
        if 'res_freeze_check' in line and 'failed to acquire' in line:
            crash_idx = i
            break
    if crash_idx is None:
        return ['(res_freeze_check message not found in log)']

    start = max(0, crash_idx - before)
    end = min(len(lines), crash_idx + after + 1)
    return [anonymize_line(ln) for ln in lines[start:end]]


def extract_endpoint_config_evidence(brief_lines: list[str], lwp: int) -> list[str]:
    """Extract the key frames showing set_var -> PJSIP_HEADER code path."""
    thread = extract_thread(brief_lines, lwp)
    # Pick frames #7-#10 which show the set_var -> PJSIP_HEADER -> chan_pjsip_new path
    evidence = []
    for line in thread:
        for frame in ('#7 ', '#8 ', '#9 ', '#10 '):
            if line.startswith(frame):
                evidence.append(anonymize_line(line))
    return evidence


def main():
    base = Path(sys.argv[1]) if len(sys.argv) > 1 else Path('.')
    prefix = 'core-asterisk-<timestamp>'

    brief_path = base / f'{prefix}-brief.txt'
    info_path = base / f'{prefix}-info.txt'
    log_path = base / 'instance-1-logs' / 'instance-1-asterisk-logs' / 'full'

    brief_lines = brief_path.read_text().splitlines()

    # Thread LWPs from the crash analysis
    # Thread 1158 (LWP 834925) - Dial thread holding channel lock
    # Thread 780 (LWP 816915) - ARI thread holding container lock
    dial_thread = extract_thread(brief_lines, 834925)
    ari_thread = extract_thread(brief_lines, 816915)

    output = []
    output.append('# Sanitized coredump excerpts for upstream bug report')
    output.append('')

    # Endpoint set_var evidence
    output.append('## Evidence of endpoint set_var configuration')
    output.append('')
    output.append(
        'The stack trace shows `PJSIP_HEADER(add,X-CUSTOMER-ID)` being called from'
    )
    output.append(
        '`chan_pjsip_new()` via the endpoint `channel_vars` loop (set_var config):'
    )
    output.append('```')
    for line in extract_endpoint_config_evidence(brief_lines, 834925):
        output.append(line)
    output.append('```')
    output.append('')

    # Deadlock threads
    output.append(
        '## Thread A: Dial / chan_pjsip_new — holds channel lock, waiting on serializer'
    )
    output.append('```')
    for line in dial_thread:
        output.append(anonymize_line(line))
    output.append('```')
    output.append('')
    output.append(
        '## Thread B: ARI GET channel variable — holds container lock, '
        'waiting on channel lock'
    )
    output.append('```')
    for line in ari_thread:
        output.append(anonymize_line(line))
    output.append('```')
    output.append('')

    # Log excerpt
    if log_path.exists():
        output.append('## Asterisk log around crash time')
        output.append('```')
        for line in extract_log_around_crash(log_path):
            output.append(line)
        output.append('```')
        output.append('')

    # System state
    output.append('## System state at crash')
    output.append('```')
    output.append(extract_system_summary(info_path))
    output.append('```')

    result = '\n'.join(output)
    out_path = base / 'sanitized-coredump-excerpts.md'
    out_path.write_text(result + '\n')
    print(f'Written to {out_path}')

    # Anonymized info.txt (full structure preserved)
    info_lines = info_path.read_text().splitlines()
    anon_info = '\n'.join(anonymize_line(ln) for ln in info_lines)
    anon_info_path = base / 'sanitized-info.txt'
    anon_info_path.write_text(anon_info + '\n')
    print(f'Written to {anon_info_path}')


if __name__ == '__main__':
    main()
