# Log analysis

## DHCP notebook (`dhcp.ipynb`)

* Install Jupyter
* Run
```shell
jupyter notebook dhcp.ipynb
```
* Edit in your browser

## Latency analysis (`analyze-latency.py`)

Analyze latency and error statistics from Wazo service HTTP logs.

The script parses `response to ... in <latency>s: <METHOD> <url> <status>` lines
emitted by Wazo services (e.g. wazo-auth, wazo-confd, wazo-calld), whether raw
or prefixed with a syslog header. Paths are normalized (UUIDs and numeric/invalid
token IDs are collapsed) so requests to the same endpoint are grouped together.

### Usage

```shell
./analyze-latency.py <logfile> [<logfile> ...]
```

### Output

The report is printed to stdout and includes:

* **Overall summary** — request count, 4xx/5xx error rates, latency
  min/avg/p50/p95/p99/p99.9/max, time range, and peak/average requests per minute
* **Status code distribution** — counts and share per HTTP status
* **Latency histogram** — request counts bucketed by latency
* **Per endpoint** — latency percentiles and error rates per `METHOD path`
  (sorted by p99 descending, endpoints with at least 10 requests)
* **Per hour** — the same metrics aggregated chronologically by hour
* **Top 20 slowest requests** — individual requests taking 1s or more
