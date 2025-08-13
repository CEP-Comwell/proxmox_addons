# EdgeSec Platform Integration Guide

This guide explains how the major subprojects of the EdgeSec HCI platform interact, share data, and integrate securely.

## Integration Points
- **Vault:** Central source of truth for credentials and secrets, used by RADIUS, REST backend, and SDN fabric roles.
- **EdgeSec-RADIUS:** Authenticates devices and users, issues certificates, and updates NetBox metadata. Interfaces with Vault and REST backend.
- **EdgeSec-REST:** Device enrollment backend, provides API/CLI for device onboarding, certificate requests, and metadata updates. Integrates with Vault and RADIUS.
- **SDN Fabric:** Uses Ansible roles to automate network provisioning, can consume secrets from Vault and update device metadata via REST backend.
- **NetBox:** Source of truth for device metadata, referenced by RADIUS and SDN fabric roles.

## Example Workflow
1. Device is enrolled via EdgeSec-REST (API/CLI).
2. REST backend requests certificate from Vault (using tenant namespace).
3. RADIUS role configures authentication and updates NetBox with device metadata.
4. SDN fabric roles provision network, referencing device metadata and secrets from Vault.

## Best Practices
- Use Vault namespaces for tenant isolation.
- Secure all API endpoints and CLI tools with authentication.
- Use Ansible Vault for sensitive playbook variables.
- Document integration flows in each subproject README.

## References
- [architecture.md](architecture.md)
- [security-best-practices.md](security-best-practices.md)
