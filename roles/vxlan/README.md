# VXLAN Role

Automates VXLAN/EVPN SDN infrastructure setup for Proxmox VE environments, including VLAN-aware bridges, SDN controllers, zones, and VNets.

## Features

- **VLAN-Aware Bridge Creation**: Creates Linux bridges with VLAN awareness and STP disabled
- **SDN Component Provisioning**: Sets up EVPN controllers, zones, and VNets for VXLAN overlays
- **Idempotent Operations**: Checks for existing components to avoid duplicates
- **Post-Reboot Verification**: Includes handlers for automated configuration persistence validation
- **Flexible Execution**: Supports both bridge-only setup and complete SDN infrastructure

## Usage

### Complete SDN Setup (Default)
Include the full role for complete SDN infrastructure:
```yaml
- hosts: proxmox-hosts
  roles:
    - vxlan
```

### Bridge-Only Setup
Use the `bridges_only` tasks tag for network bridge setup only:
```yaml
- hosts: proxmox-hosts
  roles:
    - role: vxlan
      tasks_from: bridges_only
```

## Variables

### Bridge Configuration
| Variable | Default | Description |
|----------|---------|-------------|
| `bridges` | See defaults/main.yml | List of bridges to create with interface mappings |

### SDN Configuration
| Variable | Default | Description |
|----------|---------|-------------|
| `sdn_controller` | `controller1` | Name of the EVPN controller |
| `sdn_asn` | `65000` | Autonomous System Number for BGP |
| `sdn_zones` | See defaults/main.yml | List of SDN zones with VRF VXLAN mappings |
| `sdn_vnets` | See defaults/main.yml | List of VNets with zone and VLAN tag mappings |

## Default Configuration

The role creates:
- **Bridges**: `vmbr99` (eth0), `vmbr1` (eth1), `vmbr2` (eth2) - all VLAN-aware
- **EVPN Controller**: `controller1` with ASN 65000
- **Zones**: `zone1` (VRF VXLAN 100), `zone2` (VRF VXLAN 200)
- **VNets**: `vnet1` (zone1, VLAN 10), `vnet2` (zone2, VLAN 20)

## Handlers

The role includes handlers that trigger post-configuration verification:
- Network interface status checks
- SDN component persistence validation
- Bridge configuration verification in `/etc/network/interfaces`

## Dependencies

- Proxmox VE 9+ with SDN capabilities
- `pvesh` command-line tool for SDN management
- Ansible collections: `ansible.posix`, `community.general`

## Example Playbook

```yaml
---
- name: Setup VXLAN SDN Infrastructure
  hosts: proxmox-hosts
  become: true

  roles:
    - vxlan

  post_tasks:
    - name: Manual verification trigger
      ansible.builtin.command: echo "Trigger verification"
      notify: "verify post-reboot"
      when: run_verification | default(false) | bool
```

## LLM/Code Assistant Guidance

When using LLM assistants or automated code tools to modify this role:

- **Review infrastructure automation guidelines**: Read "Infrastructure Automation: Ansible vs Proxmox API" in `docs/contributing.md`
- Follow the checklist in `docs/role_readme_template.md`
- Test changes with: `ansible-playbook --syntax-check` and `ansible-lint`
- Keep changes focused and include rationale in commit messages


## Contributing

See the [root contributing guide](../../docs/contributing.md) for standards and prompt scaffolding.

For a canonical role README checklist/template, see `../../docs/role_readme_template.md`.