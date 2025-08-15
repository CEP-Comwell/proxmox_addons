<img src="blob/images/edgesec.png" alt="edgesec logo" width="240" align="right"/>  


## PROXMOX_ADDONS


This repository provides advanced Ansible automation and monitoring add-ons for Proxmox-based hyper-converged infrastructure.  
It is organized into modular subprojects, each with its own documentation and roles. 

---

## 📦 Subprojects

---

## 🛰️ edgesec-TAPx

### [edgesec-TAPx](edgesec-tapx/README.md)
*Modular traffic and probe automation for full packet visibility and DPI in Proxmox and Docker environments.*

**Overview:**
Automates probing and mirroring of VM, Docker, VXLAN, and HCI agent network traffic to a monitoring bridge for DPI, IDS, or security analysis. Supports dynamic discovery and persistent setup of tap, Docker, and VXLAN interfaces, with modular roles for each probe type.

**Features:**
- Dynamic discovery of VM, Docker, and VXLAN interfaces
- Automated veth/bridge setup and teardown
- Persistent traffic mirroring and probe routines for DPI/IDS
- Automated cleanup routines for each probe role
- Modular, extensible Ansible roles for each probe type

**Quick Start:**
1. See [edgesec-tapx/README.md](edgesec-tapx/README.md) for setup instructions and usage details.
2. Configure monitoring bridge and interfaces in `config.yml`.
3. Run the relevant probe playbooks to enable mirroring and traffic analysis.

**Configuration Options:**
- Monitoring bridge and interface settings in `config.yml`
- Per-host variables in `host_vars/`

**Integration Points:**
- Integrates with SDN Fabric for network topology
- Supports DPI/IDS tools via mirrored traffic
- Designed for orchestration via edgesec-REST API

**References:**
- [edgesec-tapx/README.md](edgesec-tapx/README.md)
<!-- - [docs/integration-guide.md](docs/integration-guide.md) -->


---

## 🕸️ edgesec-SDN

### [edgesec-SDN](Fabric_bootstrap.md)
*Comprehensive SDN fabric automation for scalable, multi-site Proxmox deployments.*

**Network Architecture:**
- The SDN fabric is built around three primary bridges:
	- `vmbr0` (Management, left): Hosts management, engineering, and support overlays, as well as storage overlays (ceph_pub, ceph_cluster).
	- `vmbr1` (VM/Services, center): Hosts tenant/service overlays and all core service overlays (DNS, Monitoring, Vault, REST, RADIUS).
	- `vmbr2` (External, right): Connects to external gateways and legacy VLANs, and provides external access overlays (proxy_ext, external).
- Overlays (VXLANs) are mapped to these bridges for isolation and segmentation, as shown in the architecture diagram below.


**Reference Diagram (Mermaid):**
```mermaid
graph LR

	%% Bridges (ordered left to right)
	MgmtBridge[vmbr0 - Management Bridge]
	VMBridge[vmbr1 - VM Bridge]
	ExtBridge[vmbr2 - External Bridge]

	%% Services
	VaultVM[edgesec-VAULT]
	MonitorVM[monitor-vm]
	RestVM[edgesec-rest]
	RadiusVM[edgesec-radius]
	DNSVM[edgesec-dns]
	ProxyVM[Traefik Proxy VM]

	%% Overlays
	VX10100[vxlan10100 - Management]
	VX10101[vxlan10101 - Engineering]
	VX10102[vxlan10102 - Support]
	VX10110[vxlan10110 - VM]
	VX10111[vxlan10111 - DNS]
	VX10112[vxlan10112 - Monitoring]
	VX10113[vxlan10113 - Proxy]
	VXCEPH1[vxlan10030 - Ceph Pub]
	VXCEPH2[vxlan10031 - Ceph Cluster]

	Gateway1[Primary Gateway - ISP 1]
	Gateway2[Backup Gateway - ISP 2]
	LegacyVLAN[Legacy VLANs]

	Fabricd[fabricd - IS-IS Routing]

	%% Explicit bridge ordering
	MgmtBridge --> VMBridge --> ExtBridge

	%% Service VMs to bridges
	VaultVM --> MgmtBridge
	MonitorVM --> MgmtBridge
	RestVM --> VMBridge
	RadiusVM --> VMBridge
	DNSVM --> VMBridge
	ProxyVM --> VMBridge
	ProxyVM --> ExtBridge

	%% VM Bridge overlays
	VMBridge --> VX10110
	VMBridge --> VX10111
	VMBridge --> VX10112
	VMBridge --> VX10113

	%% Management Bridge overlays
	MgmtBridge --> VX10100
	MgmtBridge --> VX10101
	MgmtBridge --> VX10102
	MgmtBridge --> VXCEPH1
	MgmtBridge --> VXCEPH2

	%% VXLANs to fabricd
	VX10100 --> Fabricd
	VX10101 --> Fabricd
	VX10102 --> Fabricd
	VX10110 --> Fabricd
	VX10111 --> Fabricd
	VX10112 --> Fabricd
	VX10113 --> Fabricd
	VXCEPH1 --> Fabricd
	VXCEPH2 --> Fabricd

	%% External Bridge to Gateways
	ExtBridge --> Gateway1
	ExtBridge --> Gateway2

	%% External Bridge to Legacy VLANs
	ExtBridge --> LegacyVLAN

	%% Custom bridge colors
	classDef mgmt fill:#e3f2fd,stroke:#1976d2,stroke-width:2px;
	classDef vm fill:#fffde7,stroke:#fbc02d,stroke-width:2px;
	classDef ext fill:#fbe9e7,stroke:#d84315,stroke-width:2px;
	classDef proxy fill:#e8f5e9,stroke:#388e3c,stroke-width:2px;

	class MgmtBridge,VaultVM,MonitorVM,VX10100,VX10101,VX10102,VXCEPH1,VXCEPH2 mgmt;
	class VMBridge,RestVM,RadiusVM,DNSVM,VX10110,VX10111,VX10112,VX10113 vm;
	class ExtBridge,Gateway1,Gateway2,LegacyVLAN ext;
	class ProxyVM proxy;
```
Mermaid source: [`blob/mmd/edgesec-single-tenant-bridges.mmd`](blob/mmd/edgesec-single-tenant-bridges.mmd)

**Features:**
- Automated multi-site fabric bootstrap and configuration
- Spine-leaf topology with OpenFabric integration
- Zero trust, microsegmentation, and RBAC support
- Dynamic inventory and network map generation
	- Integration with edgesec-VAULT for secrets management

**Quick Start:**
1. Review [Fabric_bootstrap.md](Fabric_bootstrap.md) for prerequisites and setup steps.
2. Configure your environment in `inventory` and `config.yml`, ensuring bridge and overlay assignments match the diagram.
3. Run the provided playbooks to deploy the fabric.

**Configuration Options:**
- Centralized settings in `config.yml` (see bridge and overlay variables)
- Per-node and per-site variables in `group_vars/` and `host_vars/`
	- edgesec-VAULT integration for sensitive data

**Integration Points:**
- Works with edgesec-RADIUS for authentication
- Integrates with edgesec-REST backend for device enrollment
- Supports traffic mirroring for DPI/IDS via VM & Docker roles

**References:**
- [Fabric_bootstrap.md](Fabric_bootstrap.md)
<!-- - [docs/architecture.md](docs/architecture.md) -->
<!-- - [docs/integration-guide.md](docs/integration-guide.md) -->


---

## 🆔 edgesec-RADIUS

### [edgesec-RADIUS](edgesec-radius/README.md)
*Multi-tenant, certificate-based authentication and device onboarding.*

**Overview:**
Modular Ansible role for multi-tenant, certificate-based authentication and integration with Vault, Authentik, Smallstep CA, FreeRADIUS, and NetBox.

**Features:**
- Multi-tenant RADIUS authentication
- Certificate-based device enrollment
- Vault and Authentik integration
- Smallstep CA and FreeRADIUS support
- NetBox asset management

**Quick Start:**
1. Review [edgesec-radius/README.md](edgesec-radius/README.md) for setup and requirements.
2. Configure tenants and secrets in Vault and Ansible variables.
3. Deploy the role using the provided playbooks.

**Configuration Options:**
- Tenant and certificate settings in `group_vars/` and `host_vars/`
- Vault integration for secrets

**Integration Points:**
- Works with SDN Fabric for network access control
- Integrates with edgesec-REST for device onboarding

**References:**
- [edgesec-radius/README.md](edgesec-radius/README.md)
<!-- - [docs/security-best-practices.md](docs/security-best-practices.md) -->


---

## 🛡️ edgesec-VAULT

### [edgesec-VAULT](edgesec-vault/README.md)
*Centralized secrets management for the edgesec HCI platform using HashiCorp Vault.*

A HashiCorp Vault deployment for the edgesec HCI platform, serving as the central source of truth for all credentials and secrets. Designed for multi-tenant environments and integrates with the Proxmox SDN Fabric and all edgesec platform components.

**Features:**
- Centralized secrets management for edgesec HCI
- Multi-tenant isolation using Vault namespaces
- Integrates with edgesec-RADIUS, edgesec-REST, and other platform services
- Easy deployment via Docker Compose

**Quick Start:**
1. See [edgesec-vault/README.md](edgesec-vault/README.md) for setup and usage.
2. Start Vault with Docker Compose and initialize/unseal as described.
3. Create tenant namespaces and configure PKI, policies, and authentication as needed.

**References:**
- [Vault Namespaces Documentation](https://developer.hashicorp.com/vault/docs/enterprise/namespaces)
- [Vault Docker Documentation](https://hub.docker.com/_/vault)
- [edgesec-vault/README.md](edgesec-vault/README.md)


---

## 🧩 edgesec-REST

### [edgesec-REST](edgesec-rest/README.md)
*Fastify v5 + TypeScript API hub for edge security automation and orchestration.*

A Fastify v5 + TypeScript API hub for edge security automation and orchestration.  
Key integrations:
- **Datto RMM**: Device inventory ingestion
- **NetBox**: Source of truth for device metadata
- **NetBird**: SDN and ACL automation
- **Proxmox VE 9**: HCI orchestration (VM lifecycle, SDN, ZFS datasets)
- **Ollama + OpenWebUI**: Local LLM inference (Mistral, etc.)
- **Microsoft Teams**: Notifications via Graph API or Workflows webhooks

**Tech Highlights**
- Fastify v5 with JSON Schema validation
- Plugin-based architecture for connectors
- Node.js 20+, TypeScript, ESLint v9 flat config
- Docker & Docker Compose support (optional Ollama/OpenWebUI services)

**Quick Start**
```bash
cd edgesec-rest
npm ci
npm run dev        # start dev server
npm run build      # compile TypeScript
npm start          # run compiled build
```

---

## 🗂 Directory Structure

> **Note:** Each subproject has its own `README.md` and quick start. Roles and playbooks are organized for modular use and cross-integration. The `edgesec-rest` directory is the core integration hub.

```
proxmox_addons/
├── config.yml                # Central configuration for all playbooks and roles
├── inventory                 # Ansible inventory for your environment
├── group_vars/               # Group variables for Ansible
├── host_vars/                # Host-specific variables for Ansible
├── roles/                    # Shared and project-specific Ansible roles
│
├── edgesec-tapx/             # Modular traffic/probe automation (VM, Docker, VXLAN, HCI agent)
│   ├── playbooks/
│   ├── roles/
│   └── README.md
│
├── edgesec-sdn/              # SDN fabric automation (multi-site, overlays, microsegmentation)
│   ├── playbooks/
│   ├── roles/
│   └── README.md
│
├── edgesec-radius/           # Multi-tenant RADIUS authentication and device onboarding
│   ├── playbooks/
│   ├── roles/
│   └── README.md
│
├── edgesec-vault/            # HashiCorp Vault deployment for secrets management
│   ├── docker-compose.yml
│   └── README.md
│
├── edgesec-rest/             # Core integration hub (Fastify v5 + TypeScript API)
│   ├── src/
│   │   ├── server.ts
│   │   ├── plugins/
│   │   ├── routes/
│   │   ├── schemas/
│   │   ├── lib/
│   │   └── tests/
│   ├── package.json
│   ├── tsconfig.json
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── README.md
│
├── Fabric_bootstrap.md       # SDN fabric documentation
├── ...other docs...
└── README.md                 # Main project overview (this file)
```

**Key Integration Hub:**  
- `edgesec-rest/` is the central API and automation hub, integrating with all other subprojects (Vault, SDN, TAPx, RADIUS) and external systems (NetBox, Datto RMM, NetBird, etc).

**Each subproject** has its own `README.md` and quick start, with roles and playbooks organized for modular use and cross-integration.

---

MIT © CEP-Comwell


