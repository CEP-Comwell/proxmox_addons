# edgesec-SDN

<table>
  <tr>
    <td align="left" valign="top" style="min-width:240px;">
      This directory contains playbooks, Docker Compose files, and documentation for the edgesec-SDN (Software Defined Networking) automation stack.
    </td>
    <td align="right" valign="top">
      <img src="../blob/images/multi-site-sdn-fabric.png" alt="Multi-site Proxmox SDN Architecture" width="600" />
    </td>
  </tr>
</table>

## Playbooks

Located in `playbooks/`:
- `provision_network.yml`: **Phase 1** - Single node VXLAN setup, creates VLAN-aware bridges and SDN zones.
- `preflight_connectivity.yml`: **Phase 2** - Connectivity verification between nodes before fabric finalization.
- `establish_fabric.yml`: **Phase 3** - Fabric finalization with VNI mappings and EVPN overlay establishment.
- `site1_bootstrap.yml`, `site2_bootstrap.yml`, `site3_bootstrap.yml`: Per-site bootstrap playbooks for multi-site SDN deployment.

## Multi-Phase SDN Provisioning Process

This SDN implementation follows a structured 3-phase approach using Proxmox VE 9's pvesh API for reliable SDN deployment:

### 🏗️ Phase 1: Single Node VXLAN Setup (`provision_network.yml`)
**Purpose**: Provision local bridges and SDN infrastructure on individual nodes.

**Key Actions**:
- Create VLAN-aware SDN bridges (vmbr99: Management, vmbr1: Tenant, vmbr2: Gateway)
- Establish SDN fabric and EVPN controller
- Create SDN zones and VNets
- Apply network and SDN configuration changes

**Command Example**:
```bash
ansible-playbook -i ../../inventory playbooks/provision_network.yml
```

### 🔍 Phase 2: Connectivity Check (`preflight_connectivity.yml`)
**Purpose**: Verify reachability and configuration before cluster-wide fabric activation.

**Key Actions**:
- Ping test all Proxmox nodes
- Check FRR BGP session status
- Verify network interfaces and bridge status
- Validate SDN configuration existence

**Command Example**:
```bash
ansible-playbook -i ../../inventory playbooks/preflight_connectivity.yml
```

### 🧱 Phase 3: Fabric Finalization (`establish_fabric.yml`)
**Purpose**: Establish VNI mappings and finalize EVPN overlays across the cluster.

**Key Actions**:
- Add node interfaces to SDN fabric
- Create SDN subnets (optional)
- Apply final SDN configuration
- Test VNet connectivity

**Command Example**:
```bash
ansible-playbook -i ../../inventory playbooks/establish_fabric.yml
```

### 📋 SDN Architecture Overview

- **Bridges**: vmbr99 (Management), vmbr1 (Tenant), vmbr2 (Gateway)
- **Fabric**: OpenFabric-based SDN with EVPN controller
- **Zones**: tenant-zone (VRF-VXLAN 100), gateway-zone (VRF-VXLAN 200)
- **VNets**: tenant-vnet (VLAN 10), gateway-vnet (VLAN 20)
- **Controller**: EVPN core with ASN 65000

### ⚠️ Important Notes

- Always run interface pinning **before** SDN operations
- Use `bridge_vlan_aware yes` for all SDN bridges
- Apply changes with `pvesh set /nodes/localhost/network` and `pvesh set /cluster/sdn`
- Avoid VLAN subinterfaces (vmbr0.10) as bridge ports
- Test connectivity between phases to ensure reliability

## Docker Compose

Place SDN-related Docker Compose files in the `docker/` subdirectory. Each file should be named and documented for its specific purpose (e.g., `docker-compose.sdn.yml`).

## Usage

### Multi-Phase SDN Deployment

Follow this structured 3-phase approach for reliable SDN deployment:

#### Phase 1: Single Node Setup
```bash
# Provision local bridges and SDN infrastructure on individual nodes
ansible-playbook -i ../../inventory playbooks/provision_network.yml

# Optional: Limit to specific nodes
ansible-playbook -i ../../inventory playbooks/provision_network.yml --limit proxmox-node-1
```

#### Phase 2: Connectivity Verification
```bash
# Verify reachability between nodes before fabric finalization
ansible-playbook -i ../../inventory playbooks/preflight_connectivity.yml

# Check specific node connectivity
ansible-playbook -i ../../inventory playbooks/preflight_connectivity.yml --limit proxmox-node-1
```

#### Phase 3: Fabric Finalization
```bash
# Establish VNI mappings and finalize EVPN overlays
ansible-playbook -i ../../inventory playbooks/establish_fabric.yml

# Apply to specific nodes only
ansible-playbook -i ../../inventory playbooks/establish_fabric.yml --limit proxmox-node-1,proxmox-node-2
```

### Complete Deployment Workflow
```bash
# Full SDN deployment (run phases sequentially)
cd /path/to/proxmox_addons

# Phase 1: Setup individual nodes
ansible-playbook -i inventory edgesec-sdn/playbooks/provision_network.yml

# Phase 2: Verify connectivity
ansible-playbook -i inventory edgesec-sdn/playbooks/preflight_connectivity.yml

# Phase 3: Finalize fabric
ansible-playbook -i inventory edgesec-sdn/playbooks/establish_fabric.yml
```

### Advanced Usage Examples

#### Dry Run Testing
```bash
# Test playbook syntax and logic without making changes
ansible-playbook -i ../../inventory playbooks/provision_network.yml --check

# Show what would be changed
ansible-playbook -i ../../inventory playbooks/provision_network.yml --check --diff
```

#### Verbose Output
```bash
# Run with detailed output for troubleshooting
ansible-playbook -i ../../inventory playbooks/provision_network.yml -v

# Maximum verbosity
ansible-playbook -i ../../inventory playbooks/provision_network.yml -vvv
```

#### Selective Execution
```bash
# Run only specific tags
ansible-playbook -i ../../inventory playbooks/provision_network.yml --tags bridges

# Skip specific tags
ansible-playbook -i ../../inventory playbooks/provision_network.yml --skip-tags verification
```

#### Parallel Execution
```bash
# Run on multiple nodes simultaneously (default)
ansible-playbook -i ../../inventory playbooks/provision_network.yml

# Limit parallelism
ansible-playbook -i ../../inventory playbooks/provision_network.yml --forks 2
```

### Prerequisites

1. **Interface Pinning**: Ensure network interfaces are properly pinned before SDN operations
2. **Inventory Setup**: Configure your `inventory` file with correct host groups and variables
3. **SSH Access**: Verify SSH connectivity to all Proxmox nodes
4. **Permissions**: Ensure Ansible has sudo privileges on target nodes

### Troubleshooting

#### Common Issues
- **"Pending changes" in Proxmox GUI**: Run `pvesh set /nodes/localhost/network` to apply changes
- **Bridge not active**: Ensure `-autostart yes` parameter is used
- **VLAN issues**: Verify `bridge_vlan_aware yes` is set on all SDN bridges
- **Connectivity failures**: Check physical network connections and interface pinning

#### Verification Commands
```bash
# Check bridge status
ip -br link show type bridge

# Verify SDN configuration
pvesh get /cluster/sdn

# Check network configuration
pvesh get /nodes/localhost/network

# Test BGP sessions (if using FRR)
vtysh -c "show bgp summary"
```

### Docker Compose Integration

1. Edit inventory and config files as needed.
2. Run playbooks from the `playbooks/` directory.
3. Use Docker Compose files from the `docker/` directory for SDN-related services.

See the main repo README and `Fabric_bootstrap.md` for more details.



## Security Model

<details>
<summary><strong>Defense-in-Depth Security Model (click to expand)</strong></summary>

```mermaid
flowchart TD
  %% Layer Definitions
  A[Layer 1: Outer Perimeter<br/>Physical Site Security]:::outer
  B[Layer 2: Facility Core<br/>Server/AI Hardware Room]:::facility
  C[Layer 3: Network Isolation<br/>Air-Gap Enforcement]:::isolation
 
  D1[Layer 4a: ENROLL VLAN<br/>Quarantine / NAC / RADIUS]:::enroll
  D2[Layer 4b: GUEST VLAN<br/>Internet-Only, Segregated]:::guest
  D3[Layer 4c: LAN VLAN<br/>Trusted Ops Network]:::lan
 
  E[Layer 5: Logical Access Zone<br/>RBAC-Tenant APIs]:::logical
  F[Layer 6: Data Sensitivity Core<br/>Model Weights & Sensitive Data]:::core
 
  X[(No Internal Access)]:::noaccess
 
  %% Flow
  A --> B --> C
  C --> D1 --> D3 --> E --> F
  C --> D2
  D2 -.segregated.-> X
 
  %% Role Swimlanes (color ties to RBAC)
  classDef outer fill:#d9e6f2,stroke:#1b4d89,stroke-width:2px;
  classDef facility fill:#b7d7a8,stroke:#38761d,stroke-width:2px;
  classDef isolation fill:#ffe599,stroke:#b45f06,stroke-width:2px;
  classDef enroll fill:#f9cb9c,stroke:#783f04,stroke-width:2px;
  classDef guest fill:#f4cccc,stroke:#990000,stroke-width:2px;
  classDef lan fill:#cfe2f3,stroke:#134f5c,stroke-width:2px;
  classDef logical fill:#d5a6bd,stroke:#741b47,stroke-width:2px;
  classDef core fill:#b4a7d6,stroke:#351c75,stroke-width:2px;
  classDef noaccess fill:#eeeeee,stroke:#999999,stroke-dasharray: 5 5;
 
  %% Role Legends
  click A "Role: None" _blank
  click B "Role: Engineering" _blank
  click C "Roles: Engineering, Management (supervised)" _blank
  click D1 "Roles: Engineering (admin), Support" _blank
  click D2 "Roles: Tenant roles, guests" _blank
  click D3 "Roles: All internal RBAC roles" _blank
  click E "Roles: TenantID, Tenant‑Role1/2, Support, Mgmt, Eng" _blank
  click F "Roles: Engineering (write/manage), Mgmt (read)" _blank
```


</details>

<details>
<summary><strong>RBAC-to-DiD Mapping (click to expand)</strong></summary>

```mermaid
flowchart LR
  %% Swimlanes for roles
  subgraph ENG[Engineering]
    E1[Physical Site Access]:::outer
    E2[Facility Core]:::facility
    E3[Air-Gap Control]:::isolation
    E4[ENROLL VLAN Admin]:::enroll
    E5[LAN VLAN Ops]:::lan
    E6[Logical API Mgmt]:::logical
    E7[Core Data Write]:::core
  end
 
  subgraph MGT[Management]
    M1[Supervised Facility Entry]:::facility
    M2[Air-Gap Oversight]:::isolation
    M3[Logical API Read]:::logical
    M4[Core Data Read]:::core
  end
 
  subgraph SUP[Support]
    S1[ENROLL VLAN Support]:::enroll
    S2[Logical API Support Access]:::logical
  end
 
  subgraph TEN[Tenants / Guests]
    T1[Guest VLAN Access]:::guest
    T2[Logical Tenant API]:::logical
  end
 
  %% Flows within roles
  E1 --> E2 --> E3 --> E4 --> E5 --> E6 --> E7
  M1 --> M2 --> M3 --> M4
  S1 --> S2
  T1 --> T2
 
  %% Zone color definitions
  classDef outer fill:#d9e6f2,stroke:#1b4d89,stroke-width:2px;
  classDef facility fill:#b7d7a8,stroke:#38761d,stroke-width:2px;
  classDef isolation fill:#ffe599,stroke:#b45f06,stroke-width:2px;
  classDef enroll fill:#f9cb9c,stroke:#783f04,stroke-width:2px;
  classDef guest fill:#f4cccc,stroke:#990000,stroke-width:2px;
  classDef lan fill:#cfe2f3,stroke:#134f5c,stroke-width:2px;
  classDef logical fill:#d5a6bd,stroke:#741b47,stroke-width:2px;
  classDef core fill:#b4a7d6,stroke:#351c75,stroke-width:2px;
```

</details>

| **Zone / Layer**                               | **Engineering**   | **Management**   | **Support**   | **Tenants / Guests** |
|-----------------------------------------------|-------------------|------------------|---------------|----------------------|
| Outer Perimeter (Physical)                    | ✅ Full           | ❌               | ❌            | ❌                   |
| Facility Core (Server/AI Room)                | ✅ Full           | ✅ Supervised    | ❌            | ❌                   |
| Network Isolation (Air‑Gap)                   | ✅ Admin          | ✅ Oversight     | ❌            | ❌                   |
| ENROLL VLAN (Quarantine)                      | ✅ Admin          | ❌               | ✅ Support    | ❌                   |
| GUEST VLAN (Internet‑Only)                    | ❌                | ❌               | ❌            | ✅                   |
| LAN VLAN (Trusted Ops)                        | ✅ Ops            | ❌               | ❌            | ❌                   |
| Logical Access Zone (RBAC APIs)               | ✅ Admin/Mgmt     | ✅ Read          | ✅ Support    | ✅ Tenant API        |
| Data Sensitivity Core (Weights/Data)          | ✅ Write/Manage   | ✅ Read          | ❌            | ❌                   |
 

## Future Integration:

The edgesec-SDN automation platform is designed for seamless integration with organizational intelligence and external APIs. Planned future integrations include:

- **edgesec-REST:**
  - Centralizes all SDN decisions (subnet selection, VXLAN ID, firewall rules) using AI-driven and organizational policy logic.
  - Ansible playbooks will query edgesec-REST for dynamic recommendations, ensuring compliance, agility, and security.
  - Enables policy-driven, real-time automation—playbooks become thin clients executing org-approved actions.

- **Netbox:**
  - Used for authoritative IPAM, device, and network topology data.
  - Playbooks will register, update, or decommission resources in Netbox as part of the workflow.

- **Netbird API:**
  - Automates remote access provisioning for users and devices.
  - Playbooks will request, manage, and revoke secure remote access via Netbird, as directed by edgesec-REST or org policy.

**Benefits:**
- Centralized, AI-augmented decision-making for all SDN actions.
- Consistent, policy-compliant automation across the organization.
- Rapid adaptation to changing org needs—update logic in edgesec-REST, not in every playbook.
- Full auditability and security for all automated actions.
