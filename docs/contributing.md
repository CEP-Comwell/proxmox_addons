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
  - llm_guidance
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
  - [Hybrid Approach](#hybrid-approach-recommended)
  - [Key Decision Factors](#key-decision-factors)
- [Platform-Specific Considerations](#platform-specific-considerations)
  - [Proxmox VE 9 Environment](#proxmox-ve-9-environment)
  - [Known Platform Limitations](#known-platform-limitations)
  - [Version-Specific Behaviors](#version-specific-behaviors)
  - [Recommended Approaches by Component](#recommended-approaches-by-component)
- [Guidance for LLMs and automated code assistants](#guidance-for-llms-and-automated-code-assistants)

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
   - Editing `/etc/network/interfaces`, `/etc/udev/rules.d/`, or system config files
   - Creating custom udev rules for interface renaming
   - Managing systemd services or udev rule reloading

2. **Low-Level Network Configuration**
   - Running `ip link`, `brctl`, or `ethtool` commands for interface management
   - Complex interface detection using `ls -1 /sys/class/net` with filters
   - Manual bridge creation/destruction during troubleshooting

3. **Proxmox Version Compatibility Issues**
   - When Proxmox API behavior changes between versions
   - Working around API limitations or bugs
   - Implementing custom workarounds for specific Proxmox versions

4. **Complex Shell-Based Logic**
   - Parsing `ethtool` output for link speed detection
   - Multi-step operations requiring shell piping or conditional logic
   - One-time setup tasks before API management

### Use Proxmox API When:

1. **VM/Container Lifecycle Management**
   - Creating, starting, stopping VMs/containers
   - Managing VM configurations, disk attachments, network interfaces
   - Bulk operations across multiple VMs

2. **Cluster Management**
   - Managing cluster membership, HA configurations
   - Resource pool management and permissions
   - Backup scheduling and storage management

3. **Network Bridge Management**
   - Creating/managing Linux bridges through Proxmox's abstraction layer
   - Managing bridge properties and attached VMs
   - SDN integration and firewall rules

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

8. **Bootstrap with Shell, Manage with API**
   - Use shell commands for initial network setup and interface renaming
   - Switch to Proxmox API for ongoing VM/network management
   - Example: Shell commands for complex interface renaming logic, API for VM lifecycle

9. **API with Shell Fallbacks**
   - Primary operations via API, shell commands as fallbacks
   - Use API for standard operations, shell for edge cases
   - Log API failures and automatically retry with shell methods

### Key Decision Factors

```yaml
decision_factors:
  stability:
    api_preferred: true
    shell_for: "troubleshooting"
    reasoning: "API for production stability, shell for troubleshooting"
  version_compatibility:
    shell_when: "API changes between Proxmox versions"
    api_fallback: false
  complexity:
    api_for: "simple operations"
    shell_for: "complex parsing/logic"
  idempotency:
    api_better: true
    reasoning: "API generally better for idempotent operations"
  debugging:
    shell_better: true
    reasoning: "Shell commands provide better visibility during development"
```

## Platform-Specific Considerations

### Proxmox VE 9 Environment
- **OS**: Debian 13 (Bookworm)
- **Networking**: systemd-networkd disabled by default
- **Interface Management**: Traditional ifupdown system with `/etc/network/interfaces`
- **API Compatibility**: Some Proxmox VE 8 API calls may behave differently

### Known Platform Limitations
- **`pve-network-interface-pinning`**: Unreliable in Proxmox VE 9 - prefer manual udev rules
- **systemd .link files**: Don't work (systemd-networkd disabled) - use udev rules instead
- **Network bridge management**: Proxmox API preferred for production, shell for complex troubleshooting

### Version-Specific Behaviors
- **Proxmox VE 8 vs 9**: Interface pinning tools may fail in VE 9 - fallback to manual methods
- **Debian 12 vs 13**: Different systemd configurations and network management approaches
- **API Changes**: Always test API calls against target Proxmox version before production use

### Recommended Approaches by Component

```json
{
  "platform_versions": {
    "proxmox_ve_8": {
      "os": "Debian 12 (Bullseye)",
      "networking": "systemd-networkd available",
      "interface_tools": "pve-network-interface-pinning reliable"
    },
    "proxmox_ve_9": {
      "os": "Debian 13 (Bookworm)",
      "networking": "systemd-networkd disabled by default",
      "interface_tools": "pve-network-interface-pinning unreliable",
      "interface_management": "traditional ifupdown with /etc/network/interfaces"
    }
  },
  "component_approaches": {
    "vm_management": {
      "proxmox_ve_8": "API",
      "proxmox_ve_9": "API",
      "reasoning": "Stable across versions",
      "recommended": true
    },
    "network_bridges": {
      "proxmox_ve_8": "API",
      "proxmox_ve_9": "API/Shell",
      "reasoning": "API for standard ops, shell for complex configs",
      "fallback_method": "shell"
    },
    "interface_renaming": {
      "proxmox_ve_8": "pve-network-interface-pinning",
      "proxmox_ve_9": "udev rules",
      "reasoning": "Tool unreliable in VE 9",
      "alternative": "manual udev rules"
    },
    "storage_management": {
      "proxmox_ve_8": "API",
      "proxmox_ve_9": "API",
      "reasoning": "Consistent behavior",
      "recommended": true
    },
    "firewall_rules": {
      "proxmox_ve_8": "API",
      "proxmox_ve_9": "API",
      "reasoning": "Well-supported",
      "recommended": true
    },
    "user_management": {
      "proxmox_ve_8": "API",
      "proxmox_ve_9": "API",
      "reasoning": "Standard functionality",
      "recommended": true
    }
  },
  "known_limitations": {
    "pve_network_interface_pinning": {
      "status": "unreliable",
      "affected_versions": ["proxmox_ve_9"],
      "recommended_alternative": "manual udev rules"
    },
    "systemd_link_files": {
      "status": "not_working",
      "reason": "systemd-networkd disabled",
      "recommended_alternative": "udev rules"
    },
    "network_bridge_management": {
      "production": "proxmox_api",
      "troubleshooting": "shell_commands"
    }
  }
}
```

For programmatic access, this JSON structure can be used to determine the appropriate automation approach based on Proxmox version and component type.

## Proxmox VE 9 CLI Commands and Device Queries

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

# Udev and device naming
udevadm info -a -n <interface>                 # Complete udev attributes for interface
udevadm info -q property -n <interface>        # Udev properties only
find /etc/udev/rules.d -name "*net*" -exec cat {} \;  # Show network udev rules

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
journalctl -u systemd-udev                     # udev service logs
dmesg | grep -i eth                           # Kernel messages for Ethernet devices
tail -f /var/log/syslog | grep -i network      # Live network-related syslog

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
- **Interface naming**: Predictable naming with PCI address mapping
- **udev rules**: Essential for custom interface renaming (PCI address to ethX mapping)
- **pve-network-interface-pinning**: May be unreliable - prefer manual udev rules
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

### Error Remediation Checklist
If an automated change introduces a parsing error, the remediation checklist is:

1. Run `ansible-playbook --syntax-check` targeting the playbook that failed to identify the problematic file and line.
2. Inspect the flagged file(s) for stray Markdown fences, duplicate `---` markers, or duplicated blocks.
3. Re-run `yamllint` and `ansible-lint` locally, fix issues, and re-run the syntax check.

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
      "storage_operations",
      "monitoring_metrics",
      "user_access_management",
      "declarative_infrastructure"
    ],
    "use_shell_when": [
      "direct_file_operations",
      "low_level_network_config",
      "version_compatibility_issues",
      "complex_shell_logic"
    ],
    "hybrid_approach": {
      "bootstrap_with_shell": "initial_setup",
      "manage_with_api": "ongoing_operations",
      "fallback_to_shell": "api_failures"
    },
    "platform_defaults": {
      "proxmox_ve_8": {
        "interface_renaming": "pve-network-interface-pinning",
        "networking": "systemd-networkd_available"
      },
      "proxmox_ve_9": {
        "interface_renaming": "udev_rules",
        "networking": "ifupdown_system"
      }
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
