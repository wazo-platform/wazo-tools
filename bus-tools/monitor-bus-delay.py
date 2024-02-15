#!/usr/bin/env python3

# Copyright 2024 The Wazo Authors  (see the AUTHORS file)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

import argparse
import dateutil.parser
import kombu
import logging
import time

from datetime import datetime, timedelta, timezone
from kombu.mixins import ConsumerMixin
from zoneinfo import ZoneInfo


logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(process)d] (%(levelname)s) (%(name)s): %(message)s',
)
logger = logging.getLogger(__name__)

count = 0
total_delay = timedelta()

last_print_time = time.time()
last_count = 0
last_delay = timedelta()


class C(ConsumerMixin):
    def __init__(self, connection, event_name):
        self.connection = connection
        self.event_name = event_name

    def get_consumers(self, Consumer, channel):
        bindings = []
        exchange = kombu.Exchange('wazo-headers', type='headers')
        arguments = {'name': self.event_name}

        bindings.append(
            kombu.binding(
                exchange=exchange,
                routing_key=None,
                arguments=arguments,
            )
        )
        return [
            Consumer(
                kombu.Queue(
                    exchange=exchange,
                    bindings=bindings,
                    exclusive=True,
                ),
                callbacks=[self.on_message],
            )
        ]

    def on_message(self, body, message):
        count_message(body)
        message.ack()
        print_stats()


def count_message(message):
    global count
    global total_delay
    count += 1
    timestamp = message['data']['timestamp']
    message_time = dateutil.parser.parse(timestamp)
    if message_time.tzinfo is None:
        message_time = message_time.replace(tzinfo=timezone.utc)
    now = datetime.now(ZoneInfo('UTC'))
    delay = now - message_time

    total_delay += delay


def print_stats():
    global last_print_time
    global last_count
    global last_delay
    if last_print_time + 1 < time.time():
        logger.info('received %s messages, mean delay: %s', count - last_count, (total_delay - last_delay) / (count - last_count))
        last_print_time = time.time()
        last_count = count
        last_delay = total_delay


def main():
    parser = argparse.ArgumentParser('read RabbitMQ xivo exchange')
    parser.add_argument('-n', '--hostname', help='RabbitMQ server', default='localhost')
    parser.add_argument('-p', '--port', help='Port of RabbitMQ', default='5672')
    parser.add_argument(
        '-e',
        '--event-name',
        help='Event Name to bind on bus. Default: StasisStart',
        dest='event_name',
        default='StasisStart'
    )
    args = parser.parse_args()

    url_amqp = f'amqp://guest:guest@{args.hostname}:{args.port}//'

    with kombu.Connection(url_amqp) as conn:
        try:
            C(conn, args.event_name).run()
        except KeyboardInterrupt:
            return


main()
