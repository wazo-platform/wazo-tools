"""Tests proving each redaction pattern in sanitize-coredump.py actually fires.

For a sanitizer the cardinal failure is the false negative (a leak), so every
pattern gets a case asserting the sensitive token does not survive in the
output. The module filename has a dash, so it is loaded via importlib.
"""

import importlib.util
from pathlib import Path

import pytest

_MODULE_PATH = Path(__file__).parent / 'sanitize-coredump.py'
_spec = importlib.util.spec_from_file_location('sanitize_coredump', _MODULE_PATH)
assert _spec is not None and _spec.loader is not None
_module = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_module)
anonymize_line = _module.anonymize_line


# pytest.param(input line, substring that MUST NOT survive, id=pattern name)
REDACTION_CASES = [
    pytest.param('caller +33612345678 dialed', '+33612345678', id='phone E164'),
    pytest.param(
        'from 0612345678 here',
        '0612345678',
        id='phone national',
        marks=pytest.mark.xfail(
            reason='PHONE_NATIONAL is FR-specific; needs per-country handling '
            '(see GENERALIZATION-PLAN.md)',
            strict=True,
        ),
    ),
    pytest.param(
        'endpoint=customer_trunk_ab12cd34-ef', 'customer_trunk', id='customer trunk'
    ),
    pytest.param(
        'host instance1.voip2.customer.com up', 'customer.com', id='customer host'
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
    pytest.param('wazo-app-ab12cd34-ef56 started', 'ab12cd34', id='wazo app uuid'),
    pytest.param('wazo-dial-mobile-ab12cd34-ef56', 'ab12cd34', id='wazo dial mobile'),
    pytest.param('grp-ID5-ab12cd34-ef56', 'ab12cd34', id='group id'),
    pytest.param(
        'bridge 12345678-1234-1234-1234-123456789abc',
        '12345678-1234-1234-1234-123456789abc',
        id='bridge uuid',
    ),
    pytest.param(
        'contact sip:user123@1.2.3.4:5060;ob', 'user123', id='sip contact uri'
    ),
    pytest.param('peer 8.8.8.8 reachable', '8.8.8.8', id='public ip'),
]


@pytest.mark.parametrize('line,forbidden', REDACTION_CASES)
def test_pattern_redacts_sensitive_token(line, forbidden):
    assert forbidden not in anonymize_line(line)


def test_private_ip_is_preserved():
    line = 'internal peer 10.42.0.1 and 192.168.1.5'
    result = anonymize_line(line)
    assert '10.42.0.1' in result
    assert '192.168.1.5' in result


def test_loopback_ip_is_preserved():
    assert '127.0.0.1' in anonymize_line('bound to 127.0.0.1:5060')
