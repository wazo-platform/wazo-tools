#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Copyright 2015-2022 The Wazo Authors  (see the AUTHORS file)
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
import kombu
import logging

from kombu.mixins import ConsumerMixin
from pprint import pformat
from kombu import binding as Binding


logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(process)d] (%(levelname)s) (%(name)s): %(message)s')
logger = logging.getLogger(__name__)


class C(ConsumerMixin):

    def __init__(self, connection, routing_key, bindings, tenant):
        self.connection = connection
        self.routing_key = routing_key
        self.bindings = bindings
        self.tenant = tenant

    def get_consumers(self, Consumer, channel):
        bindings = []
        if self.routing_key:
            print('Use routing key binding')
            exchange = kombu.Exchange('xivo', type='topic')
        if self.bindings:
            print('Use headers binding')
            exchange = kombu.Exchange('wazo-headers', type='headers')
            for event in self.bindings.split(','):
                arguments = {'name': event}
                if self.tenant is not None:
                    arguments.update(tenant_uuid=self.tenant)
                bindings.append(kombu.binding(
                    exchange=exchange,
                    routing_key=None,
                    arguments=arguments,
                ))
        return [Consumer(kombu.Queue(exchange=exchange, routing_key=self.routing_key, bindings=bindings, exclusive=True),
                callbacks=[self.on_message])]

    def on_message(self, body, message):
        logger.info('Received: %s', pformat(body))
        message.ack()


def main():
    parser = argparse.ArgumentParser('read RabbitMQ xivo exchange')
    parser.add_argument('-n', '--hostname', help='RabbitMQ server',
                        default='localhost')
    parser.add_argument('-p', '--port', help='Port of RabbitMQ',
                        default='5672')
    parser.add_argument('-r', '--routing-key', help='(optional) Routing key to bind on bus.',
                        dest='routing_key')
    parser.add_argument('-e', '--event-name', help='Event Name to bind on bus. Multiple events are separated by a comma ",".',
                        dest='event_name')
    parser.add_argument('-t', '--tenant', help='Tenant UUID to bind on bus',
                        dest='tenant')

    args = parser.parse_args()

    url_amqp = 'amqp://guest:guest@%s:%s//' % (args.hostname, args.port)

    with kombu.Connection(url_amqp) as conn:
        try:
            C(conn, args.routing_key, args.event_name, args.tenant).run()
        except KeyboardInterrupt:
            return


main()
