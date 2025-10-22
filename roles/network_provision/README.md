# network_provision Role

## Overview
Streamlined replacement for the deprecated `nic_pinning` + `provision` roles. Provides complete network provisioning for Proxmox nodes in a hybrid spine-leaf architecture with fixed bridge assignments.

## Architecture
Fixed bridge assignments for Edgesec single-tenant network with hybrid spine-leaf topology:
- **vmbr99** (Management Bridge): First available 10Gb interface (highest priority) - management, engineering, support, storage traffic
- **vmbr2** (External Bridge): Second 10Gb interface (if available) or first 1Gb interface - external connectivity, proxy, legacy VLANs
- **vmbr1** (VM Bridge): Third 10Gb interface (if available) or next available 1Gb interface - tenant VMs and core services

**Key Design Principles:**
- Exactly 1 interface per bridge (no STP complexity)
- 10Gb interfaces prioritized for management/external traffic
- 1Gb interfaces used for VM traffic when 10Gb not available
- Management interface (vmbr0) automatically protected and excluded

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

### Selective Task Execution with Tags
```bash
# Run only interface discovery and naming (no changes applied)
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml --tags discovery,naming

# Run only bridge creation (assumes discovery/naming already done)
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml --tags bridging

# Run interface pinning only
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml --tags pinning

# Skip discovery (use cached interface data)
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml --skip-tags discovery
```

### Run the Network Provisioning Playbook
```bash
# From repository root - full provisioning
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml

# Target specific host
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml --limit hostname

# Dry run (generate-only mode) - shows what would be configured
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml -e provision_generate_only=true

# Interactive mode - prompts before applying bridge changes
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml -e provision_confirm_before_apply=true

# Verbose output for troubleshooting
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml -v
```

## Tasks Overview

The role executes tasks in the following order using `import_tasks`:

1. **discovery.yml** (`--tags discovery`): Interface detection and link mode analysis
   - Scans `/sys/class/net` for physical interfaces (excludes virtual, bridge, and already-renamed interfaces)
   - Detects management interface currently enslaved to vmbr0 (protects Proxmox management NIC)
   - Gathers supported link modes for each interface using `ethtool`
   - Builds interface-to-capability mapping for naming decisions

2. **naming.yml** (`--tags naming`): Assign normalized names (xg1/xg2, eth1-4, nicN)
   - 10Gb interfaces → `xg1`, `xg2` (sequential, up to 2 interfaces)
   - 1Gb interfaces → `eth1`, `eth2`, `eth3`, `eth4` (sequential, up to 4 interfaces)
   - Fallback → `nic1`, `nic2`, etc. for remaining interfaces
   - Preserves interface order and protects management interface

3. **pinning.yml** (`--tags pinning`): Create persistent interface renaming
   - Attempts to use `pve-network-interface-pinning` tool first
   - Falls back to manual udev rules for Proxmox VE 9 compatibility
   - Creates systemd .link files or udev rules in `/etc/udev/rules.d/`
   - Reloads udev rules to apply naming immediately

4. **bridging.yml** (`--tags bridging`): Create bridges and assign interfaces with persistence
   - Calculates optimal bridge assignments based on interface capabilities
   - Creates bridges if they don't exist (`ip link add`)
   - Attaches exactly 1 interface per bridge (no STP complexity)
   - Updates `/etc/network/interfaces` with `blockinfile` for persistence
   - Validates assignments and shows final bridge state

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `provision_confirm_before_apply` | `false` | Pause for manual confirmation before applying bridge assignments |
| `provision_generate_only` | `false` | Generate configuration but don't apply changes (dry run mode) |

### Variable Examples

```yaml
# Interactive mode - prompts before applying changes
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml -e provision_confirm_before_apply=true

# Dry run - shows what would be configured without making changes
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml -e provision_generate_only=true
```

### Task Tags

The role supports selective execution using Ansible tags:

| Tag | Tasks | Description |
|-----|-------|-------------|
| `discovery` | discovery.yml | Interface detection and analysis only |
| `naming` | naming.yml | Interface naming assignment only |
| `pinning` | pinning.yml | Interface pinning/udev rules only |
| `bridging` | bridging.yml | Bridge creation and assignment only |

**Tag Usage Examples:**
```bash
# Test interface detection without making changes
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml --tags discovery -v

# Apply only bridge configuration (assumes interfaces already renamed)
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml --tags bridging

# Skip interface discovery (use cached data)
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml --skip-tags discovery
```

## Configuration Files

## Configuration Files

### Generated .link Files (Proxmox VE 8)
Location: `/etc/systemd/network/`
```
10-pve-nic1.link
10-pve-nic2.link
...
```
These files ensure consistent interface naming across reboots when `pve-network-interface-pinning` succeeds.

### Generated udev Rules (Proxmox VE 9 Fallback)
Location: `/etc/udev/rules.d/`
```
70-pve-net-enp1s0f0.rules
70-pve-net-enp1s0f1.rules
...
```
Manual udev rules created when `pve-network-interface-pinning` fails (expected in Proxmox VE 9).

### Network Interfaces Configuration
Location: `/etc/network/interfaces`
```bash
# ANSIBLE MANAGED BRIDGES - DO NOT EDIT MANUALLY
auto vmbr99
iface vmbr99 inet manual
        bridge-ports xg1
        bridge-stp off
        bridge-fd 0

auto vmbr2
iface vmbr2 inet manual
        bridge-ports xg2
        bridge-stp off
        bridge-fd 0

auto vmbr1
iface vmbr1 inet manual
        bridge-ports eth1
        bridge-stp off
        bridge-fd 0
```

## Handlers

- **update initramfs**: Updates initramfs after .link file changes (used when `pve-network-interface-pinning` succeeds)
- **restart networking**: Restarts networking service to apply bridge changes (used after bridge configuration)

## Prerequisites

This role requires:
- `ethtool` (for interface speed detection)
- `pve-network-interface-pinning` script (auto-downloaded by prereqs role)

## Troubleshooting

### Interface Not Detected
Check physical interface status:
```bash
ip link show                                    # Show all interfaces
ls -1 /sys/class/net                           # List interface device names
ethtool <interface> | grep Speed               # Check interface speed/capabilities
```

### Management Interface Protection
The role automatically protects the interface currently enslaved to vmbr0:
```bash
# Check which interface is enslaved to vmbr0
ip link show master vmbr0

# Check vmbr0 MAC address matching
cat /sys/class/net/vmbr0/address
for i in /sys/class/net/*; do echo "$i: $(cat $i/address 2>/dev/null)"; done
```

### Interface Pinning Issues (Proxmox VE 9)
When `pve-network-interface-pinning` fails (expected in VE 9):
```bash
# Check udev rules were created
ls -la /etc/udev/rules.d/70-pve-net-*.rules

# Check udev rules content
cat /etc/udev/rules.d/70-pve-net-*.rules

# Manually reload udev rules
udevadm control --reload-rules && udevadm trigger
```

### Bridge Configuration Issues
Verify bridge assignments and current state:
```bash
# Show bridge status
ip -br link show type bridge

# Show interfaces attached to bridges
for br in vmbr99 vmbr1 vmbr2; do echo "=== $br ==="; ip link show master $br; done

# Check /etc/network/interfaces configuration
grep -A 5 "auto vmbr" /etc/network/interfaces
```

### Changes Not Persistent After Reboot
Check configuration persistence:
```bash
# Verify initramfs includes systemd network config (VE 8)
lsinitramfs /boot/initrd.img | grep -E "systemd/network|10-pve"

# Check udev rules are loaded (VE 9)
udevadm info --export-db | grep -A 5 -B 5 "INTERFACE.*xg\|eth"

# Verify network interfaces configuration
systemctl status networking
journalctl -u networking --no-pager -n 20
```

### Common Issues and Solutions

| Issue | Symptom | Solution |
|-------|---------|----------|
| **Interface not renamed** | Interface still shows PCI name after reboot | Check udev rules in `/etc/udev/rules.d/` and reload with `udevadm trigger` |
| **Bridge not created** | `ip link show` doesn't show vmbr* | Run bridging tasks separately: `ansible-playbook ... --tags bridging` |
| **Multiple interfaces on bridge** | STP issues, network instability | Role enforces exactly 1 interface per bridge - check interface assignments |
| **Management interface lost** | Cannot access Proxmox web UI | Role protects vmbr0-enslaved interface - check discovery task output |
| **VE 9 compatibility** | `pve-network-interface-pinning` failures | Expected - role falls back to udev rules automatically |

### Debug Mode
Run with maximum verbosity to troubleshoot issues:
```bash
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml -vvv
```

## Replaced Components
- `roles/nic_pinning/` (marked DEPRECATED)
- `roles/provision/` (marked DEPRECATED)

## Benefits
- **Proxmox VE 9 Compatible**: Automatic fallback from `pve-network-interface-pinning` to udev rules
- **Fixed SDN Architecture**: Exactly 1 interface per bridge eliminates STP complexity
- **Intelligent Assignment**: 10Gb interfaces prioritized for management/external traffic
- **Management Protection**: Automatically detects and protects vmbr0-enslaved interfaces
- **Selective Execution**: Task-level tagging allows partial execution and troubleshooting
- **Comprehensive Validation**: Validates assignments and prevents interface conflicts
- **Dry Run Support**: `provision_generate_only` mode for safe testing
- **70% code reduction** through deduplication from legacy `nic_pinning` + `provision` roles

## Contributing
See the [root contributing guide](../../docs/contributing.md) for standards and prompt scaffolding.

For a canonical role README checklist/template, see `../../docs/role_readme_template.md`.
## LLM/Code Assistant Guidance

When using LLM assistants or automated code tools to modify this role:

### Role-Specific Considerations
- **Task Structure**: This role uses `import_tasks` for modularity - modify individual task files (`discovery.yml`, `naming.yml`, `pinning.yml`, `bridging.yml`) rather than `main.yml`
- **Tagging Support**: Use `--tags` for selective execution: `discovery`, `naming`, `pinning`, `bridging`
- **Proxmox VE 9 Compatibility**: The role automatically falls back to udev rules when `pve-network-interface-pinning` fails
- **Bridge Architecture**: Maintains exactly 1 interface per bridge - do not add multiple interfaces to avoid STP issues

### Development Guidelines
- **Review infrastructure automation guidelines**: Read "Infrastructure Automation: Ansible vs Proxmox API" in `docs/contributing.md`
- **Follow the checklist**: See `docs/role_readme_template.md` for comprehensive testing requirements
- **Test with tagging**: Use selective task execution for focused testing: `ansible-playbook ... --tags discovery,naming`
- **Validate assignments**: The role validates bridge assignments - ensure exactly 1 interface per bridge
- **Keep changes focused**: Modify individual task files rather than the entire role
- **Include rationale**: Commit messages should explain architectural decisions, especially around interface assignments
