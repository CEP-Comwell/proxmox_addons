---
title: "Contributing Guide"
description: "Guidelines for contributing to the Proxmox Addons repository"
version: "1.0"
last_updated: "2025-10-22"
sections:
  - general_recommendations
  - commit_standards
  - coding_standards
  - pull_requests
  - secrets
  - project_structure
  - infrastructure_automation
  - platform_considerations
  - sdn_provisioning_guidelines
  - network_configuration_commands
  - llm_guidance
  - quick_reference
---

# Contributing Guide

## Table of Contents

- [General Recommendations](#general-recommendations)
- [Commit Standards](#commit-standards)
- [Coding Standards](#coding-standards)
- [Pull Requests](#pull-requests)
- [Secrets](#secrets)
- [Ansible & Docker Compose Project Structure](#ansible--docker-compose-project-structure)
  - [Playbooks](#playbooks)
  - [Roles](#roles)
  - [Tasks](#tasks)
  - [Variables & Handlers](#variables--handlers)
  - [ansible.cfg](#ansiblecfg)
  - [Docker Compose](#docker-compose)
  - [Running Playbooks](#running-playbooks)
- [Infrastructure Automation: Ansible vs Proxmox API](#infrastructure-automation-ansible-vs-proxmox-api)
  - [Use Ansible/Shell Commands When](#use-ansibleshell-commands-when)
  - [Use Proxmox API When](#use-proxmox-api-when)
  - [Hybrid Approach (Recommended)](#hybrid-approach-recommended)
  - [Key Decision Factors](#key-decision-factors)
- [Platform-Specific Considerations](#platform-specific-considerations)
  - [Proxmox VE 9 Environment](#proxmox-ve-9-environment)
  - [Known Platform Limitations](#known-platform-limitations)
  - [Version-Specific Behaviors](#version-specific-behaviors)
  - [Recommended Approaches by Component](#recommended-approaches-by-component)
- [Proxmox VE 9 SDN Provisioning Guidelines](#proxmox-ve-9-sdn-provisioning-guidelines)
  - [Interface Pinning First, Then SDN Provisioning](#interface-pinning-first-then-sdn-provisioning)
  - [Primary Method: pvesh API for SDN](#primary-method-pvesh-api-for-sdn)
  - [Bridge Creation Best Practices](#bridge-creation-best-practices)
  - [Configuration Application](#configuration-application)
  - [Verification Steps](#verification-steps)
  - [Common Issues and Solutions](#common-issues-and-solutions)
  - [Automated Testing](#automated-testing)
  - [Migration from Manual SDN Bridge Creation](#migration-from-manual-sdn-bridge-creation)
- [Proxmox VE 9 Network Configuration Commands](#proxmox-ve-9-network-configuration-commands)
  - [Essential pvesh SDN Commands (After Interface Pinning)](#essential-pvesh-sdn-commands-after-interface-pinning)
  - [Essential Device Discovery Commands](#essential-device-discovery-commands)
  - [Network Bridge and VLAN Commands](#network-bridge-and-vlan-commands)
  - [System Information Commands](#system-information-commands)
  - [Troubleshooting Commands](#troubleshooting-commands)
  - [Automation-Friendly Commands](#automation-friendly-commands)
  - [Proxmox VE 9 Specific Considerations](#proxmox-ve-9-specific-considerations)
  - [Common Device Query Patterns](#common-device-query-patterns)
- [Guidance for LLMs and automated code assistants](#guidance-for-llms-and-automated-code-assistants)
  - [Best Practices for Automated Changes](#best-practices-for-automated-changes)
  - [Error Remediation Checklist](#error-remediation-checklist)
- [Quick Reference](#quick-reference)
  - [Automation Decision Matrix](#automation-decision-matrix)
  - [Essential Commands for Contributors](#essential-commands-for-contributors)

---

For more, see `/docs/onboarding.md` and `/docs/security-best-practices.md`.

---

## General Recommendations
- Follow Ansible best practices for role and playbook structure:
  - Place tasks in `tasks/main.yml` and handlers in `handlers/main.yml` within each role.
  - Do not include handlers directly in task files; use `notify` to trigger handlers.
  - Use `roles:` in playbooks to import roles, ensuring modularity and reusability.
  - Reference roles by name only; Ansible will locate them via `ansible.cfg`.
  - Use `loop_control` for loop indices and avoid deprecated or invalid YAML constructs.
  - Ensure all YAML files are properly indented and formatted to avoid syntax errors.
  - Place templates in the `templates/` directory and use the `template` module for rendering.
  - Store shared variables in `defaults/main.yml` or `vars/main.yml` for each role.
  - Use `group_vars/` and `host_vars/` for inventory-wide variables.
  - Always test changes with `ansible-playbook --syntax-check` before submitting.
- For Docker Compose and other automation, follow the same modular directory structure and naming conventions.

## Commit Standards
- Use [Conventional Commits](https://www.conventionalcommits.org/) for all commits.
- Run linting and tests before submitting a PR.

## Coding Standards
- Use ESLint and Prettier for all TypeScript/JavaScript code.
- Follow the directory structure and naming conventions in the onboarding guide.

## Pull Requests
- Reference the related issue or task in your PR description.
- Ensure all CI checks pass before requesting review.

## Secrets
- Never commit real secrets. Use `.env.example` for templates.

---

For more, see `/docs/onboarding.md` and `/docs/security-best-practices.md`.

---

## Ansible & Docker Compose Project Structure

This repository uses a modular structure for automation projects. Please follow these guidelines when contributing Ansible or Docker Compose code:

### Playbooks
- Place all playbooks in the appropriate subproject directory (e.g., `edgesec-tapx/playbooks/`, `edgesec-sdn/playbooks/`).
- Do not keep playbooks in the project root.

### Roles
- All reusable roles must be placed in the top-level `roles/` directory.
- Reference roles in playbooks using their name only (Ansible will find them via `ansible.cfg`).

### Tasks
- Shared task files (for `include_tasks`) should be placed in the top-level `tasks/` directory.
- Reference them with a relative path from your playbook (e.g., `../../tasks/my_task.yml`).

### Variables & Handlers
- Use `group_vars/` and `host_vars/` for inventory-wide variables.
- Use `vars_files:` in playbooks to include shared variable files (e.g., `../../config.yml`).
- Define handlers inside roles whenever possible for modularity.

### ansible.cfg
- Each subproject's `playbooks/` directory must have an `ansible.cfg` with:
	````markdown
	# Contributing Guide

	## General Recommendations
	- Follow Ansible best practices for role and playbook structure:
	  - Place tasks in `tasks/main.yml` and handlers in `handlers/main.yml` within each role.
	  - Do not include handlers directly in task files; use `notify` to trigger handlers.
	  - Use `roles:` in playbooks to import roles, ensuring modularity and reusability.
	  - Reference roles by name only; Ansible will locate them via `ansible.cfg`.
	  - Use `loop_control` for loop indices and avoid deprecated or invalid YAML constructs.
	  - Ensure all YAML files are properly indented and formatted to avoid syntax errors.
	  - Place templates in the `templates/` directory and use the `template` module for rendering.
	  - Store shared variables in `defaults/main.yml` or `vars/main.yml` for each role.
	  - Use `group_vars/` and `host_vars/` for inventory-wide variables.
	  - Always test changes with `ansible-playbook --syntax-check` before submitting.
	- For Docker Compose and other automation, follow the same modular directory structure and naming conventions.

	## Commit Standards
	- Use [Conventional Commits](https://www.conventionalcommits.org/) for all commits.
	- Run linting and tests before submitting a PR.

	## Coding Standards
	- Use ESLint and Prettier for all TypeScript/JavaScript code.
	- Follow the directory structure and naming conventions in the onboarding guide.

	## Pull Requests
	- Reference the related issue or task in your PR description.
	- Ensure all CI checks pass before requesting review.

## Secrets
- Never commit real secrets. Use `.env.example` for templates.

---

For more, see `/docs/onboarding.md` and `/docs/security-best-practices.md`.

---

## Ansible & Docker Compose Project Structure## Infrastructure Automation: Ansible vs Proxmox API

When developing automation for Proxmox environments, choose the appropriate tool based on the operation type. This guidance helps maintain clean separation between direct system management and API-based infrastructure management.

### Use Ansible/Shell Commands When:

1. **Direct File System Operations**
   - Editing `/etc/network/interfaces` or system config files
   - Managing systemd services

2. **Interface Pinning and Renaming**
   - Using `pve-network-interface-pinning` for persistent interface naming
   - Interface detection and PCI address mapping for naming

3. **Low-Level Network Configuration**
   - Running `ip link`, `brctl`, or `ethtool` commands for interface management
   - Complex interface detection using `ls -1 /sys/class/net` with filters
   - Manual bridge creation/destruction during troubleshooting

4. **Proxmox Version Compatibility Issues**
   - When Proxmox API behavior changes between versions
   - Working around API limitations or bugs
   - Implementing custom workarounds for specific Proxmox versions

5. **Complex Shell-Based Logic**
   - Parsing `ethtool` output for link speed detection
   - Multi-step operations requiring shell piping or conditional logic
   - One-time setup tasks before API management

### Use Proxmox API (pvesh) When:

1. **VM/Container Lifecycle Management**
   - Creating, starting, stopping VMs/containers
   - Managing VM configurations, disk attachments, network interfaces
   - Bulk operations across multiple VMs

2. **Cluster Management**
   - Managing cluster membership, HA configurations
   - Resource pool management and permissions
   - Backup scheduling and storage management

3. **SDN Network Provisioning (After Interface Pinning)**
   - Creating/managing Linux bridges through Proxmox's SDN abstraction layer
   - Managing bridge properties, VLAN awareness, and attached VMs
   - Applying network configuration changes with `pvesh set /nodes/localhost/network`
   - Ensuring bridge persistence with `-autostart yes` parameter

4. **Storage Operations**
   - Creating/managing storage pools, volumes, and backups
   - Storage migration and replication
   - iSCSI/LVM/ZFS configuration

5. **Monitoring and Metrics**
   - Accessing performance metrics and logs
   - Health monitoring and alerting
   - Resource usage tracking

6. **User/Access Management**
   - Managing users, groups, and API tokens
   - Permission and role assignments
   - Authentication configuration

7. **Declarative Infrastructure**
   - Ongoing configuration management and drift detection
   - Automated remediation of configuration changes
   - Integration with infrastructure-as-code workflows

### Hybrid Approach (Recommended):

8. **Interface Pinning First, Then SDN Provisioning**
   - Use `pve-network-interface-pinning` for persistent interface naming
   - After interfaces are properly named/pinned, switch to pvesh API for SDN bridge creation
   - Example: Pinning ensures eth0/eth1 are consistent, then pvesh creates bridges on those interfaces

9. **API with Shell Fallbacks**
   - Primary operations via pvesh API, shell commands as fallbacks
   - Use API for standard operations, shell for edge cases
   - Log API failures and automatically retry with shell methods

### Key Decision Factors

```yaml
decision_factors:
  stability:
    api_preferred: true
    shell_for: "interface pinning only"
    reasoning: "pvesh API for SDN, pve-network-interface-pinning for interface naming"
  version_compatibility:
    shell_when: "API changes between Proxmox versions"
    api_fallback: false
  complexity:
    api_for: "SDN operations"
    shell_for: "interface detection and pinning"
  idempotency:
    api_better: true
    reasoning: "pvesh API generally better for idempotent SDN operations"
  debugging:
    shell_better: true
    reasoning: "Shell commands provide better visibility for interface issues"
```

## Platform-Specific Considerations

### Proxmox VE 9 Environment
- **OS**: Debian 13 (Bookworm)
- **Networking**: systemd-networkd disabled by default, traditional ifupdown system
- **SDN Provisioning**: pvesh API is the primary method for network configuration
- **Interface Management**: `/etc/network/interfaces` with Proxmox SDN abstraction
- **API Compatibility**: Full pvesh API support for SDN operations

### Known Platform Limitations
- **Network bridge management**: pvesh API preferred for SDN operations after interface pinning
- **Bridge persistence**: Requires `-autostart yes` parameter for activation after reboot
- **Network changes**: Must use `pvesh set /nodes/localhost/network` to apply configurations

### Version-Specific Behaviors
- **Proxmox VE 8 vs 9**: pvesh API behavior consistent, but VE 9 requires explicit autostart for bridges
- **Debian 12 vs 13**: Different systemd configurations, but network management via pvesh API
- **API Changes**: Always test pvesh commands against target Proxmox version

### Recommended Approaches by Component

```json
{
  "platform_versions": {
    "proxmox_ve_8": {
      "os": "Debian 12 (Bullseye)",
      "networking": "systemd-networkd available",
      "interface_tools": "pve-network-interface-pinning"
    },
    "proxmox_ve_9": {
      "os": "Debian 13 (Bookworm)",
      "networking": "systemd-networkd disabled by default",
      "interface_tools": "pve-network-interface-pinning",
      "sdn_provisioning": "pvesh API (primary method)",
      "bridge_persistence": "requires -autostart yes"
    }
  },
  "component_approaches": {
    "vm_management": {
      "proxmox_ve_8": "pvesh API",
      "proxmox_ve_9": "pvesh API",
      "reasoning": "Stable across versions",
      "recommended": true
    },
    "network_bridges": {
      "proxmox_ve_8": "pvesh API",
      "proxmox_ve_9": "pvesh API (primary)",
      "reasoning": "SDN abstraction layer provides consistent interface",
      "autostart_required": true
    },
    "interface_renaming": {
      "proxmox_ve_8": "pve-network-interface-pinning",
      "proxmox_ve_9": "pve-network-interface-pinning",
      "reasoning": "Exception for interface naming - use pve-network-interface-pinning",
      "alternative": "none - pinning handles interface consistency"
    },
    "storage_management": {
      "proxmox_ve_8": "pvesh API",
      "proxmox_ve_9": "pvesh API",
      "reasoning": "Consistent behavior",
      "recommended": true
    },
    "firewall_rules": {
      "proxmox_ve_8": "pvesh API",
      "proxmox_ve_9": "pvesh API",
      "reasoning": "Well-supported",
      "recommended": true
    },
    "user_management": {
      "proxmox_ve_8": "pvesh API",
      "proxmox_ve_9": "pvesh API",
      "reasoning": "Standard functionality",
      "recommended": true
    }
  },
  "pve9_sdn_guidelines": {
    "primary_method": "pvesh API",
    "bridge_creation": "pvesh create /nodes/localhost/network -type bridge -bridge_ports <interface> -bridge_vlan_aware yes -autostart yes",
    "single_interface_only": "SDN bridges can only have one physical interface connected",
    "vlan_awareness_required": "bridge_vlan_aware yes is mandatory for SDN functionality",
    "apply_changes": "pvesh set /nodes/localhost/network",
    "verification": "pvesh get /nodes/localhost/network",
    "bridge_persistence": "always include -autostart yes",
    "reboot_handling": "bridges activate automatically after reboot with autostart"
  }
}
```

For programmatic access, this JSON structure can be used to determine the appropriate automation approach based on Proxmox version and component type.

## Proxmox VE 9 SDN Provisioning Guidelines

Based on extensive testing and troubleshooting, the following guidelines ensure reliable SDN network provisioning in Proxmox VE 9. These guidelines apply to SDN bridge creation and management, not interface pinning/renaming.

### Interface Pinning First, Then SDN Provisioning
- **Complete interface pinning** using `pve-network-interface-pinning` before SDN operations
- **Ensure consistent interface names** (eth0, eth1, etc.) before creating bridges
- **SDN provisioning assumes** interfaces are already properly named/pinned

### Primary Method: pvesh API for SDN
- **Always use pvesh** for SDN network operations (bridge creation/management)
- **Use Proxmox's SDN abstraction layer** for all bridge and network management
- **Do not use pvesh** for interface pinning - use `pve-network-interface-pinning` instead

### Bridge Creation Best Practices
```bash
# Always include these parameters for reliable bridge creation:
pvesh create /nodes/localhost/network \
  -type bridge \
  -bridge_ports "eth0" \
  -bridge_vlan_aware yes \
  -autostart yes
```

**Critical Parameters:**
- `-autostart yes`: Ensures bridge activates automatically after reboot
- `-bridge_vlan_aware yes`: **Required** for SDN-capable bridges - enables VLAN support
- `-bridge_ports "eth0"`: **Only one interface** can be connected to an SDN-capable bridge
- `-type bridge`: Specifies SDN bridge type

**Important SDN Guidelines:**
- SDN-capable bridges can only have **one physical interface** connected
- VLAN awareness (`-bridge_vlan_aware yes`) is **mandatory** for SDN functionality
- Multiple VLANs can be configured on the same bridge interface
- Use VLAN tagging for multiple network segments on a single physical link

### Configuration Application
```bash
# Always apply changes after bridge creation:
pvesh set /nodes/localhost/network
```

**Important:** Bridges will show as "Pending changes" in the Proxmox GUI until `pvesh set /nodes/localhost/network` is executed.

### Verification Steps
```bash
# Verify configuration in Proxmox:
pvesh get /nodes/localhost/network

# Verify bridge status after reboot:
ip -br link show type bridge
```

### Common Issues and Solutions
- **Interface pinning fails**: Check `pve-network-interface-pinning` output and system logs
- **Bridge not active after reboot**: Missing `-autostart yes` parameter
- **Pending changes in GUI**: Forgot to run `pvesh set /nodes/localhost/network`
- **Bridge creation fails**: Check interface names and ensure they exist
- **Multiple interfaces on SDN bridge**: SDN bridges can only have **one physical interface** connected
- **VLAN issues**: Ensure `-bridge_vlan_aware yes` is set (mandatory for SDN)

### ⚠️ SDN Architecture Limitations

**Critical constraints for SDN bridge configuration:**

| Limitation | Details | Workaround |
|------------|---------|------------|
| **Single Physical Interface** | SDN bridges can only connect to **one physical interface** | Use separate bridges for each physical interface |
| **VLAN Awareness Required** | `-bridge_vlan_aware yes` is **mandatory** for SDN functionality | Always include this parameter |
| **No Pre-tagged VLAN Interfaces** | Cannot use `vmbr0.10` or similar VLAN subinterfaces as bridge ports | Use physical interfaces and let SDN manage VLANs |
| **GUI Pending Changes** | Bridges show "Pending changes" until `pvesh set /nodes/localhost/network` runs | Always apply changes after bridge creation |
| **Autostart Required** | Bridges don't activate after reboot without `-autostart yes` | Include autostart parameter for persistence |
| **Interface Pinning First** | SDN operations fail if interfaces aren't pinned consistently | Always run interface pinning before SDN provisioning |

**Why these limitations exist:**
- SDN provides a virtualization layer over Linux bridging
- Single interface design ensures clean VLAN trunking
- VLAN awareness enables dynamic SDN zone management
- Autostart ensures network availability after system reboots

### Automated Testing
When implementing network provisioning roles, include automated verification:
- Test interface pinning with `pve-network-interface-pinning` first
- Test bridge creation with `pvesh create`
- Apply changes with `pvesh set`
- Reboot and verify with `ip link show`
- Use conditional tasks for automated testing with `provision_reboot_after_config: true`

### Migration from Manual SDN Bridge Creation
If migrating from manual shell-based bridge creation to pvesh API:
1. Ensure interface pinning is working correctly first
2. Replace manual `brctl` commands with pvesh bridge creation
3. Use pvesh API for all SDN bridge management
4. Test thoroughly with reboot cycles to ensure persistence

### Complete SDN Provisioning Workflow Example

Here's a complete example of the recommended workflow from interface pinning through SDN bridge creation:

```bash
# Step 1: Generate and apply interface pinning rules
pve-network-interface-pinning generate
pve-network-interface-pinning apply

# Step 2: Verify interface names are consistent
ip link show | grep -E "^[0-9]+: (eth[0-9]+|eno[0-9]+|ens[0-9]+)"

# Step 3: Create VLAN-aware SDN bridge
pvesh create /nodes/localhost/network \
  -type bridge \
  -iface vmbr2 \
  -bridge_ports eth1 \
  -bridge_vlan_aware yes \
  -autostart yes

# Step 4: Apply network configuration changes
pvesh set /nodes/localhost/network

# Step 5: Verify bridge configuration
pvesh get /nodes/localhost/network | jq '.[] | select(.iface == "vmbr2")'
ip -br link show type bridge

# Step 6: Create SDN zones and VNets (optional, for VLAN segmentation)
# This would be done through the Proxmox web GUI or additional pvesh commands
```

**Key Points:**
- Always run interface pinning **before** SDN operations
- Use physical interfaces (eth0, eth1, etc.) as bridge ports, not VLAN subinterfaces
- Include `-autostart yes` for bridge persistence across reboots
- Run `pvesh set /nodes/localhost/network` to apply changes
- Test bridge status with both `pvesh get` and `ip link show`

### ✅ **Recommended Approach**

Instead of using VLAN interfaces as bridge ports:

1. **Create a VLAN-aware bridge** on a physical NIC:
   ```bash
   pvesh create /nodes/localhost/network \
     -type bridge \
     -iface vmbr2 \
     -bridge_ports eth1 \
     -bridge_vlan_aware 1 \
     -autostart 1
   ```

2. **Use SDN to define VLAN zones and VNets**:
   - Each VNet corresponds to a VLAN ID.
   - VMs can be attached to VNets with VLAN tags.
   - SDN will manage the VLAN tagging and bridge mapping.

3. **Let SDN handle VLANs dynamically**:
   - Avoid manually creating `vmbrX.Y` interfaces unless for host-level access.
   - Use SDN zones and VNets for VM-level VLAN segmentation.

**Why avoid VLAN interfaces as bridge ports?**
VLAN interfaces (e.g., `vmbr0.10`, `vmbr0.20`) are tagged subinterfaces that represent pre-configured VLAN segments. SDN bridges expect trunk ports capable of handling multiple VLANs dynamically through the SDN abstraction layer. Using pre-tagged VLAN interfaces bypasses SDN's VLAN management and can cause conflicts with SDN zone and VNet configurations.

---

### 🧩 TL;DR

| Configuration | SDN-Compatible | Recommended | Rationale |
|---------------|----------------|-------------|-----------|
| `bridge_ports eth1` on VLAN-aware bridge | ✅ Yes | ✅ Yes | Physical trunk port allows SDN VLAN management |
| `bridge_ports vmbr0.10 vmbr0.20` | ❌ No | ❌ Not recommended | Pre-tagged VLAN interfaces bypass SDN abstraction |

---

## Proxmox VE 9 Network Configuration Commands

### Essential pvesh SDN Commands (After Interface Pinning)

```bash
# Network configuration management
pvesh get /nodes/localhost/network                # Show current network configuration
pvesh set /nodes/localhost/network                # Apply pending network changes
pvesh create /nodes/localhost/network             # Create new network interface
pvesh delete /nodes/localhost/network/<iface>     # Delete network interface

# Bridge creation for SDN
pvesh create /nodes/localhost/network -type bridge -bridge_ports "eth0" -bridge_vlan_aware yes -autostart yes
pvesh create /nodes/localhost/network -type bridge -iface vmbr2 -bridge_ports eth1 -bridge_vlan_aware 1 -autostart 1

# Network verification
pvesh get /nodes/localhost/network | jq '.[] | select(.type == "bridge")'  # Show bridges only
ip -br link show type bridge                     # Verify bridge status after configuration

# JSON API examples for programmatic access
pvesh get /nodes/localhost/network --output-format json                    # Get network config as JSON
pvesh get /nodes/localhost/network --output-format json | jq '.[] | select(.type == "bridge" and .bridge_vlan_aware == true)'  # Filter VLAN-aware bridges
pvesh get /nodes/localhost/network --output-format json | jq '.[] | select(.iface | startswith("vmbr"))'  # Find all vmbr interfaces
```

### Essential Device Discovery Commands

```bash
# Network interface enumeration and details
ip link show                                    # List all network interfaces with status
ls -1 /sys/class/net                           # List network device names only (for scripting)
ip addr show                                   # Show IP addresses and interface details
ethtool <interface>                            # Get detailed interface capabilities and status
ethtool -i <interface>                         # Show driver information

# PCI device information
lspci | grep -i ethernet                       # Find Ethernet devices by PCI address
lspci -v -s <pci_address>                      # Detailed PCI device information

# Systemd network status (VE 9: disabled by default)
systemctl status systemd-networkd              # Check if systemd-networkd is running
systemctl is-enabled systemd-networkd          # Check if systemd-networkd is enabled

# Proxmox-specific tools
pve-network-interface-pinning --help           # Show interface pinning tool options
qm list                                        # List all VMs
pct list                                       # List all containers
```

### Network Bridge and VLAN Commands

```bash
# Bridge management
brctl show                                    # Show Linux bridges
brctl showmacs <bridge>                       # Show MAC addresses on bridge
bridge link show                              # Show bridge port information

# VLAN information
ip link show type vlan                         # Show VLAN interfaces
cat /proc/net/vlan/config                     # Show VLAN configuration

# Interface bonding/teaming
cat /proc/net/bonding/<interface>             # Show bonding interface details (if applicable)
```

### System Information Commands

```bash
# Proxmox version and system info
pveversion                                    # Show Proxmox version
uname -a                                      # Kernel version and system info
lsb_release -a                                # Distribution information
cat /etc/debian_version                       # Debian version

# Hardware information
dmidecode -t system                           # System hardware info
dmidecode -t processor                        # CPU information
free -h                                       # Memory information
df -h                                         # Disk usage
```

### Troubleshooting Commands

```bash
# Network troubleshooting
ping -c 4 <host>                              # Basic connectivity test
traceroute <host>                             # Network path tracing
nslookup <hostname>                           # DNS resolution
dig <hostname>                                # Detailed DNS query

# Log inspection
journalctl -u systemd-networkd                 # systemd-networkd logs (if enabled)
dmesg | grep -i eth                           # Kernel messages for Ethernet devices
tail -f /var/log/syslog | grep -i network      # Live network-related syslog

# pvesh troubleshooting
pvesh get /nodes/localhost/network             # Check current network configuration
pvesh get /nodes/localhost/network | jq '.[] | select(.type == "bridge")'  # Show bridges only
ip -br link show type bridge                   # Verify active bridges

# Process and service status
ps aux | grep -E "(dhcp|dns|network)"          # Network-related processes
systemctl list-units --type=service | grep network  # Network services status
```

### Automation-Friendly Commands

```bash
# JSON/Parsable output commands
ip -j link show                               # JSON-formatted interface information
ip -j addr show                               # JSON-formatted address information
lshw -json                                    # Hardware information in JSON
lspci -mm                                     # Machine-readable PCI information

# Device enumeration for scripts
for iface in $(ls /sys/class/net); do
    echo "Interface: $iface"
    ethtool $iface | grep -E "(Speed|Duplex|Link)"
done

# Interface capability detection
for iface in $(ls /sys/class/net); do
    if [ -d "/sys/class/net/$iface/device" ]; then
        pci_addr=$(basename $(readlink /sys/class/net/$iface/device))
        echo "$iface -> $pci_addr"
    fi
done
```

### Proxmox VE 9 Specific Considerations

- **systemd-networkd**: Disabled by default - use traditional `/etc/network/interfaces`
- **Interface pinning**: Use `pve-network-interface-pinning` for persistent naming
- **SDN Provisioning**: pvesh API is the primary method for network configuration after pinning
- **Bridge Persistence**: Always include `-autostart yes` when creating bridges
- **Network Changes**: Use `pvesh set /nodes/localhost/network` to apply configurations
- **Interface naming**: Predictable naming with PCI address mapping
- **Network scripts**: Located in `/etc/network/interfaces.d/` for modular configuration

### Common Device Query Patterns

```yaml
device_discovery_patterns:
  # Find physical interfaces only (exclude bridges, VLANs, etc.)
  physical_interfaces: "ls /sys/class/net | xargs -I {} sh -c 'test -d /sys/class/net/{}/device && echo {}'"
  
  # Get PCI address for interface
  pci_address: "basename $(readlink /sys/class/net/{interface}/device)"
  
  # Check if interface is up
  interface_status: "ip link show {interface} | grep -q 'state UP'"
  
  # Get interface speed
  interface_speed: "ethtool {interface} | grep -oP 'Speed: \K[^ ]+'"
  
  # Find interfaces by driver
  by_driver: "find /sys/class/net -name '*' -exec sh -c 'echo -n \"{}: \"; ethtool -i $(basename {}) | grep driver' \\;"

pvesh_sdn_patterns:
  # Create VLAN-aware bridge with autostart (single physical interface only)
  create_bridge: "pvesh create /nodes/localhost/network -type bridge -bridge_ports '{interface}' -bridge_vlan_aware yes -autostart yes"
  
  # Apply network configuration changes
  apply_changes: "pvesh set /nodes/localhost/network"
  
  # Verify bridge configuration
  verify_bridge: "pvesh get /nodes/localhost/network | jq '.[] | select(.type == \"bridge\" and .iface == \"{bridge_name}\")'"
  
  # Check bridge status after reboot
  check_bridge_status: "ip -br link show type bridge | grep {bridge_name}"
```

## Guidance for LLMs and automated code assistants

**Important**: Before making any infrastructure automation changes, review the "Infrastructure Automation: Ansible vs Proxmox API" section above to choose the appropriate tool for each task type. This ensures consistent architectural decisions across the codebase.

We encourage using automated tools (including LLM-based code assistants) to speed development, but to keep the repository stable please ensure the following when an LLM or automated editor makes changes:

### Best Practices for Automated Changes
- **Small, focused changes**: Prefer narrow PRs that change one role or one small area rather than sweeping edits across many files.
- **Run local checks after any generated change**:
  - `yamllint` for YAML formatting
  - `ansible-lint` for role/playbook best-practices
  - `ansible-playbook --syntax-check` for any playbooks that include edited roles
- **YAML purity**: Do not insert Markdown code fences (```yaml```) inside YAML files. Tasks files must be pure YAML.
- **Document separators**: Avoid duplicate YAML document separators (`---`) inside role task files; if multiple documents are required, split into separate files.
- **Commit messages**: Add an explanatory commit message and PR description summarizing what the assistant changed and why (include the exact files edited).
- **Verification steps**: Where possible include or update small verification steps (syntax checks or a tiny run in `--check` mode) as part of the PR so reviewers can quickly validate correctness.
- **Repository conventions**: Preserve repository conventions (2-space YAML indentation, role layout, `defaults/main.yml` for defaults).

### Structured JSON Snippets for LLM Processing

Use these structured JSON templates to generate consistent automation logic:

```json
{
  "network_provisioning_workflow": {
    "interface_pinning": {
      "command": "pve-network-interface-pinning generate && pve-network-interface-pinning apply",
      "verification": "ip link show | grep -E '^[0-9]+: (eth[0-9]+|eno[0-9]+|ens[0-9]+)'",
      "purpose": "Ensure consistent interface naming before SDN operations"
    },
    "sdn_bridge_creation": {
      "command": "pvesh create /nodes/localhost/network -type bridge -bridge_ports '{interface}' -bridge_vlan_aware yes -autostart yes",
      "parameters": {
        "type": "bridge",
        "bridge_ports": "single physical interface only",
        "bridge_vlan_aware": "yes (mandatory)",
        "autostart": "yes (for persistence)"
      },
      "verification": "pvesh get /nodes/localhost/network | jq '.[] | select(.iface == \"{bridge_name}\")'"
    },
    "configuration_application": {
      "command": "pvesh set /nodes/localhost/network",
      "purpose": "Apply pending network changes to activate configuration"
    }
  },
  "ansible_task_patterns": {
    "pvesh_command_task": {
      "template": {
        "name": "Execute pvesh command",
        "command": "pvesh {{ item.command }} {{ item.parameters | join(' ') }}",
        "with_items": "{{ pvesh_commands }}",
        "register": "pvesh_result",
        "changed_when": "pvesh_result.rc == 0"
      }
    },
    "network_verification_task": {
      "template": {
        "name": "Verify network configuration",
        "command": "pvesh get /nodes/localhost/network",
        "register": "network_config",
        "failed_when": "network_config.rc != 0 or 'error' in network_config.stdout"
      }
    }
  },
  "error_handling_patterns": {
    "pvesh_error_check": {
      "failed_when": "'error' in pvesh_result.stdout or pvesh_result.rc != 0",
      "retries": 3,
      "delay": 5,
      "until": "pvesh_result.rc == 0"
    }
  }
}
```

### Role-Specific LLM Guidance

**For network_provision role:**
- Always check interface pinning status before SDN operations
- Use conditional tasks for reboot verification when `provision_reboot_after_config: true`
- Include both `pvesh get` and `ip link show` verification commands
- Handle "Pending changes" state by ensuring `pvesh set /nodes/localhost/network` execution

**For roles using network bridges:**
- Reference bridge interfaces by name (vmbr0, vmbr1, etc.) rather than assuming creation
- Use `delegate_to: localhost` for pvesh commands targeting the Proxmox host
- Include network connectivity tests after bridge configuration

### Test Harness Recommendations

When developing automation with LLMs, consider these validation approaches:

1. **Syntax Validation**: Always run `ansible-playbook --syntax-check` on generated playbooks
2. **Dry Run Testing**: Use `--check` mode to validate logic without making changes
3. **Idempotency Testing**: Run playbooks multiple times to ensure they don't break on re-execution
4. **Network Isolation**: Test in isolated environments before production deployment

### Error Remediation Checklist
If an automated change introduces a parsing error, the remediation checklist is:

1. Run `ansible-playbook --syntax-check` targeting the playbook that failed to identify the problematic file and line.
2. Inspect the flagged file(s) for stray Markdown fences, duplicate `---` markers, or duplicated blocks.
3. Re-run `yamllint` and `ansible-lint` locally, fix issues, and re-run the syntax check.
4. Check for deprecated YAML constructs or invalid indentation.
5. Verify that role references use relative paths correctly.
6. Test with minimal variable sets to isolate configuration issues.

Including this guidance in PRs created by assistants makes reviews faster and reduces back-and-forth.

---

## Quick Reference

### Automation Decision Matrix

```json
{
  "quick_reference": {
    "use_api_when": [
      "vm_lifecycle_management",
      "cluster_management",
      "sdn_network_provisioning",
      "storage_operations",
      "monitoring_metrics",
      "user_access_management",
      "declarative_infrastructure"
    ],
    "use_shell_when": [
      "interface_pinning_and_renaming",
      "direct_file_operations",
      "low_level_network_config",
      "version_compatibility_issues",
      "complex_shell_logic"
    ],
    "hybrid_approach": {
      "interface_pinning_first": "use pve-network-interface-pinning",
      "then_sdn_provisioning": "use pvesh API for bridges",
      "fallback_to_shell": "api_failures"
    },
    "platform_defaults": {
      "proxmox_ve_8": {
        "interface_renaming": "pve-network-interface-pinning",
        "networking": "systemd-networkd_available"
      },
      "proxmox_ve_9": {
        "interface_renaming": "pve-network-interface-pinning",
        "networking": "ifupdown_system",
        "bridge_autostart": "required"
      }
    },
    "pvesh_sdn_essentials": {
      "note": "Use after interface pinning is complete - single physical interface only",
      "create_bridge": "pvesh create /nodes/localhost/network -type bridge -bridge_ports <interface> -bridge_vlan_aware yes -autostart yes",
      "apply_changes": "pvesh set /nodes/localhost/network",
      "verify_config": "pvesh get /nodes/localhost/network",
      "check_bridges": "ip -br link show type bridge"
    }
  }
}
```

### Essential Commands for Contributors

```bash
# Validation commands (run after any changes)
yamllint roles/*/tasks/*.yml                    # YAML syntax validation
ansible-lint roles/                             # Ansible best practices
ansible-playbook --syntax-check playbook.yml    # Playbook validation

# Testing commands
ansible-playbook --check playbook.yml           # Dry-run execution
ansible-playbook -i inventory playbook.yml --limit target_host  # Limited execution

# Repository maintenance
./scripts/add_llm_guidance_to_roles.sh          # Add LLM guidance to all roles
./scripts/add_llm_guidance_to_roles.sh roles/specific_role  # Add to specific role
```

---
