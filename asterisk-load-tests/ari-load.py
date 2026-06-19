#!/usr/bin/env python3
"""Generic ARI load generator for Asterisk.

Drives configurable load against an Asterisk ARI interface:

  - originator workers continuously originate calls through PJSIP endpoints
  - poller workers continuously list channels and read a channel variable
  - a health checker pings ARI and a reporter logs periodic stats

This is meant as a reusable base for load-test scenarios. Scenario-specific
behaviour (e.g. deadlock detection) belongs in a scenario under scenarios/.
"""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import random
import sys
import time
from dataclasses import dataclass, field
from itertools import count
from pathlib import Path

import aiohttp

logger = logging.getLogger("ari-load")


@dataclass
class LoadConfig:
    ari_url: str = "http://localhost:8088/ari"
    ari_user: str = "loadtest"
    ari_pass: str = "loadtest"
    endpoint_prefix: str = "PJSIP/loadtest"
    context: str = "loadtest"
    extension: str = "s"
    duration: int = 600
    pollers: int = 30
    originators: int = 10
    poll_interval: float = 0.005
    originate_interval: float = 0.02
    num_endpoints: int = 3
    result_dir: str = "/results"


@dataclass
class LoadStats:
    polls: int = 0
    poll_errors: int = 0
    originates: int = 0
    originate_errors: int = 0
    start_time: float = field(default_factory=time.monotonic)

    def to_dict(self) -> dict:
        elapsed = max(time.monotonic() - self.start_time, 0.001)
        return {
            "elapsed_seconds": round(elapsed, 1),
            "polls": self.polls,
            "poll_errors": self.poll_errors,
            "polls_per_second": round(self.polls / elapsed, 1),
            "originates": self.originates,
            "originate_errors": self.originate_errors,
            "originates_per_second": round(self.originates / elapsed, 1),
        }


# Errors raised by aiohttp requests we treat as expected load-time noise.
REQUEST_ERRORS = (aiohttp.ClientError, asyncio.TimeoutError)


class LoadGenerator:
    def __init__(self, config: LoadConfig) -> None:
        self.config = config
        self.stats = LoadStats()
        self.call_counter = count(1)
        self.stop_event = asyncio.Event()
        self.session: aiohttp.ClientSession | None = None

    def _auth(self) -> aiohttp.BasicAuth:
        return aiohttp.BasicAuth(self.config.ari_user, self.config.ari_pass)

    def _endpoint(self) -> str:
        idx = random.randint(0, self.config.num_endpoints - 1)
        return f"{self.config.endpoint_prefix}-{idx}"

    async def list_channels(self) -> list[dict]:
        assert self.session is not None
        url = f"{self.config.ari_url}/channels"
        try:
            async with self.session.get(
                url, auth=self._auth(), timeout=aiohttp.ClientTimeout(total=5)
            ) as resp:
                if resp.status == 200:
                    return await resp.json()
                return []
        except REQUEST_ERRORS:
            return []

    async def poll_channel_variable(self, channel_id: str) -> None:
        assert self.session is not None
        url = f"{self.config.ari_url}/channels/{channel_id}/variable"
        params = {"variable": "CHANNEL"}
        try:
            async with self.session.get(
                url,
                params=params,
                auth=self._auth(),
                timeout=aiohttp.ClientTimeout(total=5),
            ):
                self.stats.polls += 1
        except REQUEST_ERRORS:
            self.stats.poll_errors += 1

    async def originate_call(self) -> None:
        assert self.session is not None
        url = f"{self.config.ari_url}/channels"
        params = {
            "endpoint": self._endpoint(),
            "extension": self.config.extension,
            "context": self.config.context,
            "priority": 1,
            "timeout": 5,
            "channelId": f"loadtest-{next(self.call_counter)}",
        }
        try:
            async with self.session.post(
                url,
                params=params,
                auth=self._auth(),
                timeout=aiohttp.ClientTimeout(total=10),
            ) as resp:
                if resp.status in (200, 201):
                    self.stats.originates += 1
                else:
                    self.stats.originate_errors += 1
        except REQUEST_ERRORS:
            self.stats.originate_errors += 1

    async def poller_worker(self, worker_id: int) -> None:
        logger.info("[poller-%d] started", worker_id)
        while not self.stop_event.is_set():
            channels = await self.list_channels()
            sample = channels[:50]
            if sample:
                await asyncio.gather(
                    *(self.poll_channel_variable(ch["id"]) for ch in sample),
                    return_exceptions=True,
                )
            await asyncio.sleep(self.config.poll_interval)
        logger.info("[poller-%d] stopped", worker_id)

    async def originator_worker(self, worker_id: int) -> None:
        logger.info("[originator-%d] started", worker_id)
        while not self.stop_event.is_set():
            await self.originate_call()
            await asyncio.sleep(self.config.originate_interval)
        logger.info("[originator-%d] stopped", worker_id)

    async def health_checker(self) -> None:
        assert self.session is not None
        url = f"{self.config.ari_url}/asterisk/info"
        while not self.stop_event.is_set():
            await asyncio.sleep(5)
            start = time.monotonic()
            try:
                async with self.session.get(
                    url, auth=self._auth(), timeout=aiohttp.ClientTimeout(total=15)
                ):
                    elapsed = time.monotonic() - start
                    if elapsed > 2:
                        logger.warning("[health] slow response: %.1fs", elapsed)
                    else:
                        logger.info("[health] ok (%.2fs)", elapsed)
            except asyncio.TimeoutError:
                logger.error("[health] timeout after 15s - Asterisk unresponsive")
            except aiohttp.ClientError as exc:
                logger.error("[health] error: %s", exc)

    async def progress_reporter(self) -> None:
        while not self.stop_event.is_set():
            await asyncio.sleep(10)
            d = self.stats.to_dict()
            logger.info(
                "[progress] %ss - polls: %s (%s/s), originates: %s (%s/s), errors: %s",
                d["elapsed_seconds"],
                d["polls"],
                d["polls_per_second"],
                d["originates"],
                d["originates_per_second"],
                d["poll_errors"] + d["originate_errors"],
            )

    async def _check_connectivity(self) -> bool:
        assert self.session is not None
        url = f"{self.config.ari_url}/asterisk/info"
        try:
            async with self.session.get(
                url, auth=self._auth(), timeout=aiohttp.ClientTimeout(total=5)
            ) as resp:
                if resp.status != 200:
                    logger.error("ARI returned status %s", resp.status)
                    return False
                info = await resp.json()
                version = info.get("system", {}).get("version", "unknown")
                logger.info("connected to Asterisk %s", version)
                return True
        except REQUEST_ERRORS as exc:
            logger.error("cannot connect to ARI: %s", exc)
            return False

    def write_result(self) -> None:
        result_dir = Path(self.config.result_dir)
        result_dir.mkdir(parents=True, exist_ok=True)
        result = {
            "stats": self.stats.to_dict(),
            "config": {
                "duration": self.config.duration,
                "pollers": self.config.pollers,
                "originators": self.config.originators,
                "poll_interval": self.config.poll_interval,
                "originate_interval": self.config.originate_interval,
                "num_endpoints": self.config.num_endpoints,
            },
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        }
        result_path = result_dir / "load_result.json"
        result_path.write_text(json.dumps(result, indent=2))
        logger.info("result written to %s", result_path)

    async def run(self) -> bool:
        connector = aiohttp.TCPConnector(limit=200)
        async with aiohttp.ClientSession(connector=connector) as session:
            self.session = session

            logger.info("checking ARI connectivity at %s", self.config.ari_url)
            if not await self._check_connectivity():
                return False

            self.stats = LoadStats()
            tasks: list[asyncio.Task] = []
            for i in range(self.config.pollers):
                tasks.append(asyncio.create_task(self.poller_worker(i)))
            for i in range(self.config.originators):
                tasks.append(asyncio.create_task(self.originator_worker(i)))
            tasks.append(asyncio.create_task(self.health_checker()))
            tasks.append(asyncio.create_task(self.progress_reporter()))

            logger.info("running load for %ss", self.config.duration)
            try:
                await asyncio.wait_for(
                    self.stop_event.wait(), timeout=self.config.duration
                )
            except asyncio.TimeoutError:
                pass  # duration elapsed normally

            logger.info("stopping workers")
            self.stop_event.set()
            await asyncio.gather(*tasks, return_exceptions=True)

            self.write_result()
            return True


def build_parser() -> argparse.ArgumentParser:
    defaults = LoadConfig()
    parser = argparse.ArgumentParser(
        description="Generic ARI load generator for Asterisk"
    )
    parser.add_argument("--ari-url", default=defaults.ari_url)
    parser.add_argument("--ari-user", default=defaults.ari_user)
    parser.add_argument("--ari-pass", default=defaults.ari_pass)
    parser.add_argument(
        "--endpoint-prefix",
        default=defaults.endpoint_prefix,
        help="PJSIP endpoint prefix; '-N' index is appended",
    )
    parser.add_argument("--context", default=defaults.context)
    parser.add_argument("--extension", default=defaults.extension)
    parser.add_argument("--duration", type=int, default=defaults.duration)
    parser.add_argument("--pollers", type=int, default=defaults.pollers)
    parser.add_argument("--originators", type=int, default=defaults.originators)
    parser.add_argument("--poll-interval", type=float, default=defaults.poll_interval)
    parser.add_argument(
        "--originate-interval", type=float, default=defaults.originate_interval
    )
    parser.add_argument("--num-endpoints", type=int, default=defaults.num_endpoints)
    parser.add_argument("--result-dir", default=defaults.result_dir)
    return parser


def config_from_args(args: argparse.Namespace) -> LoadConfig:
    return LoadConfig(
        ari_url=args.ari_url,
        ari_user=args.ari_user,
        ari_pass=args.ari_pass,
        endpoint_prefix=args.endpoint_prefix,
        context=args.context,
        extension=args.extension,
        duration=args.duration,
        pollers=args.pollers,
        originators=args.originators,
        poll_interval=args.poll_interval,
        originate_interval=args.originate_interval,
        num_endpoints=args.num_endpoints,
        result_dir=args.result_dir,
    )


def main() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
    )
    args = build_parser().parse_args()
    config = config_from_args(args)
    if config.num_endpoints < 1:
        logger.error("--num-endpoints must be >= 1")
        sys.exit(2)
    generator = LoadGenerator(config)
    try:
        ok = asyncio.run(generator.run())
    except KeyboardInterrupt:
        logger.info("interrupted by user")
        ok = False
    if not ok:
        sys.exit(1)


if __name__ == "__main__":
    main()
