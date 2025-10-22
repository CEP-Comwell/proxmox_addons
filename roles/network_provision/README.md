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

### 1. **discovery.yml** (`--tags discovery`): Interface Detection and Analysis
**Purpose**: Scan system for physical network interfaces and analyze their capabilities.

**Key Operations**:
- **Interface enumeration**: `ls -1 /sys/class/net | grep -vE '^(lo|vmbr|tap|fw|bonding_masters|veth|br|docker|virbr|wg|tun|bond|bridge)'`
  - Excludes virtual interfaces, bridges, and already-renamed interfaces
- **Management interface protection**: Detect interface enslaved to vmbr0 using `/sys/class/net/*/master` symlinks
- **Link mode analysis**: `ethtool <interface> | grep 'Supported link modes'` for each interface
  - Identifies 10Gb vs 1Gb capabilities for intelligent bridge assignment
- **MAC address correlation**: Match vmbr0 MAC with physical interfaces for management protection

**Variables Set**: `interfaces`, `protected_mgmt_iface`, `link_modes_map`

### 2. **naming.yml** (`--tags naming`): Interface Normalization and Mapping
**Purpose**: Assign standardized names (xg1/xg2, eth1-4) based on interface capabilities.

**Key Operations**:
- **Capability detection**: Parse `link_modes_map` for "10000" (10Gb) vs "1000" (1Gb) interfaces
- **Management protection**: Reserve `xg1` for 10Gb management interface if detected
- **Sequential naming**:
  - 10Gb interfaces: `xg1`, `xg2` (max 2, preserves order)
  - 1Gb interfaces: `eth1`, `eth2`, `eth3`, `eth4` (max 4, preserves order)
  - Remaining: `nic1`, `nic2`, etc.
- **Already-named detection**: Skip interfaces matching `^(xg[12]|eth[1-9]+)$` patterns
- **Mapping generation**: Create `nic_names` dictionary: `{"nic1": "eth1", "nic6": "xg2", ...}`

**Variables Set**: `ten_g_ifaces`, `nic_names`, `xg_norm`, `eth_norm`

### 3. **pinning.yml** (`--tags pinning`): Persistent Interface Renaming
**Purpose**: Create persistent interface naming rules for boot-time application.

**Key Operations**:
- **Primary method**: `pve-network-interface-pinning generate --interface <name> --target-name <new_name>`
  - Attempts Proxmox VE 8+ native pinning tool
  - Creates `/etc/systemd/network/10-pve-<interface>.link` files
- **Fallback method** (VE 9): Manual udev rule creation
  - Template: `SUBSYSTEM=="net", KERNEL=="<current>", NAME="<target>"`
  - Creates `/etc/udev/rules.d/70-pve-net-<interface>.rules` files
- **Rule activation**: `udevadm control --reload-rules && udevadm trigger --subsystem-match=net`
  - Applies naming immediately when possible
- **Failure handling**: Detects pinning failures and switches to udev fallback automatically

**Variables Set**: `pinning_failures`

### 4. **bridging.yml** (`--tags bridging`): Bridge Creation and Interface Assignment
**Purpose**: Create SDN bridges and assign exactly 1 interface per bridge.

**Key Operations**:
- **Bridge priority assignment**:
  - `vmbr99` (Management): First available 10Gb interface (highest priority)
  - `vmbr2` (External): Second 10Gb interface, or first 1Gb if no second 10Gb
  - `vmbr1` (VM): Third 10Gb interface, or next available 1Gb interface
- **Bridge creation**: `ip link add name <bridge> type bridge` (if not exists)
- **Interface cleanup**: Detach unmanaged interfaces from bridges using `ip link set <iface> nomaster`
- **Interface attachment**: `ip link set <iface> master <bridge>` with proper up/down sequencing
- **Configuration persistence**: Create `/etc/network/interfaces.d/ansible-bridges` with bridge definitions
- **Validation**: Ensure exactly 1 interface per bridge, no interface conflicts

**Variables Set**: `bridge_assignments`, `available_10gbe`, `available_10gbe_norm`

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
Location: `/etc/network/interfaces.d/ansible-bridges`
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

# Check /etc/network/interfaces.d/ configuration
cat /etc/network/interfaces.d/ansible-bridges
```

### Changes Not Persistent After Reboot
Check configuration persistence:
```bash
# Verify initramfs includes systemd network config (VE 8)
lsinitramfs /boot/initrd.img | grep -E "systemd/network|10-pve"

# Check udev rules are loaded (VE 9)
udevadm info --export-db | grep -A 5 -B 5 "INTERFACE.*xg\|eth"

# Verify network interfaces.d configuration
cat /etc/network/interfaces.d/ansible-bridges
systemctl status networking
journalctl -u networking --no-pager -n 20
```

### Common Issues and Solutions

| Issue | Symptom | Solution |
|-------|---------|----------|
| **Interface not renamed** | Interface still shows PCI name after reboot | Check udev rules in `/etc/udev/rules.d/` and reload with `udevadm trigger` |
| **Bridge not created** | `ip link show` doesn't show vmbr* | Run bridging tasks separately: `ansible-playbook ... --tags bridging` |
| **Multiple interfaces on bridge** | STP issues, network instability | Role enforces exactly 1 interface per bridge - check `/etc/network/interfaces.d/ansible-bridges` |
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

### Critical: Proxmox Network Interface Management Rules

**🚨 NEVER directly modify `/etc/network/interfaces` in Proxmox! 🚨**

**Proxmox Network Architecture Requirements:**
- **Main interfaces file**: `/etc/network/interfaces` contains only `source /etc/network/interfaces.d/*`
- **Bridge configurations**: MUST be placed in `/etc/network/interfaces.d/ansible-bridges`
- **No duplicates**: Never create duplicate bridge definitions across files
- **Single source of truth**: All bridge configurations managed exclusively through this role

**Correct Approach:**
```bash
# ❌ WRONG - Never modify main interfaces file directly
echo "auto vmbr1..." >> /etc/network/interfaces

# ✅ CORRECT - Use interfaces.d subdirectory
cat > /etc/network/interfaces.d/ansible-bridges << EOF
# ANSIBLE MANAGED BRIDGES - DO NOT EDIT MANUALLY
auto vmbr99
iface vmbr99 inet manual
        bridge-ports xg2
        bridge-stp off
        bridge-fd 0
EOF
```

**Validation Commands:**
```bash
# Check for duplicates
grep -r "auto vmbr" /etc/network/interfaces*

# Verify main file only sources subdirectories
grep -v "^#" /etc/network/interfaces | grep -v "^source"

# Confirm bridge persistence
cat /etc/network/interfaces.d/ansible-bridges
```

### Role-Specific Considerations
- **Task Structure**: This role uses `import_tasks` for modularity - modify individual task files (`discovery.yml`, `naming.yml`, `pinning.yml`, `bridging.yml`) rather than `main.yml`
- **Tagging Support**: Use `--tags` for selective execution: `discovery`, `naming`, `pinning`, `bridging`
- **Proxmox VE 9 Compatibility**: The role automatically falls back to udev rules when `pve-network-interface-pinning` fails
- **Bridge Architecture**: Maintains exactly 1 interface per bridge - do not add multiple interfaces to avoid STP issues
- **Configuration Location**: Bridge definitions saved to `/etc/network/interfaces.d/ansible-bridges` (not main interfaces file)

### General Command Line Tool Usage Rules

**Query vs Modify Principle:**
- **Query operations**: Use command line tools freely to gather information (`ip link show`, `brctl show`, `cat /etc/network/interfaces`, etc.)
- **Modification operations**: When direct system modifications are necessary, ALWAYS include:
  1. **Clear description** of what will be modified
  2. **Purpose** of the proposed changes
  3. **Expected outcome** after execution
  4. **Rollback instructions** if applicable

**Example Modification Request:**
```bash
# ❌ Vague command without context
ip link set eth1 down

# ✅ Properly documented modification
# Purpose: Prepare interface for renaming from eth1 to eth2
# Expected: eth1 will be brought down to allow name change
# Rollback: ip link set eth1 up (if needed)
ip link set eth1 down
```

**Safety Guidelines:**
- Prefer Ansible modules over direct shell commands when possible
- Test modifications on non-production systems first
- Include verification commands after modifications
- Document any persistent changes made to system files
