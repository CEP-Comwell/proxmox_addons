# Ansible Role: probe-hci-agent

## Overview

`probe-hci-agent` is an Ansible role designed to deploy a lightweight, agent-based active response component within hyper-converged infrastructure (HCI) environments. It enables dynamic, node-local monitoring and response to network activity across VXLAN overlays, Linux bridges, and container networks.

This role is part of a modular active response framework that allows centralized orchestration to "zoom in" on specific workloads (VMs or containers) and take targeted actions based on real-time traffic analysis.

---

## Key Features
- Deploys a local agent to monitor VXLAN, bridge, and container interfaces
- Mirrors or captures traffic using `tc`, `veth`, or `ebpf`
- Extracts metadata (VNI, MAC/IP, interface mappings)
- Responds to triggers from a central controller or local thresholds
- Supports traffic isolation, QoS enforcement, and logging
- Integrates with Proxmox, Docker, and other HCI platforms

---

## Use Cases

- Forensic inspection of VM/container traffic
- Real-time response to anomalies or threats
- Tenant-level traffic introspection in multi-tenant environments
- Dynamic tap activation for packet capture or mirroring

---

## Requirements

- Linux host with VXLAN and/or container networking
- `tc`, `iproute2`, `tcpdump`, and optionally `bcc`/`eBPF` tools
- Root privileges for network configuration
- Optional: connection to a central orchestrator or SIEM

---

## Role Variables

| Variable             | Description                                      | Default              |
|----------------------|--------------------------------------------------|----------------------|
| `vxlan_interface`    | VXLAN interface to monitor                       | `vxlan0`             |
| `tap_interface`      | Interface to mirror traffic to                   | `veth-tap0`          |
| `capture_enabled`    | Whether to start a packet capture                | `true`               |
| `capture_path`       | Path to store pcap files                         | `/var/log/hci_probe.pcap` |
| `response_mode`      | Action to take on trigger (`mirror`, `drop`, etc)| `mirror`             |

---

## Example Playbook

```yaml
- hosts: hci_nodes
  become: true
  roles:
    - role: probe-hci-agent
      vars:
        vxlan_interface: vxlan0
        tap_interface: veth-tap0
        capture_enabled: true
        response_mode: mirror
```

---

## Contributing
See the [root contributing guide](../../docs/contributing.md) for standards and prompt scaffolding.

For a canonical role README checklist/template, see `../../docs/role_readme_template.md`.
