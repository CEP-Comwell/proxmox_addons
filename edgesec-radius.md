src/
tests/

# edgesec-RADIUS Role

## Overview
Implements a modular, multi-tenant, certificate-based authentication system for Proxmox environments. Integrates with Vault, Authentik, Smallstep CA, FreeRADIUS, NetBox, and the edgesec-REST backend.

## Features
- Vault namespace and PKI engine setup per tenant
- Device enrollment via Authentik (OIDC)
- Automated certificate issuance with Smallstep CA
- Device registration and metadata updates in NetBox
- FreeRADIUS reload and configuration sync for EAP-TLS authentication
- Integration with the edgesec-REST backend for device enrollment and orchestration

## Quick Start
1. **Configure endpoints and credentials:**
	 - Define Vault, Authentik, Smallstep CA, NetBox, and FreeRADIUS settings in `defaults/main.yml` or group/host vars.
2. **Include the role in your playbook:**
	 ```yaml
	 - hosts: all
		 roles:
			 - edgesec-radius
	 ```
3. **Run the playbook:**
	 ```bash
	 ansible-playbook -i inventory your_playbook.yml
	 ```
4. **Integration with backend:**
	- The role can call the edgesec-REST backend via REST API or CLI for device enrollment and certificate operations.
	 - Example:
		 ```yaml
		 - name: Enroll device via REST backend
			 uri:
				 url: "http://localhost:3000/enroll"
				 method: POST
				 body_format: json
				 body:
					 device_id: "{{ inventory_hostname }}"
				 status_code: 200
		 ```

## Configuration
- All endpoints, tokens, and tenant settings should be defined in `defaults/main.yml`, group_vars, or host_vars.
- Use Ansible Vault to encrypt sensitive variables.

## Integration Points
- Interfaces with Vault for secrets and PKI management.
- Calls Authentik for OIDC-based device enrollment.
- Issues certificates via Smallstep CA.
- Updates device metadata in NetBox.
- Reloads FreeRADIUS for EAP-TLS authentication.
- Communicates with edgesec-REST backend for device orchestration.

## References
- [import/edgesec-radius.md](import/edgesec-radius.md) — Conceptual design and architecture
- [edgesec-REST Backend](edgesec-rest/README.md)
- [edgesec-Vault](edgesec-vault/README.md)
- [docs/integration-guide.md](docs/integration-guide.md)
- [docs/security-best-practices.md](docs/security-best-practices.md)
