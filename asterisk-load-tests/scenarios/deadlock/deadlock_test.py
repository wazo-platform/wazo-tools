#!/usr/bin/env python3
"""
Deadlock reproduction test for Asterisk PJSIP_HEADER + ARI channel variable race.

This test attempts to trigger the deadlock by:
1. Continuously polling ARI for channel variables (acquires container lock, then channel lock)
2. Continuously originating calls through an endpoint with PJSIP_HEADER set_var
   (acquires channel lock, then waits for serializer)

The deadlock occurs when these two patterns collide with inverted lock ordering.

Usage:
    python3 deadlock_test.py --ari-url http://localhost:8088/ari --duration 120

Requirements:
    pip install aiohttp
"""

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
from typing import Optional

import aiohttp

logger = logging.getLogger(__name__)

RESULT_DIR = Path("/results")


@dataclass
class TestConfig:
    ari_url: str = "http://localhost:8088/ari"
    ari_user: str = "wazo"
    ari_pass: str = "wazo"
    endpoint: str = "PJSIP/deadlock-test"
    context: str = "deadlock-test"
    extension: str = "s"
    duration: int = 600
    poller_count: int = 30
    originator_count: int = 10
    poll_interval: float = 0.005
    originate_interval: float = 0.02
    num_endpoints: int = 5
    result_dir: str = "/results"


@dataclass
class TestStats:
    polls: int = 0
    poll_errors: int = 0
    poll_timeouts: int = 0
    originates: int = 0
    originate_errors: int = 0
    originate_timeouts: int = 0
    start_time: float = field(default_factory=time.time)

    def to_dict(self) -> dict:
        elapsed = time.time() - self.start_time
        return {
            "elapsed_seconds": round(elapsed, 1),
            "polls": self.polls,
            "poll_errors": self.poll_errors,
            "poll_timeouts": self.poll_timeouts,
            "polls_per_second": round(self.polls / max(elapsed, 0.1), 1),
            "originates": self.originates,
            "originate_errors": self.originate_errors,
            "originate_timeouts": self.originate_timeouts,
            "originates_per_second": round(self.originates / max(elapsed, 0.1), 1),
        }

    def report(self):
        d = self.to_dict()
        print(f"\n{'='*60}")
        print(f"Test Statistics (elapsed: {d['elapsed_seconds']}s)")
        print(f"{'='*60}")
        print(f"Channel variable polls:  {d['polls']:,} ({d['polls_per_second']}/s)")
        print(f"Poll errors:             {d['poll_errors']:,}")
        print(f"Poll timeouts:           {d['poll_timeouts']:,}")
        print(
            f"Calls originated:        {d['originates']:,} ({d['originates_per_second']}/s)"
        )
        print(f"Originate errors:        {d['originate_errors']:,}")
        print(f"Originate timeouts:      {d['originate_timeouts']:,}")
        print(f"{'='*60}")


@dataclass
class DeadlockDetector:
    consecutive_health_timeouts: int = 0
    consecutive_poll_timeouts: int = 0
    deadlock_detected: bool = False
    detection_time: Optional[float] = None
    _start_time: float = field(default_factory=time.time)

    HEALTH_TIMEOUT_THRESHOLD: int = 3
    POLL_TIMEOUT_THRESHOLD: int = 10

    def record_health_timeout(self) -> bool:
        self.consecutive_health_timeouts += 1
        if self.consecutive_health_timeouts >= self.HEALTH_TIMEOUT_THRESHOLD:
            self._detect()
        return self.deadlock_detected

    def record_health_ok(self):
        self.consecutive_health_timeouts = 0

    def record_poll_timeout(self) -> bool:
        self.consecutive_poll_timeouts += 1
        if self.consecutive_poll_timeouts >= self.POLL_TIMEOUT_THRESHOLD:
            self._detect()
        return self.deadlock_detected

    def record_poll_ok(self):
        self.consecutive_poll_timeouts = 0

    def _detect(self):
        if not self.deadlock_detected:
            self.deadlock_detected = True
            self.detection_time = time.time() - self._start_time
            logger.warning(
                "DEADLOCK DETECTED after %.1fs (health_timeouts=%d, poll_timeouts=%d)",
                self.detection_time,
                self.consecutive_health_timeouts,
                self.consecutive_poll_timeouts,
            )


class DeadlockTest:
    def __init__(self, config: TestConfig):
        self.config = config
        self.stats = TestStats()
        self.detector = DeadlockDetector()
        self.call_counter = count(1)
        self.stop_event = asyncio.Event()
        self.session: Optional[aiohttp.ClientSession] = None
        self.ws: Optional[aiohttp.ClientWebSocketResponse] = None
        self.active_channels: set = set()

    def auth(self):
        return aiohttp.BasicAuth(self.config.ari_user, self.config.ari_pass)

    async def stasis_event_handler(self):
        """Handle Stasis websocket events and maintain channel list for mobile-wait app"""
        ws_url = self.config.ari_url.replace("http://", "ws://").replace(
            "https://", "wss://"
        )
        ws_url = f"{ws_url}/events?app=mobile-wait&api_key={self.config.ari_user}:{self.config.ari_pass}"

        logger.info("[STASIS] Connecting to %s", ws_url)
        try:
            async with self.session.ws_connect(ws_url) as ws:
                self.ws = ws
                logger.info("[STASIS] Connected to Stasis websocket")
                async for msg in ws:
                    if self.stop_event.is_set():
                        break
                    if msg.type == aiohttp.WSMsgType.TEXT:
                        try:
                            event = msg.json()
                            event_type = event.get("type", "")
                            channel = event.get("channel", {})
                            channel_id = channel.get("id", "")

                            if event_type == "StasisStart":
                                self.active_channels.add(channel_id)
                            elif event_type in ("StasisEnd", "ChannelDestroyed"):
                                self.active_channels.discard(channel_id)
                        except Exception:
                            pass
                    elif msg.type == aiohttp.WSMsgType.ERROR:
                        logger.error("[STASIS] Websocket error: %s", ws.exception())
                        break
        except Exception as e:
            logger.error("[STASIS] Connection error: %s", e)
        finally:
            self.ws = None
            logger.info("[STASIS] Disconnected")

    async def get_channels(self) -> list:
        """List all active channels"""
        url = f"{self.config.ari_url}/channels"
        try:
            async with self.session.get(
                url, auth=self.auth(), timeout=aiohttp.ClientTimeout(total=5)
            ) as resp:
                if resp.status == 200:
                    return await resp.json()
                return []
        except Exception:
            return []

    async def poll_channel_variable(self, channel_id: str) -> bool:
        """
        Poll a channel variable via ARI.
        This is the Thread A pattern - acquires container lock, then channel lock.
        """
        url = f"{self.config.ari_url}/channels/{channel_id}/variable"
        params = {"variable": "CHANNEL"}
        try:
            async with self.session.get(
                url,
                params=params,
                auth=self.auth(),
                timeout=aiohttp.ClientTimeout(total=5),
            ) as resp:
                self.stats.polls += 1
                ok = resp.status in (200, 404)
                if ok:
                    self.detector.record_poll_ok()
                return ok
        except asyncio.TimeoutError:
            self.stats.poll_errors += 1
            self.stats.poll_timeouts += 1
            if self.detector.record_poll_timeout():
                print(f"[DEADLOCK] Poll timeout triggered deadlock detection!")
                self.stop_event.set()
            return False
        except Exception:
            self.stats.poll_errors += 1
            return False

    async def originate_call(self, use_stasis: bool = False) -> bool:
        """
        Originate a call through one of the PJSIP_HEADER endpoints.
        Rotates through multiple endpoints to create serializer contention.
        This is the Thread B pattern - acquires channel lock, waits for serializer.
        """
        url = f"{self.config.ari_url}/channels"
        call_id = next(self.call_counter)
        endpoint_idx = random.randint(0, self.config.num_endpoints - 1)
        endpoint = f"{self.config.endpoint}-{endpoint_idx}"

        if use_stasis:
            params = {
                "endpoint": endpoint,
                "app": "mobile-wait",
                "appArgs": f"push-{call_id}",
                "timeout": 30,
            }
        else:
            params = {
                "endpoint": endpoint,
                "extension": self.config.extension,
                "context": self.config.context,
                "priority": 1,
                "timeout": 5,
            }
        try:
            async with self.session.post(
                url,
                params=params,
                auth=self.auth(),
                timeout=aiohttp.ClientTimeout(total=10),
            ) as resp:
                if resp.status not in (200, 201):
                    self.stats.originate_errors += 1
                    return False
                self.stats.originates += 1
                if use_stasis:
                    data = await resp.json()
                    self.active_channels.add(data.get("id", ""))
                return True
        except asyncio.TimeoutError:
            self.stats.originate_errors += 1
            self.stats.originate_timeouts += 1
            logger.warning("[TIMEOUT] Originate timed out - possible deadlock!")
            return False
        except Exception:
            self.stats.originate_errors += 1
            return False

    async def hangup_stasis_channel(self, channel_id: str):
        """Hang up a Stasis channel after simulated wait"""
        url = f"{self.config.ari_url}/channels/{channel_id}"
        try:
            async with self.session.delete(
                url, auth=self.auth(), timeout=aiohttp.ClientTimeout(total=5)
            ) as resp:
                self.active_channels.discard(channel_id)
                return resp.status in (200, 204, 404)
        except Exception:
            return False

    async def poller_worker(self, worker_id: int):
        """Continuously poll channel variables"""
        logger.info("[Poller-%d] Started", worker_id)
        while not self.stop_event.is_set():
            channels = await self.get_channels()
            if channels:
                sample = channels[:50] if len(channels) > 50 else channels
                tasks = [self.poll_channel_variable(ch["id"]) for ch in sample]
                await asyncio.gather(*tasks, return_exceptions=True)
            await asyncio.sleep(self.config.poll_interval)
        logger.info("[Poller-%d] Stopped", worker_id)

    async def originator_worker(self, worker_id: int):
        """Continuously originate calls - mix of dialplan and Stasis"""
        logger.info("[Originator-%d] Started", worker_id)
        while not self.stop_event.is_set():
            use_stasis = random.random() < 0.3
            await self.originate_call(use_stasis=use_stasis)
            await asyncio.sleep(self.config.originate_interval)
        logger.info("[Originator-%d] Stopped", worker_id)

    async def stasis_cleanup_worker(self):
        """Periodically hang up old Stasis channels (simulates push timeout)"""
        logger.info("[StasisCleanup] Started")
        while not self.stop_event.is_set():
            await asyncio.sleep(3)
            channels = list(self.active_channels)
            if len(channels) > 50:
                to_hangup = channels[50:]
                for ch_id in to_hangup[:20]:
                    await self.hangup_stasis_channel(ch_id)
        logger.info("[StasisCleanup] Stopped")

    async def health_checker(self):
        """Periodically check if Asterisk is responsive"""
        check_interval = 5
        timeout_threshold = 15

        while not self.stop_event.is_set():
            await asyncio.sleep(check_interval)

            start = time.time()
            try:
                url = f"{self.config.ari_url}/asterisk/info"
                async with self.session.get(
                    url,
                    auth=self.auth(),
                    timeout=aiohttp.ClientTimeout(total=timeout_threshold),
                ):
                    elapsed = time.time() - start
                    if elapsed > 2:
                        print(f"[HEALTH] SLOW response: {elapsed:.1f}s")
                    else:
                        self.detector.record_health_ok()
                        print(
                            f"[HEALTH] OK ({elapsed:.2f}s) - "
                            f"polls: {self.stats.polls:,}, originates: {self.stats.originates:,}"
                        )
            except asyncio.TimeoutError:
                print(f"[HEALTH] TIMEOUT after {timeout_threshold}s - DEADLOCK LIKELY!")
                if self.detector.record_health_timeout():
                    print(f"[DEADLOCK] Health timeout triggered deadlock detection!")
                    self.stop_event.set()
            except Exception as e:
                print(f"[HEALTH] Error: {e}")

    async def progress_reporter(self):
        """Report progress periodically"""
        while not self.stop_event.is_set():
            await asyncio.sleep(10)
            elapsed = time.time() - self.stats.start_time
            print(
                f"[PROGRESS] {elapsed:.0f}s - polls: {self.stats.polls:,}, "
                f"originates: {self.stats.originates:,}, "
                f"timeouts: {self.stats.poll_timeouts + self.stats.originate_timeouts}"
            )

    def write_result(self):
        """Write structured JSON result"""
        result_dir = Path(self.config.result_dir)
        result_dir.mkdir(parents=True, exist_ok=True)

        result = {
            "result": (
                "DEADLOCK_DETECTED"
                if self.detector.deadlock_detected
                else "NO_DEADLOCK"
            ),
            "detection_time_seconds": self.detector.detection_time,
            "stats": self.stats.to_dict(),
            "config": {
                "duration": self.config.duration,
                "poller_count": self.config.poller_count,
                "originator_count": self.config.originator_count,
                "poll_interval": self.config.poll_interval,
                "originate_interval": self.config.originate_interval,
                "num_endpoints": self.config.num_endpoints,
            },
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        }

        result_path = result_dir / "test_result.json"
        with open(result_path, "w") as f:
            json.dump(result, f, indent=2)
        print(f"\n[RESULT] Written to {result_path}")
        print(f"[RESULT] {result['result']}")
        if self.detector.detection_time is not None:
            print(
                f"[RESULT] Deadlock detected after {self.detector.detection_time:.1f}s"
            )

    async def run(self):
        """Run the deadlock test"""
        print(f"{'='*60}")
        print("Asterisk PJSIP_HEADER + ARI Deadlock Reproduction Test")
        print(f"{'='*60}")
        print(f"ARI URL:           {self.config.ari_url}")
        print(f"Endpoints:         {self.config.num_endpoints}")
        print(f"Duration:          {self.config.duration}s")
        print(f"Pollers:           {self.config.poller_count}")
        print(f"Originators:       {self.config.originator_count}")
        print(f"Poll interval:     {self.config.poll_interval}s")
        print(f"Originate interval:{self.config.originate_interval}s")
        print(f"{'='*60}")
        print()

        connector = aiohttp.TCPConnector(limit=200)
        async with aiohttp.ClientSession(connector=connector) as session:
            self.session = session

            # Verify ARI connectivity
            print("[INIT] Checking ARI connectivity...")
            try:
                url = f"{self.config.ari_url}/asterisk/info"
                async with session.get(
                    url, auth=self.auth(), timeout=aiohttp.ClientTimeout(total=5)
                ) as resp:
                    if resp.status != 200:
                        print(f"[ERROR] ARI returned status {resp.status}")
                        return
                    info = await resp.json()
                    print(
                        f"[INIT] Connected to Asterisk {info.get('system', {}).get('version', 'unknown')}"
                    )
            except Exception as e:
                print(f"[ERROR] Cannot connect to ARI: {e}")
                return

            # Start workers
            print("[INIT] Starting workers...")
            self.stats.start_time = time.time()
            self.detector._start_time = time.time()

            tasks = []

            # Stasis event handler
            tasks.append(asyncio.create_task(self.stasis_event_handler()))
            await asyncio.sleep(1)

            # Poller workers (Thread A pattern)
            for i in range(self.config.poller_count):
                tasks.append(asyncio.create_task(self.poller_worker(i)))

            # Originator workers (Thread B pattern)
            for i in range(self.config.originator_count):
                tasks.append(asyncio.create_task(self.originator_worker(i)))

            # Stasis cleanup worker
            tasks.append(asyncio.create_task(self.stasis_cleanup_worker()))

            # Health checker
            tasks.append(asyncio.create_task(self.health_checker()))

            # Progress reporter
            tasks.append(asyncio.create_task(self.progress_reporter()))

            print(f"[RUN] Test running for {self.config.duration}s...")
            print(f"[RUN] Watch for TIMEOUT messages indicating deadlock")
            print()

            # Run for specified duration or until deadlock detected
            try:
                await asyncio.wait_for(
                    self.stop_event.wait(), timeout=self.config.duration
                )
            except asyncio.TimeoutError:
                pass  # Duration expired without deadlock

            # Stop all workers
            print("\n[STOP] Stopping workers...")
            self.stop_event.set()

            try:
                await asyncio.wait_for(
                    asyncio.gather(*tasks, return_exceptions=True), timeout=10
                )
            except asyncio.TimeoutError:
                print(
                    "[STOP] Some workers did not stop cleanly (may indicate deadlock)"
                )

            self.stats.report()
            self.write_result()


def main():
    parser = argparse.ArgumentParser(
        description="Asterisk PJSIP_HEADER + ARI Deadlock Reproduction Test"
    )
    parser.add_argument(
        "--ari-url", default="http://localhost:8088/ari", help="ARI base URL"
    )
    parser.add_argument("--ari-user", default="wazo", help="ARI username")
    parser.add_argument("--ari-pass", default="wazo", help="ARI password")
    parser.add_argument(
        "--endpoint",
        default="PJSIP/deadlock-test",
        help="PJSIP endpoint to originate through",
    )
    parser.add_argument("--context", default="deadlock-test", help="Dialplan context")
    parser.add_argument("--extension", default="s", help="Dialplan extension")
    parser.add_argument(
        "--duration", type=int, default=600, help="Test duration in seconds"
    )
    parser.add_argument(
        "--pollers",
        type=int,
        default=30,
        help="Number of concurrent channel variable pollers",
    )
    parser.add_argument(
        "--originators",
        type=int,
        default=10,
        help="Number of concurrent call originators",
    )
    parser.add_argument(
        "--poll-interval",
        type=float,
        default=0.005,
        help="Interval between poll cycles (seconds)",
    )
    parser.add_argument(
        "--originate-interval",
        type=float,
        default=0.02,
        help="Interval between originate attempts (seconds)",
    )
    parser.add_argument(
        "--num-endpoints",
        type=int,
        default=5,
        help="Number of PJSIP endpoints to rotate through",
    )
    parser.add_argument(
        "--result-dir", default="/results", help="Directory to write test results"
    )

    args = parser.parse_args()

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
    )

    config = TestConfig(
        ari_url=args.ari_url,
        ari_user=args.ari_user,
        ari_pass=args.ari_pass,
        endpoint=args.endpoint,
        context=args.context,
        extension=args.extension,
        duration=args.duration,
        poller_count=args.pollers,
        originator_count=args.originators,
        poll_interval=args.poll_interval,
        originate_interval=args.originate_interval,
        num_endpoints=args.num_endpoints,
        result_dir=args.result_dir,
    )

    test = DeadlockTest(config)

    try:
        asyncio.run(test.run())
    except KeyboardInterrupt:
        print("\n[INTERRUPTED] Test stopped by user")
        test.stats.report()
        test.write_result()

    sys.exit(1 if test.detector.deadlock_detected else 0)


if __name__ == "__main__":
    main()
