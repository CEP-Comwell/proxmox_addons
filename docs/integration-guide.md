
# edgesec Platform Integration Guide

This guide explains how the major subprojects of the edgesec HCI platform interact, share data, and integrate securely.

# Naming Convention: All subprojects and references must use the lower-case prefix `edgesec-` (e.g., `edgesec-SDN`, `edgesec-TAPx`). Do not use any variations in capitalization or spelling.

- **edgesec-VAULT:** Central source of truth for credentials and secrets, used by RADIUS, REST backend, and SDN fabric roles.
- **edgesec-RADIUS:** Authenticates devices and users, issues certificates, and updates NetBox metadata. Interfaces with Vault and REST backend.
- **edgesec-REST:** Device enrollment backend, provides API/CLI for device onboarding, certificate requests, and metadata updates. Integrates with Vault and RADIUS.
- **edgesec-TAPx:** Modular traffic mirroring with SIEM-triggered full packet visibility. Integrates with SDN fabric and can be triggered by SIEM or security events for dynamic packet capture and analysis.
- **edgesec-SDN:** Uses Ansible roles to automate network provisioning, can consume secrets from Vault and update device metadata via REST backend.
- **NetBox:** Source of truth for device metadata, referenced by RADIUS and SDN fabric roles.

## Example Workflow
1. Device is enrolled via edgesec-REST (API/CLI).
2. REST backend requests certificate from edgesec-VAULT (using tenant namespace).
3. RADIUS role configures authentication and updates NetBox with device metadata.
4. SDN fabric roles provision network, referencing device metadata and secrets from edgesec-VAULT.
5. edgesec-TAPx can be invoked to mirror traffic for enrolled devices, supporting security operations and SIEM workflows.

## Best Practices
- Use Vault namespaces for tenant isolation.
- Secure all API endpoints and CLI tools with authentication.
- Use Ansible Vault for sensitive playbook variables.
- Document integration flows in each subproject README.

## References
- [architecture.md](architecture.md)
- [security-best-practices.md](security-best-practices.md)
