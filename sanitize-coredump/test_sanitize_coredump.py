"""Tests for the sanitize-coredump sanitizer.

For a sanitizer the cardinal failure is the false negative (a leak), so every
pattern gets a case asserting the sensitive token does not survive in the
output. The module filename has a dash, so it is loaded via importlib.
"""

import importlib.util
import json
from pathlib import Path

import pytest

_MODULE_PATH = Path(__file__).parent / 'sanitize-coredump.py'
_spec = importlib.util.spec_from_file_location('sanitize_coredump', _MODULE_PATH)
assert _spec is not None and _spec.loader is not None
_module = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_module)

anonymize_line = _module.anonymize_line
Sanitizer = _module.Sanitizer
extract_system_summary = _module.extract_system_summary
main = _module.main


# pytest.param(input line, substring that MUST NOT survive, id=pattern name).
# Customer-specific literals (brand/domain) are covered separately, since they
# are config-driven and not part of the default structural ruleset.
REDACTION_CASES = [
    pytest.param('caller +33612345678 dialed', '+33612345678', id='phone E164'),
    pytest.param(
        'from 0612345678 here',
        '0612345678',
        id='phone national',
        marks=pytest.mark.xfail(
            reason='national numbers need per-country config (phone_country); '
            'not redacted by default (see README design notes)',
            strict=True,
        ),
    ),
    pytest.param(
        '"PJSIP_HEADER(add,X-CUSTOMER-ID)", value=0x7f001234 "9876543"',
        '9876543',
        id='customer-id header value',
    ),
    pytest.param(
        'data=0x55 "add", value=0x66 "789012"', '789012', id='header add value'
    ),
    pytest.param('foo value=0x55 "1234567" bar', '1234567', id='bare numeric value'),
    pytest.param('callerid=0x7f0012 "+33612345678"', '+33612345678', id='callerid arg'),
    pytest.param('From: "John Smith" <sip:...>', 'John Smith', id='sip display name'),
    pytest.param('channel PJSIP/ABcD1234@ctx active', 'ABcD1234', id='pjsip endpoint'),
    pytest.param('PJSIP/ABcD1234-0000abcd hung up', 'ABcD1234', id='pjsip channel'),
    pytest.param(
        'dialstring PJSIP/ysy7AakU&PJSIP/other',
        'ysy7AakU',
        id='pjsip endpoint before &',
    ),
    pytest.param(
        'Local/ABcD1234@default-0001', 'ABcD1234', id='local channel endpoint'
    ),
    pytest.param(
        'pjsip/options/ABcD1234-00000040', 'ABcD1234', id='taskprocessor endpoint'
    ),
    pytest.param('dial_mobile,join,ABcD1234', 'ABcD1234', id='dial_mobile endpoint'),
    pytest.param(
        'stasis/p:mwi:all/1001@ctx-ID3-internal-aa-bb',
        '1001@ctx',
        id='mwi subscription',
    ),
    pytest.param('in ctx-ID42-internal', 'ctx-ID42', id='context tenant id'),
    pytest.param(
        'ctx-CABINETOPH-internal-3b554589-908c up',
        'CABINETOPH',
        id='context business name',
    ),
    pytest.param('wazo-app-ab12cd34-ef56 started', 'ab12cd34', id='wazo app uuid'),
    pytest.param('wazo-dial-mobile-ab12cd34-ef56', 'ab12cd34', id='wazo dial mobile'),
    pytest.param('grp-ID5-ab12cd34-ef56', 'ab12cd34', id='group id'),
    pytest.param(
        'bridge 12345678-1234-1234-1234-123456789abc',
        '12345678-1234-1234-1234-123456789abc',
        id='bridge uuid',
    ),
    pytest.param(
        'ref 0a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4 seen',
        '0a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4',
        id='truncated trunk uuid (9-hex tail)',
    ),
    pytest.param(
        'branch=z9hG4bKPj0a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4678;alias',
        '0a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4678',
        id='uuid glued to SIP Via branch prefix',
    ),
    pytest.param(
        'contact sip:user123@1.2.3.4:5060;ob', 'user123', id='sip contact uri'
    ),
    pytest.param('peer 8.8.8.8 reachable', '8.8.8.8', id='public ip'),
    pytest.param(
        'peer 2606:4700:4700::1111 up',
        '2606:4700:4700::1111',
        id='public ipv6 compressed',
    ),
    pytest.param(
        'addr 2a00:1450:4007:80f::200e end',
        '2a00:1450:4007:80f::200e',
        id='public ipv6',
    ),
    pytest.param('sock ::ffff:8.8.8.8 bound', '8.8.8.8', id='ipv4-mapped ipv6'),
    pytest.param(
        'id A1B2C3D4-E5F6-7A8B-9C0D-E1F2A3B4C5D6 seen',
        'A1B2C3D4-E5F6-7A8B-9C0D-E1F2A3B4C5D6',
        id='uppercase-hex uuid',
    ),
    pytest.param(
        'PJSIP/customer_trunk_DEADBEEF-1111-2222-3333-44445555 up',
        'DEADBEEF',
        id='uppercase-hex trunk id',
    ),
]


@pytest.mark.parametrize('line,forbidden', REDACTION_CASES)
def test_pattern_redacts_sensitive_token(line, forbidden):
    assert forbidden not in anonymize_line(line)


def test_private_ip_is_preserved():
    result = anonymize_line('internal peer 10.42.0.1 and 192.168.1.5')
    assert '10.42.0.1' in result
    assert '192.168.1.5' in result


def test_loopback_ip_is_preserved():
    assert '127.0.0.1' in anonymize_line('bound to 127.0.0.1:5060')


def test_ipv6_loopback_and_link_local_preserved():
    assert '::1' in anonymize_line('bind [::1]:5060')
    assert 'fe80::1' in anonymize_line('iface fe80::1 up')


def test_ipv6_rule_does_not_corrupt_cpp_symbols_or_timestamps():
    # gdb backtraces are full of ns::Sym tokens and HH:MM:SS timestamps
    assert anonymize_line('frame ast::unload_resource') == 'frame ast::unload_resource'
    assert anonymize_line('cafe::babe handler') == 'cafe::babe handler'
    assert anonymize_line('reload at 11:20:54 done') == 'reload at 11:20:54 done'


def test_sip_contact_with_ipv6_collapses_to_single_token():
    out = anonymize_line('c sip:user42@[2606:4700::1111]:5060;ob done')
    assert 'user42' not in out  # user redacted, not just the address
    assert '2606:4700' not in out
    assert out.count('CONTACT_') == 1  # one token, not a half-redacted URI
    assert 'IP_' not in out  # not split by the standalone IPv6 rule


def test_summary_sanitizes_safe_prefix_lines(tmp_path):
    # the safe_prefix taskprocessor lines must be sanitized, not emitted raw
    info = tmp_path / 'info.txt'
    info.write_text(
        '\n'.join(
            [
                'header0',
                'header1',
                'Asterisk 22 built',
                'started',
                'reload',
                '',
                '',
                'TaskProcessors (1):',
                '',
                'Processor   Processed',
                'pjsip/messaging  a1b2c3d4-e5f6-7a8b-9c0d-112233445566  0  0',
                'Channels (0)',
                'Bridges (0)',
            ]
        )
    )
    out = extract_system_summary(info, Sanitizer())
    assert 'a1b2c3d4-e5f6-7a8b-9c0d-112233445566' not in out


def test_trunk_name_fully_redacted():
    # real trunk ids carry a non-standard UUID the UUID rule misses, so the
    # dedicated trunk rule must capture the whole <slug>_trunk_<id> name.
    out = anonymize_line(
        'PJSIP/customer_trunk_1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5-00000bc0 up'
    )
    assert 'customer_trunk' not in out
    assert '1a2b3c4d' not in out


def test_underscored_endpoint_names_are_redacted():
    # business/customer names appear as endpoint names in several contexts
    assert 'ALLIANZ' not in anonymize_line(
        'pjsip/options/ALLIANZ_ANNE_BAILLET_UNYC-0000f868   23949   0'
    )
    assert 'BOULANGERIE' not in anonymize_line(
        'pjsip/outreg/BOULANGERIE_GERARD_UNYC-00000228 x'
    )
    assert 'CABINET' not in anonymize_line(
        'stasis/p:endpoint:PJSIP/CABINET_ANTUNEZ_UNYC-00008105 y'
    )
    assert 'ACS_INTERIM' not in anonymize_line(
        'chan PJSIP/ACS_INTERIM_UNYC-0000abcd up'
    )


def test_underscored_endpoint_correlates_across_contexts():
    sanitizer = Sanitizer()
    a = sanitizer.line('pjsip/options/FEE_PAPILLON_UNYC-0000f868')
    b = sanitizer.line('stasis/p:endpoint:PJSIP/FEE_PAPILLON_UNYC-00008105')
    assert 'ENDPOINT_1' in a and 'ENDPOINT_1' in b  # same endpoint, same token
    assert 'FEE_PAPILLON' not in a + b


def test_human_named_trunk_is_redacted():
    # real trunk ids are not always hex UUIDs; some carry person/business names
    out = anonymize_line('PJSIP/dstny_trunk_Adil_Aube-0000021c answered')
    assert 'Adil_Aube' not in out
    assert 'dstny_trunk' not in out
    out2 = anonymize_line('chan dstny_trunk_ChapelleTrucksServices-00000216 up')
    assert 'ChapelleTrucksServices' not in out2


# --- pseudonymization mechanics ---


def test_same_value_gets_same_token_across_lines():
    sanitizer = Sanitizer()
    first = sanitizer.line('answered PJSIP/ABcD1234-0000aaaa')
    second = sanitizer.line('hangup PJSIP/ABcD1234-0000bbbb')
    assert 'ENDPOINT_1' in first
    assert 'ENDPOINT_1' in second


def test_distinct_values_get_distinct_tokens():
    out = Sanitizer().line('PJSIP/AAAAAA11@x and PJSIP/BBBBBB22@y')
    assert 'ENDPOINT_1' in out
    assert 'ENDPOINT_2' in out


def test_sanitization_does_not_rematch_generated_tokens():
    line = (
        'PJSIP/ABcD1234-0000abcd&PJSIP/ZyXw9876 dial_mobile,join,EfGh5678 '
        'sip:user123@1.2.3.4:5060 12345678-1234-1234-1234-123456789abc '
        'ctx-ID42 wazo-app-ab12cd34-ef56 +33612345678 '
        'pjsip/options/ACS_INTERIM_UNYC-00008107 PJSIP/FEE_PAPILLON_UNYC-0000abcd'
    )
    once = Sanitizer().line(line)
    twice = Sanitizer().line(once)
    assert once == twice


def test_mapping_recovers_original_value():
    sanitizer = Sanitizer()
    sanitizer.line('channel PJSIP/ABcD1234@ctx')
    assert sanitizer.pseudo.mapping()['ENDPOINT_1'] == 'ABcD1234'


# --- caller-supplied config literals ---


def test_config_literal_is_redacted():
    out = Sanitizer(literals=('customer',)).line('endpoint=customer_trunk_ab12cd34-ef')
    assert 'customer' not in out


def test_config_domain_is_redacted():
    out = Sanitizer(domains=('instance1.voip2.customer.com',)).line(
        'host instance1.voip2.customer.com up'
    )
    assert 'customer.com' not in out


def test_config_domain_redacted_even_when_gdb_truncated():
    sanitizer = Sanitizer(domains=('instance1.voip3.customer.com',))
    assert 'voip3' not in sanitizer.line('aor user@instance1.voip3.bo"..., payload')
    # gdb may cut even shorter, mid-second-label
    assert 'instance1' not in sanitizer.line('<sip:abc@instance1.v"..., payload')


def test_config_header_value_is_redacted():
    out = Sanitizer(headers=('X-TENANT-NAME',)).line(
        '"PJSIP_HEADER(add,X-TENANT-NAME)", value=0x7f001234 "AcmeCorp"'
    )
    assert 'AcmeCorp' not in out


def test_national_phone_redacted_when_country_configured():
    out = Sanitizer(phone_country='FR').line('from 0612345678 here')
    assert '0612345678' not in out


# --- CLI ---


def test_cli_filter_sanitizes(tmp_path, capsys):
    src = tmp_path / 'in.txt'
    src.write_text('peer 8.8.8.8 reachable\n')
    main(['--structural-only', 'filter', str(src)])
    out = capsys.readouterr().out
    assert '8.8.8.8' not in out
    assert 'IP_1' in out


def test_cli_filter_handles_non_utf8_bytes(tmp_path, capsys):
    src = tmp_path / 'bin.txt'
    src.write_bytes(b'peer 8.8.8.8 \x97 raw byte\n')
    main(['--structural-only', 'filter', str(src)])
    out = capsys.readouterr().out
    assert '8.8.8.8' not in out
    assert 'IP_1' in out


def test_cli_warns_without_config(tmp_path, capsys):
    src = tmp_path / 'in.txt'
    src.write_text('nothing sensitive\n')
    main(['filter', str(src)])
    assert 'WARNING' in capsys.readouterr().err


def test_cli_mapping_out_kept_out_of_sanitized_output(tmp_path, capsys):
    src = tmp_path / 'in.txt'
    src.write_text('peer 8.8.8.8 reachable\n')
    mapping_path = tmp_path / 'map.json'
    main(['--structural-only', '--mapping-out', str(mapping_path), 'filter', str(src)])
    out = capsys.readouterr().out
    assert '8.8.8.8' not in out
    assert '8.8.8.8' in json.loads(mapping_path.read_text()).values()
