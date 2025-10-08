# Ansible Role: probe-vxlan-node

## Overview

`probe-vxlan-node` is an Ansible role designed for active network introspection within hyper-converged infrastructures (HCI) using VXLAN overlays. It enables dynamic probing of VXLAN nodes to monitor encapsulated traffic, correlate virtual network identifiers (VNIs) with tenant workloads, and trigger active responses.

This role is part of a modular active response toolkit that zooms into VM and container traffic across virtualized environments.

---

## Features

- Mirrors VXLAN traffic to tap interfaces using `tc` rules
- Captures and inspects VXLAN encapsulated packets
- Extracts metadata such as VNI, inner MAC/IP headers
- Supports integration with eBPF for programmable deep inspection
- Designed for use in Proxmox, Docker, and other HCI platforms

---

## Requirements

- Linux host with VXLAN interfaces (e.g., `vxlan0`)
- `tc` (traffic control), `tcpdump`, and optionally `eBPF` tools installed
- Root privileges for network configuration

---

## Role Variables

| Variable         | Description                              | Default        |
|------------------|------------------------------------------|----------------|
| `vxlan_interface`| Name of the VXLAN interface to probe     | `vxlan0`       |
| `tap_interface`  | Destination interface for mirrored traffic| `veth-tap0`    |
| `capture_path`   | Path to store captured traffic logs      | `/var/log/vxlan_probe.pcap` |

---

## Example Playbook

```yaml
- hosts: vxlan_nodes
  become: true
  roles:
    - role: probe-vxlan-node
      vars:
        vxlan_interface: vxlan0
        tap_interface: veth-tap0
        capture_path: /var/log/vxlan_probe.pcap
```

---

## Contributing

See the [root contributing guide](../../docs/contributing.md) for standards and prompt scaffolding.
