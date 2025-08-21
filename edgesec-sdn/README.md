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
- `provision_network.yml`: Main SDN fabric provisioning playbook.
- `site1_bootstrap.yml`, `site2_bootstrap.yml`, `site3_bootstrap.yml`: Per-site bootstrap playbooks for multi-site SDN deployment.
- `preflight_connectivity.yml`: Checks connectivity between all Proxmox nodes before BGP peering.
- `establish_fabric.yml`: Interactive BGP peering and fabric activation.

## Docker Compose

Place SDN-related Docker Compose files in the `docker/` subdirectory. Each file should be named and documented for its specific purpose (e.g., `docker-compose.sdn.yml`).

## Usage

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

[6:33 p.m.] Christopher Peterson
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
