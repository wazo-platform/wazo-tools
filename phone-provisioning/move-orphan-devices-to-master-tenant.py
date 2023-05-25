#!/usr/bin/env python3
# Copyright 2020-2023 The Wazo Authors  (see the AUTHORS file)
# SPDX-License-Identifier: GPL-3.0-or-later
"""
This script moves devices that are orphan to the master tenant. An orphan device is a
device that belongs to a tenant that does not exist anymore.
"""

import json
import os
import requests
import subprocess

from urllib3.exceptions import InsecureRequestWarning
from wazo_auth_client import Client as AuthClient
from xivo.chain_map import ChainMap
from xivo.config_helper import parse_config_file, read_config_file_hierarchy

_DEFAULT_CONFIG = {
    'config_file': '/etc/wazo-upgrade/config.yml',
    'auth': {
        'key_file': '/var/lib/wazo-auth-keys/wazo-upgrade-key.yml',
    },
    'provd': {
        'prefix': '',
    },
}

PROVD_JSONDB_DEVICES_DIR = '/var/lib/wazo-provd/jsondb/devices'

requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)


def _load_config():
    file_config = read_config_file_hierarchy(_DEFAULT_CONFIG)
    key_config = _load_key_file(ChainMap(file_config, _DEFAULT_CONFIG))
    return ChainMap(key_config, file_config, _DEFAULT_CONFIG)


def _load_key_file(config):
    key_file = parse_config_file(config['auth']['key_file'])
    return {
        'auth': {'username': key_file['service_id'], 'password': key_file['service_key']},
    }


def _change_device_tenant_if_orphan(device_id, master_tenant_uuid, all_tenants):
    device_path = os.path.join(PROVD_JSONDB_DEVICES_DIR, device_id)
    with open(device_path, 'r+') as file_:
        device = json.load(file_)
        if not device.get('tenant_uuid', None) in all_tenants:
            print(f'Moving device {device_id} to master tenant')
            device['tenant_uuid'] = master_tenant_uuid
            file_.seek(0)
            json.dump(device, file_)
            file_.truncate()


def main():
    config = _load_config()

    auth_client = AuthClient(**config['auth'])
    token = auth_client.token.new('wazo_user', expiration=5*60)
    auth_client.set_token(token['token'])

    master_tenant_uuid = token['metadata']['tenant_uuid']
    all_tenants = [tenant['uuid'] for tenant in auth_client.tenants.list()['items']]

    for dir_entry in os.scandir(PROVD_JSONDB_DEVICES_DIR):
        device_id = dir_entry.name
        try:
            _change_device_tenant_if_orphan(device_id, master_tenant_uuid, all_tenants)
        except json.JSONDecodeError:
            print(device_id, 'is not a valid JSON file. Skipping.')
            continue

    subprocess.run(['systemctl', 'restart', 'wazo-provd'])


if __name__ == '__main__':
    main()
