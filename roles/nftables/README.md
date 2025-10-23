# nftables Role

Manages nftables firewall rules for Proxmox environments with support for SDN bridge access control.

## Features

- **Basic Firewall**: Default deny policy with ICMP and management access
- **Bridge Access Control**: Optional SDN bridge isolation with tenant separation
- **IPv4/IPv6 Forwarding**: Automatic configuration for routing
- **Service Management**: Automatic nftables service management and reloading

## Usage

### Basic Usage

Include this role to set up basic nftables rules:

```yaml
- hosts: proxmox-hosts
  roles:
    - nftables
```

### Bridge Access Control

Enable SDN bridge isolation by setting variables:

```yaml
- hosts: proxmox-hosts
  roles:
    - role: nftables
      nftables_configure_bridges: true
```

## Variables

### Basic Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `nftables_default_policy` | `"drop"` | Default policy for input/forward chains |
| `nftables_allow_icmp` | `true` | Allow ICMP and ICMPv6 traffic |
| `nftables_allow_management_to_all` | `true` | Allow management subnet to all destinations |
| `nftables_explicit_rules` | `[]` | List of additional rules to add |

### Bridge Access Control

| Variable | Default | Description |
|----------|---------|-------------|
| `nftables_configure_bridges` | `false` | Enable bridge-specific rules |
| `nftables_bridge_rules_dir` | `"/etc/nftables.d"` | Directory for bridge rule files |
| `nftables_bridges` | See defaults | List of bridges to configure |
| `nftables_bridge_access_control` | See defaults | Access policies per bridge |
| `nftables_bridge_rules` | See defaults | Detailed rules per bridge |

## Bridge Security Model

When `nftables_configure_bridges` is enabled, implements tenant isolation:

- **Management Bridge (vmbr99)**: Full bidirectional access to all tenant/gateway bridges
- **Tenant Bridge (vmbr1)**: Restricted to management bridge only (blocks vmbr2)
- **Gateway Bridge (vmbr2)**: Restricted to management bridge only (blocks vmbr1)

### Traffic Matrix

| Source → Destination | vmbr99 (Management) | vmbr1 (Tenant) | vmbr2 (Gateway) |
|---------------------|-------------------|----------------|----------------|
| vmbr99 (Management) | ✅ N/A | ✅ ALLOWED | ✅ ALLOWED |
| vmbr1 (Tenant) | ✅ ALLOWED (responses) | ✅ N/A | ❌ BLOCKED |
| vmbr2 (Gateway) | ✅ ALLOWED (responses) | ❌ BLOCKED | ✅ N/A |

## Examples

### Custom Rules

```yaml
- hosts: proxmox-hosts
  vars:
    nftables_explicit_rules:
      - "ip saddr 10.0.0.0/24 tcp dport 3306 accept"
      - "ip daddr 192.168.1.0/24 accept"
  roles:
    - nftables
```

### Bridge Configuration Override

```yaml
- hosts: proxmox-hosts
  vars:
    nftables_configure_bridges: true
    nftables_bridge_access_control:
      vmbr99:
        allowed_peers: ["vmbr1", "vmbr2", "vmbr3"]
      vmbr3:
        ingress_policy: "management_only"
        allowed_peers: ["vmbr99"]
  roles:
    - nftables
```

## Testing

### Basic Functionality

```bash
# Check service status
systemctl status nftables

# Verify rules loaded
nft list ruleset

# Test ICMP (should work)
ping -c 3 <target_ip>
```

### Bridge Isolation Testing

```bash
# Should work: Management to Tenant
ping -I vmbr99 <tenant_ip>

# Should fail: Tenant to Gateway
ping -I vmbr1 <gateway_ip>

# Check bridge rules
nft list table bridge vmbr1_filter
```

## File Structure

```
roles/nftables/
├── defaults/
│   └── main.yml                 # Default variables
├── handlers/
│   └── main.yml                 # Service reload handlers
├── tasks/
│   └── main.yml                 # Main role tasks
├── templates/
│   ├── nftables.conf.j2         # Main nftables configuration
│   ├── vmbr99_rules.nft.j2      # Management bridge rules
│   ├── vmbr1_rules.nft.j2       # Tenant bridge rules
│   └── vmbr2_rules.nft.j2       # Gateway bridge rules
└── README.md                    # This file
```

## Dependencies

- `ansible.posix.sysctl` collection for kernel parameter management
- nftables package (automatically installed)

## Troubleshooting

### Rules Not Applied

1. Check service status: `systemctl status nftables`
2. Reload manually: `systemctl reload nftables`
3. Verify syntax: `nft -c /etc/nftables.conf`

### Bridge Rules Missing

1. Confirm `nftables_configure_bridges: true`
2. Check bridge interfaces exist: `ip link show`
3. Verify rule files: `ls -la /etc/nftables.d/`

### Performance Issues

- Monitor rule count: `nft list ruleset | wc -l`
- Consider consolidating similar rules
- Use sets for large IP address lists

## Contributing

See the [root contributing guide](../../docs/contributing.md) for standards and prompt scaffolding.

For a canonical role README checklist/template, see `../../docs/role_readme_template.md`.

## LLM/Code Assistant Guidance

When using LLM assistants or automated code tools to modify this role:

- **Review infrastructure automation guidelines**: Read "Infrastructure Automation: Ansible vs Proxmox API" in `docs/contributing.md`
- Follow the checklist in `docs/role_readme_template.md`
- Test changes with: `ansible-playbook --syntax-check` and `ansible-lint`
- Keep changes focused and include rationale in commit messages