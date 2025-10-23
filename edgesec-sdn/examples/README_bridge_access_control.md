# SDN Bridge Access Control with NFTables

**⚠️ MIGRATED TO ROLE**: This functionality has been moved to the `nftables` Ansible role for better reusability and maintainability. See [NFTables Role Documentation](../../roles/nftables/README.md) for current usage.

This directory contains legacy examples and documentation for configuring secure bridge access control using NFTables in Proxmox VE SDN environments.

## Overview

The bridge access control system implements tenant isolation with the following security model:

- **Management Bridge (vmbr99)**: Full access to all tenant and gateway bridges
- **Tenant Bridge (vmbr1)**: Restricted to management bridge only (no cross-tenant communication)
- **Gateway Bridge (vmbr2)**: Restricted to management bridge only (no cross-tenant communication)

## Files

### Configuration Files (Legacy Examples)
- `bridge_access_control.json` - JSON examples showing ingress/egress rule structures
- `bridge_access_control_vars.yml` - Legacy Ansible variables (now in role defaults)
- `vmbr99_access_policy.json` - Management bridge policy overview

### Moved to NFTables Role
- **Playbook**: `nftables_bridge_rules.yml` → Moved to `roles/nftables/`
- **Templates**: Bridge rule templates → Moved to `roles/nftables/templates/`
- **Variables**: Access control variables → Moved to `roles/nftables/defaults/main.yml`

## Usage

### Current Method (Using NFTables Role)

Enable bridge access control in your playbook:

```yaml
- hosts: proxmox-hosts
  vars:
    nftables_configure_bridges: true
  roles:
    - nftables
```

Or use the example playbook:

```bash
ansible-playbook roles/nftables/examples/bridge_access_control.yml
```

### Legacy Method (Deprecated)

The old standalone playbook approach:

```bash
ansible-playbook playbooks/nftables_bridge_rules.yml \
  -e @examples/bridge_access_control_vars.yml
```

**⚠️ Note**: The legacy method is deprecated. Use the nftables role instead for better maintainability.

### Migration from Legacy Playbook

If you were using the old `nftables_bridge_rules.yml` playbook, here's how to migrate:

**Old Way:**
```yaml
- name: Configure NFTables
  import_playbook: edgesec-sdn/playbooks/nftables_bridge_rules.yml
```

**New Way:**
```yaml
- hosts: proxmox-hosts
  vars:
    nftables_configure_bridges: true
  roles:
    - nftables
```

**Variable Migration:**
- `tenants` → `nftables_bridge_access_control`
- Bridge-specific variables → `nftables_bridge_rules`
- Template customization → Override role defaults

### Expected Behavior

After configuration, the following traffic patterns should be observed:

| Source Bridge | Destination Bridge | Status | Description |
|---------------|-------------------|--------|-------------|
| vmbr99 (Management) | vmbr1 (Tenant) | ✅ ALLOWED | Management can access tenant |
| vmbr99 (Management) | vmbr2 (Gateway) | ✅ ALLOWED | Management can access gateway |
| vmbr1 (Tenant) | vmbr99 (Management) | ✅ ALLOWED | Responses only |
| vmbr2 (Gateway) | vmbr99 (Management) | ✅ ALLOWED | Responses only |
| vmbr1 (Tenant) | vmbr2 (Gateway) | ❌ BLOCKED | Tenant isolation |
| vmbr2 (Gateway) | vmbr1 (Tenant) | ❌ BLOCKED | Gateway isolation |

### Testing

Test the configuration by attempting pings between bridges:

```bash
# Should work: Management to Tenant
ping -I vmbr99 <tenant_ip>

# Should work: Management to Gateway
ping -I vmbr99 <gateway_ip>

# Should fail: Tenant to Gateway
ping -I vmbr1 <gateway_ip>

# Should fail: Gateway to Tenant
ping -I vmbr2 <tenant_ip>
```

### Verification

Check that NFTables rules are loaded:

```bash
nft list ruleset | grep -A 20 "table bridge"
```

Verify IP forwarding is enabled:

```bash
sysctl net.ipv4.ip_forward
```

## Customization

### Adding New Tenants

1. Add new bridge configuration to `bridge_access_control_vars.yml`
2. Create corresponding template file (e.g., `vmbr3_rules.nft.j2`)
3. Update the bridges list in the playbook

### Modifying Rules

Edit the `nftables_rules` section in `bridge_access_control_vars.yml`:

```yaml
nftables_rules:
  vmbr1:
    ingress:
      - "iif \"vmbr1\" arp accept"
      - "iif \"vmbr1\" tcp dport 80 accept"
    egress:
      - "iif \"vmbr1\" oif \"vmbr99\" accept"
```

### Advanced Policies

For complex policies, use the JSON format in `bridge_access_control.json` as a reference for implementing:

- Time-based rules
- Rate limiting
- Protocol-specific filtering
- Custom logging

## Security Considerations

- **Default Deny**: All templates end with `drop` rules for unmatched traffic
- **Stateful Inspection**: Established connections are automatically allowed
- **ARP/DHCP**: Essential protocols are permitted for network operation
- **Isolation**: Cross-tenant traffic is explicitly blocked

## Troubleshooting

### Rules Not Applied

1. Check NFTables service status: `systemctl status nftables`
2. Reload rules: `systemctl reload nftables`
3. Verify syntax: `nft -c /etc/nftables.d/vmbr*_rules.nft`

### Traffic Still Allowed

1. Check for overlapping rules in other tables
2. Verify bridge interfaces exist: `ip link show`
3. Test with `nft monitor` to see rule matching

### Performance Issues

- Monitor rule count: `nft list ruleset | wc -l`
- Consider consolidating similar rules
- Use sets for large IP address lists

## Integration

This configuration integrates with:

- **VXLAN Role**: Provides post-reboot verification
- **SDN Setup**: Creates the underlying network infrastructure
- **NFTables Role**: Now handles all bridge access control via `roles/nftables/`
- **Bridge Configuration**: Sets up VLAN-aware bridges

**📖 [Complete NFTables Role Documentation](../../roles/nftables/README.md)**

## References

- [NFTables Documentation](https://wiki.nftables.org/)
- [Proxmox VE SDN](https://pve.proxmox.com/wiki/Software-Defined_Network)
- [Bridge Filtering](https://wiki.nftables.org/wiki-nftables/index.php/Bridge_filtering)