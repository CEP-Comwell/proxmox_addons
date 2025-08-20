# Feature-Gap Analysis: Forking washyu/ansible-mcp-server for edgesec-REST/MCP

## Core Features in washyu/ansible-mcp-server
- Model Context Protocol (MCP) REST API
- Context-driven orchestration
- Ansible playbook execution via API
- Basic inventory/context management
- Python/Flask backend

---

## Required/Desired Features for edgesec-REST/MCP

### 1. Inventory & Source Integration
**Gaps:**
- No native support for Datto RMM, NetBox, or other external inventory sources.
- No dynamic inventory aggregation or enrichment from multiple APIs.
- No inventory normalization (e.g., mapping RMM/NetBox/Proxmox data to a unified model).

**Actions:**
- Implement connectors for Datto RMM, NetBox, Proxmox, and other sources.
- Add inventory normalization and caching logic.

---

### 2. Security, RBAC, and Multi-Tenancy
**Gaps:**
- Minimal or no authentication/authorization (RBAC, OAuth, SSO).
- No multi-tenant context isolation or namespace support.
- No audit logging or compliance features.

**Actions:**
- Integrate authentication (JWT, OAuth2, SSO).
- Add RBAC and tenant-aware context management.
- Implement audit/event logging.

---

### 3. API & Protocol Coverage
**Gaps:**
- Limited to MCP endpoints; may lack endpoints for custom workflows, health checks, or integration triggers.
- No support for webhooks, event-driven automation, or async job status.

**Actions:**
- Extend API for custom endpoints, health, and event hooks.
- Add async job management and status endpoints.

---

### 4. Orchestration & Automation
**Gaps:**
- Tightly coupled to Ansible; no abstraction for other automation engines (e.g., Salt, custom scripts).
- No workflow/pipeline orchestration (multi-step, conditional logic).
- No rollback or error-handling strategies.

**Actions:**
- Abstract orchestration layer for pluggable engines.
- Add workflow/pipeline support.
- Implement error handling and rollback.

---

### 5. Data Model & Context
**Gaps:**
- MCP model may not cover all your edge security, SDN, secrets, and compliance concepts.
- No schema validation or versioning for context models.

**Actions:**
- Extend MCP data model for your domain (SDN, Vault, RADIUS, etc.).
- Add schema validation and context versioning.

---

### 6. Integration & Extensibility
**Gaps:**
- No plugin/module system for easy extension.
- No built-in support for secrets management (Vault), notifications, or external API calls.

**Actions:**
- Add plugin/module architecture.
- Integrate with Vault, notification systems, and external APIs.

---

### 7. Observability & Operations
**Gaps:**
- No built-in metrics, tracing, or monitoring endpoints.
- No admin UI or dashboard.

**Actions:**
- Add Prometheus metrics, logging, and tracing.
- Optionally, build a simple admin UI.

---

### 8. DevOps & CI/CD
**Gaps:**
- May lack Dockerization, CI/CD pipeline templates, or deployment scripts.
- No automated tests for new integrations.

**Actions:**
- Add Dockerfile, CI/CD configs, and test coverage for new features.

---

## Summary Table

| Area                | Present in MCP Server | Gap/Needed for edgesec-REST/MCP         |
|---------------------|----------------------|-----------------------------------------|
| MCP REST API        | Yes                  | Extend for custom endpoints             |
| Ansible Integration | Yes                  | Abstract for other engines (optional)   |
| Inventory           | Basic                | Add Datto RMM, NetBox, Proxmox, etc.    |
| Security/RBAC       | Minimal              | Add auth, RBAC, multi-tenancy           |
| Multi-Tenancy       | No                   | Add context isolation                   |
| Audit/Logging       | Minimal              | Add audit/event logging                 |
| Data Model          | MCP only             | Extend for SDN, Vault, RADIUS, etc.     |
| Workflow/Pipeline   | No                   | Add workflow/pipeline support           |
| Observability       | Minimal              | Add metrics, tracing, admin UI          |
| Extensibility       | No                   | Add plugin/module system                |
| DevOps/CI           | Basic                | Add Docker, CI/CD, tests                |

---

**Conclusion:**

washyu/ansible-mcp-server provides a strong MCP/Ansible API foundation, but you’ll need to extend it for inventory integration, security, multi-tenancy, richer data models, and operational features to fully meet your edgesec-REST/MCP concept.

