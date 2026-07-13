#!/usr/bin/env python3
"""Analyze latency and error stats from Wazo service HTTP logs.

Usage: analyze-latency.py <logfile> [<logfile> ...]
"""

import re
import sys
from collections import defaultdict
from datetime import datetime
from urllib.parse import urlparse

UUID_RE = re.compile(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
# Also normalize numeric IDs and "null"/"undefined" token placeholders
JUNK_TOKEN_RE = re.compile(r'/token/(null|undefined|[0-9]+)\b')

RESPONSE_RE = re.compile(
    r'^(?:\w{3} +\d+ \d{2}:\d{2}:\d{2} \S+ \S+\[\d+\]: )?'
    r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}),\d+ \[\d+\] \(\w+\) \(\S+\): '
    r'response to (\S+) in ([0-9.]+)s: ([A-Z]+) (.*) (\d{3})\s*$'
)


def normalize_path(url: str) -> str:
    path = urlparse(url).path
    # strip nginx proxy prefix
    for prefix in ('/api/auth', '/api/confd', '/api/calld'):
        if path.startswith(prefix):
            path = path[len(prefix) :]
            break
    path = UUID_RE.sub('{uuid}', path)
    path = JUNK_TOKEN_RE.sub('/token/{invalid}', path)
    return path


def percentile(sorted_values: list[float], p: float) -> float:
    if not sorted_values:
        return 0.0
    idx = min(int(len(sorted_values) * p / 100), len(sorted_values) - 1)
    return sorted_values[idx]


def ms(seconds: float) -> str:
    if seconds >= 1.0:
        return f"{seconds:.2f}s"
    return f"{seconds * 1000:.1f}ms"


def parse_log(
    logfile: str,
    endpoints: dict,
    status_totals: dict,
    per_minute: dict,
    per_hour: dict,
    slow: list,
) -> int:
    count = 0
    with open(logfile) as f:
        for line in f:
            m = RESPONSE_RE.match(line)
            if not m:
                continue
            ts_str, _ip, latency_s, method, url, status_str = m.groups()
            latency = float(latency_s)
            status = int(status_str)
            path = normalize_path(url)
            key = f"{method} {path}"

            ep = endpoints[key]
            ep['latencies'].append(latency)
            ep['statuses'][status] += 1
            status_totals[status] += 1
            count += 1

            ts = datetime.strptime(ts_str, '%Y-%m-%d %H:%M:%S')
            per_minute[ts.strftime('%Y-%m-%d %H:%M')] += 1

            hr = per_hour[ts.strftime('%Y-%m-%d %H')]
            hr['latencies'].append(latency)
            hr['statuses'][status] += 1

            if latency >= 1.0:
                slow.append(
                    (latency, f"{ts_str}  {latency_s}s  {method} {path}  HTTP {status}")
                )
    return count


def print_section(title: str) -> None:
    print()
    print('=' * 72)
    print(f'  {title}')
    print('=' * 72)


def main(logfiles: list[str]) -> None:
    endpoints: dict[str, dict] = defaultdict(
        lambda: {'latencies': [], 'statuses': defaultdict(int)}
    )
    status_totals: dict[int, int] = defaultdict(int)
    per_minute: dict[str, int] = defaultdict(int)
    per_hour: dict[str, dict] = defaultdict(
        lambda: {'latencies': [], 'statuses': defaultdict(int)}
    )
    slow: list[tuple[float, str]] = []

    total = 0
    for logfile in logfiles:
        total += parse_log(
            logfile, endpoints, status_totals, per_minute, per_hour, slow
        )

    if not total:
        print("No response lines found.")
        return

    all_latencies = sorted(lat for ep in endpoints.values() for lat in ep['latencies'])
    errors_5xx = sum(v for k, v in status_totals.items() if k >= 500)
    errors_4xx = sum(v for k, v in status_totals.items() if 400 <= k < 500)

    print_section('OVERALL SUMMARY')
    print(f"  Total requests   : {total:>10,}")
    print(f"  4xx errors       : {errors_4xx:>10,}  ({100*errors_4xx/total:5.2f}%)")
    print(f"  5xx errors       : {errors_5xx:>10,}  ({100*errors_5xx/total:5.2f}%)")
    print()
    print(f"  Min latency      : {ms(all_latencies[0])}")
    print(f"  Avg latency      : {ms(sum(all_latencies) / total)}")
    print(f"  Median (p50)     : {ms(percentile(all_latencies, 50))}")
    print(f"  p95              : {ms(percentile(all_latencies, 95))}")
    print(f"  p99              : {ms(percentile(all_latencies, 99))}")
    print(f"  p99.9            : {ms(percentile(all_latencies, 99.9))}")
    print(f"  Max latency      : {ms(all_latencies[-1])}")
    print()
    peak_min, peak_rpm = max(per_minute.items(), key=lambda x: x[1])
    if per_minute:
        keys = sorted(per_minute)
        delta = datetime.strptime(keys[-1], '%Y-%m-%d %H:%M') - datetime.strptime(
            keys[0], '%Y-%m-%d %H:%M'
        )
        span_min = int(delta.total_seconds()) // 60 + 1
        time_range = f"{keys[0]} – {keys[-1]}"
    else:
        span_min = 0
        time_range = "n/a"
    avg_rpm = total / span_min if span_min else 0
    print(f"  Time range       : {time_range}")
    print(f"  Peak req/min     : {peak_rpm:>10,}  (at {peak_min})")
    print(
        f"  Avg req/min      : {avg_rpm:>10.0f}  (over {span_min} min span, {len(per_minute)} active)"
    )

    print_section('STATUS CODE DISTRIBUTION')
    for code in sorted(status_totals):
        bar = '█' * int(40 * status_totals[code] / total)
        print(
            f"  {code}  {status_totals[code]:>9,}  ({100*status_totals[code]/total:5.2f}%)  {bar}"
        )

    print_section('LATENCY HISTOGRAM  (all requests)')
    buckets = [0, 1, 5, 10, 25, 50, 100, 250, 500, 1000, 5000, float('inf')]
    labels = [
        '0ms',
        '1ms',
        '5ms',
        '10ms',
        '25ms',
        '50ms',
        '100ms',
        '250ms',
        '500ms',
        '1s',
        '5s',
        '∞',
    ]
    counts = [0] * (len(buckets) - 1)
    for lat in all_latencies:
        lat_ms = lat * 1000
        for i in range(len(buckets) - 1):
            if lat_ms < buckets[i + 1]:
                counts[i] += 1
                break
    for i, cnt in enumerate(counts):
        if cnt == 0:
            continue
        bar = '█' * int(40 * cnt / total)
        label = f"[{labels[i]}, {labels[i+1]})"
        print(f"  {label:<18}  {cnt:>9,}  ({100*cnt/total:5.2f}%)  {bar}")

    print_section('PER ENDPOINT  (p99 descending, min 10 requests)')
    rows = []
    for key, data in endpoints.items():
        lats = sorted(data['latencies'])
        count = len(lats)
        if count < 10:
            continue
        err_5xx = sum(v for k, v in data['statuses'].items() if k >= 500)
        err_4xx = sum(v for k, v in data['statuses'].items() if 400 <= k < 500)
        rows.append(
            {
                'endpoint': key,
                'count': count,
                'err_5xx': err_5xx,
                'err_4xx': err_4xx,
                'avg': sum(lats) / count,
                'p50': percentile(lats, 50),
                'p95': percentile(lats, 95),
                'p99': percentile(lats, 99),
                'max': lats[-1],
            }
        )
    rows.sort(key=lambda r: r['p99'], reverse=True)

    ep_w = max((len(r['endpoint']) for r in rows), default=len('Endpoint'))
    ep_w = max(ep_w, len('Endpoint'))
    hdr = f"  {'Endpoint':<{ep_w}} {'Count':>8} {'5xx%':>6} {'4xx%':>6} {'Avg':>7} {'p50':>7} {'p95':>7} {'p99':>7} {'Max':>7}"
    print(hdr)
    print('  ' + '-' * (len(hdr) - 2))
    for r in rows:
        pct_5xx = f"{100*r['err_5xx']/r['count']:.1f}%" if r['err_5xx'] else '    -'
        pct_4xx = f"{100*r['err_4xx']/r['count']:.1f}%" if r['err_4xx'] else '    -'
        print(
            f"  {r['endpoint']:<{ep_w}} {r['count']:>8,} {pct_5xx:>6} {pct_4xx:>6}"
            f" {ms(r['avg']):>7} {ms(r['p50']):>7} {ms(r['p95']):>7} {ms(r['p99']):>7} {ms(r['max']):>7}"
        )

    print_section('PER HOUR  (chronological)')
    multi_day = len({k[:10] for k in per_hour}) > 1
    label_w = 22 if multi_day else 13
    hdr = f"  {'Hour':<{label_w}} {'Count':>8} {'5xx%':>6} {'4xx%':>6} {'Avg':>7} {'p50':>7} {'p95':>7} {'p99':>7} {'Max':>7}"
    print(hdr)
    print('  ' + '-' * (len(hdr) - 2))
    for hour_key in sorted(per_hour):
        data = per_hour[hour_key]
        lats = sorted(data['latencies'])
        n = len(lats)
        h = int(hour_key[11:13])
        label = (
            f"{hour_key[:10]} {h:02d}:00–{h+1:02d}:00"
            if multi_day
            else f"{h:02d}:00–{h+1:02d}:00"
        )
        err_5xx = sum(v for k, v in data['statuses'].items() if k >= 500)
        err_4xx = sum(v for k, v in data['statuses'].items() if 400 <= k < 500)
        pct_5xx = f"{100*err_5xx/n:.1f}%" if err_5xx else '    -'
        pct_4xx = f"{100*err_4xx/n:.1f}%" if err_4xx else '    -'
        print(
            f"  {label:<{label_w}} {n:>8,} {pct_5xx:>6} {pct_4xx:>6}"
            f" {ms(sum(lats)/n):>7} {ms(percentile(lats, 50)):>7}"
            f" {ms(percentile(lats, 95)):>7} {ms(percentile(lats, 99)):>7} {ms(lats[-1]):>7}"
        )

    if slow:
        slow.sort(reverse=True)
        print_section('TOP 20 SLOWEST REQUESTS')
        for lat, desc in slow[:20]:
            print(f"  {desc}")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <logfile> [<logfile> ...]")
        sys.exit(1)
    main(sys.argv[1:])
