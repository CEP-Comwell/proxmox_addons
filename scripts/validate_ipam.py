#!/usr/bin/env python3
"""Validate IPAM/YAML produced for VXLAN ports.

Checks:
- VNI uniqueness
- `vnet` equals 'vn' + vni
- gateway is in subnet
- dhcp_range start/end are in subnet
- when feature 'jumbo mtu 9000' present, warn or check bridges.yml for matching mtu

Usage: ./scripts/validate_ipam.py [path/to/ovs_vxlan_ports.yml]
"""
import sys
from pathlib import Path
import ipaddress

try:
    import yaml
except Exception:
    print("Missing PyYAML dependency. Install with: pip install pyyaml", file=sys.stderr)
    sys.exit(2)


def parse_dhcp_range(rng):
    if not rng:
        return None, None
    if isinstance(rng, (list, tuple)) and len(rng) == 2:
        return rng[0], rng[1]
    if isinstance(rng, str) and '-' in rng:
        a, b = rng.split('-', 1)
        return a.strip(), b.strip()
    return None, None


def load_yaml(path: Path):
    with path.open() as f:
        return yaml.safe_load(f)


def find_bridge_for_vx(host_bridges, vxname):
    for bridge in host_bridges.get('bridges', []):
        for sub in bridge.get('subinterfaces', []) or []:
            if sub.get('name') == vxname:
                return bridge
    return None


def main():
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path('import/ovs_vxlan_ports.yml')
    if not path.exists():
        print(f"IPAM file not found: {path}", file=sys.stderr)
        sys.exit(2)

    data = load_yaml(path)
    ipam = data.get('ipam', {}) if isinstance(data, dict) else {}

    seen_vnis = {}
    errors = 0
    warns = 0

    # try load a host_vars bridges file to check mtu hints (best-effort)
    hv_path = Path('host_vars')
    host_bridge_data = {}
    # load pve1 host_vars if present
    sample = Path('host_vars/pve1.comwell.edgesec.ca/bridges.yml')
    if sample.exists():
        try:
            host_bridge_data = load_yaml(sample)
        except Exception:
            host_bridge_data = {}

    for key, entry in sorted(ipam.items()):
        vni = entry.get('vni')
        vnet = entry.get('vnet')
        subnet = entry.get('subnet')
        gateway = entry.get('gateway')
        dhcp = entry.get('dhcp_range')
        features = entry.get('features') or []

        if vni is None:
            print(f"ERROR: {key} missing vni")
            errors += 1
            continue

        if vni in seen_vnis:
            print(f"ERROR: duplicate VNI {vni} for {key} and {seen_vnis[vni]}")
            errors += 1
        else:
            seen_vnis[vni] = key

        expected_vnet = f"vn{vni}"
        if vnet != expected_vnet:
            print(f"WARN: {key} vnet '{vnet}' != expected '{expected_vnet}'")
            warns += 1

        # subnet/gateway checks
        try:
            net = ipaddress.ip_network(subnet)
        except Exception as e:
            print(f"ERROR: {key} invalid subnet '{subnet}': {e}")
            errors += 1
            continue

        try:
            gw = ipaddress.ip_address(gateway)
            if gw not in net:
                print(f"ERROR: {key} gateway {gateway} not in subnet {subnet}")
                errors += 1
        except Exception as e:
            print(f"ERROR: {key} invalid gateway '{gateway}': {e}")
            errors += 1

        start, end = parse_dhcp_range(dhcp)
        if start and end:
            try:
                a = ipaddress.ip_address(start)
                b = ipaddress.ip_address(end)
                if a not in net or b not in net:
                    print(f"ERROR: {key} dhcp_range {dhcp} not fully inside {subnet}")
                    errors += 1
            except Exception as e:
                print(f"ERROR: {key} invalid dhcp_range '{dhcp}': {e}")
                errors += 1

        # feature checks: jumbo mtu 9000 -> check host bridge mtu if declared
        for feat in features:
            if isinstance(feat, str) and 'jumbo mtu 9000' in feat:
                # find bridge in host_bridge_data that references this vx name
                bridge = find_bridge_for_vx(host_bridge_data, key)
                if bridge:
                    bmtu = bridge.get('mtu')
                    if bmtu != 9000:
                        print(f"WARN: {key} requests jumbo mtu 9000 but bridge '{bridge.get('name')}' mtu={bmtu}")
                        warns += 1
                else:
                    print(f"WARN: {key} requests jumbo mtu 9000 but no bridge reference found in host_vars/pve1.../bridges.yml")
                    warns += 1

    print('\nSummary:')
    print(f"  errors: {errors}")
    print(f"  warnings: {warns}")
    sys.exit(1 if errors else 0)


if __name__ == '__main__':
    main()
