# network_provision Role

## Overview
Streamlined replacement for the deprecated `nic_pinning` + `provision` roles. Provides complete network provisioning for Proxmox nodes in a hybrid spine-leaf architecture with fixed bridge assignments.

## Architecture
Fixed bridge assignments for Edgesec single-tenant network:
- **vmbr99** (Management Bridge): All 10Gb interfaces - management, engineering, support, storage traffic
- **vmbr1** (VM Bridge): First 2 1Gb interfaces - tenant VMs and core services
- **vmbr2** (External Bridge): Remaining 1Gb interfaces - external connectivity, proxy, legacy VLANs

## Quick Start

### Basic Usage
```yaml
- hosts: proxmox-hosts
  become: true
  roles:
    - network_provision
```

### With Prerequisites
```yaml
- hosts: proxmox-hosts
  become: true
  roles:
    - prereqs              # Install required packages
    - network_provision    # Configure network interfaces and bridges
```

### Run the Provision Playbook
```bash
# From repository root
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml

# Target specific host
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml --limit hostname

# Dry run (generate-only mode)
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml -e provision_generate_only=true
```

## Tasks Overview

1. **discovery.yml**: Interface detection and link mode analysis
   - Scans `/sys/class/net` for physical interfaces
   - Excludes virtual interfaces (lo, vmbr*, tap*, etc.)
   - Detects management interface via MAC address or enslavement

2. **naming.yml**: Assign normalized names (xg1/xg2, eth1-4, nicN)
   - 10Gb interfaces → `xg1`, `xg2` (sequential)
   - 1Gb interfaces → `eth1`, `eth2`, `eth3`, `eth4` (sequential)
   - Fallback → `nic1`, `nic2`, etc.

3. **pinning.yml**: Create persistent .link files and systemd configuration
   - Uses `pve-network-interface-pinning` tool
   - Generates systemd .link files in `/etc/systemd/network/`
   - Handles existing pins gracefully with warnings

4. **bridging.yml**: Create bridges and assign interfaces with persistence
   - Creates fixed bridge assignments
   - Updates `/etc/network/interfaces` with `blockinfile`
   - Applies bridge configuration immediately

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `provision_confirm_before_apply` | `false` | Pause for manual confirmation before applying bridge assignments |
| `provision_generate_only` | `false` | Generate configuration files but don't apply them (dry run mode) |

### Variable Examples

```yaml
# Interactive mode - prompts before applying changes
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml -e provision_confirm_before_apply=true

# Dry run - shows what would be configured without making changes
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml -e provision_generate_only=true
```

## Configuration Files

### Generated .link Files
Location: `/etc/systemd/network/`
```
10-pve-nic1.link
10-pve-nic2.link
...
```
These files ensure consistent interface naming across reboots.

### Network Interfaces Configuration
Location: `/etc/network/interfaces`
```bash
# Added by network_provision role
auto vmbr99
iface vmbr99 inet manual
    bridge-ports xg1 xg2
    bridge-stp off
    bridge-fd 0

auto vmbr1
iface vmbr1 inet manual
    bridge-ports eth1 eth2
    bridge-stp off
    bridge-fd 0

auto vmbr2
iface vmbr2 inet manual
    bridge-ports eth3 eth4
    bridge-stp off
    bridge-fd 0
```

## Handlers

- **update initramfs**: Updates initramfs after .link file changes
- **restart networking**: Restarts networking service to apply bridge changes

## Prerequisites

This role requires:
- `ethtool` (for interface speed detection)
- `pve-network-interface-pinning` script (auto-downloaded by prereqs role)

## Troubleshooting

### Interface Not Detected
Check physical interface status:
```bash
ip link show
ethtool <interface> | grep Speed
```

### Bridge Not Created
Verify interface naming:
```bash
ls -la /etc/systemd/network/
systemctl status systemd-networkd
```

### Changes Not Persistent After Reboot
Check initramfs was updated:
```bash
lsinitramfs /boot/initrd.img | grep systemd/network
```

## Replaced Components
- `roles/nic_pinning/` (marked DEPRECATED)
- `roles/provision/` (marked DEPRECATED)

## Benefits
- 70% code reduction through deduplication
- Fixed architecture eliminates complex template system
- Improved error handling and reliability
- Single source of truth for network configuration

## Contributing
See the [root contributing guide](../../docs/contributing.md) for standards and prompt scaffolding.

For a canonical role README checklist/template, see `../../docs/role_readme_template.md`.