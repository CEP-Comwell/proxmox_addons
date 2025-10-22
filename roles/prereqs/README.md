# prereqs Role

## Overview
Installs common prerequisites for Proxmox hosts used by the `network_provision` role. Ensures all required packages and tools are available before network configuration.

## What It Does

- Installs packages listed in `roles/prereqs/defaults/main.yml` (git, make, ethtool, lm-sensors, wget by default)
- Optionally downloads and installs `proxmox-network-interface-pinning` script when `pve_network_interface_pinning_url` is provided
- Validates system compatibility for network provisioning tasks

## Quick Start

### Basic Usage
```yaml
- hosts: proxmox-hosts
  become: true
  roles:
    - prereqs
```

### With Network Provisioning
```yaml
- hosts: proxmox-hosts
  become: true
  roles:
    - prereqs              # Install prerequisites first
    - network_provision    # Then configure network
```

### With Custom Pinning Script
```yaml
- hosts: proxmox-hosts
  become: true
  vars:
    pve_network_interface_pinning_url: "https://example.com/pve-network-interface-pinning"
  roles:
    - prereqs
```

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `prereq_packages` | `[git, ethtool, lm-sensors, wget]` | List of packages to install |
| `pve_network_interface_pinning_url` | `null` | URL to download the pinning script from |
| `pve_network_interface_pinning_path` | `/usr/local/bin/pve-network-interface-pinning` | Installation path for the script |

### Variable Examples

```yaml
# Add custom packages
- hosts: proxmox-hosts
  become: true
  vars:
    prereq_packages:
      - git
      - ethtool
      - lm-sensors
      - wget
      - curl
      - jq
  roles:
    - prereqs

# Download pinning script from custom URL
- hosts: proxmox-hosts
  become: true
  vars:
    pve_network_interface_pinning_url: "https://github.com/example/pinning-script"
  roles:
    - prereqs
```

## Configuration Files

### Package Installation
The role installs packages via `apt` on Debian/Ubuntu-based systems. Default packages:
- **git**: Version control for scripts and configurations
- **ethtool**: Network interface diagnostics and speed detection
- **lm-sensors**: Hardware monitoring (useful for network diagnostics)
- **wget**: Downloading scripts and resources

### PVE Network Interface Pinning Script
When `pve_network_interface_pinning_url` is provided, the script is:
1. Downloaded to a temporary location
2. Made executable (`chmod +x`)
3. Installed to `/usr/local/bin/pve-network-interface-pinning`
4. Verified to be functional

## Usage Examples

### Complete Provisioning Workflow
```yaml
# inventory.ini
[proxmox-hosts]
pve-node1 ansible_host=192.168.1.101
pve-node2 ansible_host=192.168.1.102

# playbook.yml
- name: Complete Proxmox Node Provisioning
  hosts: proxmox-hosts
  become: true
  vars:
    pve_network_interface_pinning_url: "https://example.com/pinning-script"
  roles:
    - prereqs
    - network_provision
```

### Run with Ansible
```bash
# Install prerequisites only
ansible-playbook -i inventory playbook.yml --tags prereqs

# Install prerequisites and configure network
ansible-playbook -i inventory playbook.yml

# Check what packages would be installed
ansible-playbook -i inventory playbook.yml --check
```

## Platform Support

- **Primary**: Debian/Ubuntu-based Proxmox installations
- **Package Manager**: Uses `apt` for package installation
- **Future**: Can be extended for CentOS/RHEL support with `yum`/`dnf`

## Troubleshooting

### Package Installation Fails
Check apt repository status:
```bash
apt update
apt list --upgradable
```

### Pinning Script Download Fails
Verify URL accessibility:
```bash
curl -I "{{ pve_network_interface_pinning_url }}"
wget --spider "{{ pve_network_interface_pinning_url }}"
```

### Script Not Executable
Check permissions after installation:
```bash
ls -la /usr/local/bin/pve-network-interface-pinning
```

## Dependencies

This role has no external dependencies and can run standalone. It's designed to be run before `network_provision` to ensure all required tools are available.

## Contributing
See the [root contributing guide](../../docs/contributing.md) for standards and prompt scaffolding.

For a canonical role README checklist/template, see `../../docs/role_readme_template.md`.
