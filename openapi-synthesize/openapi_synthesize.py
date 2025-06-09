#!/usr/bin/env python3

import sys
import yaml

from xivo.chain_map import ChainMap
from xivo.rest_api_helpers import load_all_api_specs
from pkg_resources import iter_entry_points

def main():
    assert len(sys.argv) >= 2
    http_plugins_package = sys.argv[1]
    host = sys.argv[2] if len(sys.argv) >= 3 else None
    prefix = sys.argv[3] if len(sys.argv) >= 4 else None

    for entrypoint in iter_entry_points(http_plugins_package):
        print(f'Entry point: {entrypoint.module_name}', file=sys.stderr)

    api_specs = []
    for api_spec in load_all_api_specs(http_plugins_package, 'api.yml'):
        paths = api_spec.get('paths', {}).keys()
        for path in paths:
            print(f'Path: {path}', file=sys.stderr)
        api_specs.append(api_spec)
    api_spec = ChainMap(*api_specs)

    if host:
        api_spec['host'] = host
    if prefix:
        api_spec['schemes'] = ['https']
        base_path = api_spec.get('basePath', '')
        api_spec['basePath'] = f'{prefix}{base_path}'

    print(yaml.dump(dict(api_spec)))


if __name__ == '__main__':
    main()
