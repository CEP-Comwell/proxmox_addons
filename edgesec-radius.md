# EdgeSec-RADIUS Role

Implements a modular, multi-tenant, certificate-based authentication system for Proxmox environments, following the conceptual design in `import/edgesec-radius.md` and best practices from clean architecture.

## Conceptual Overview

- **Multi-Tenancy:** Strong isolation using HashiCorp Vault namespaces and policy constraints.
- **Automated Enrollment:** Device onboarding via Authentik (OIDC), with integration to Vault, Smallstep CA, and NetBox.
- **Certificate Lifecycle:** Automated issuance, renewal, and revocation of X.509 certificates using Vault PKI and Smallstep CA.
- **Metadata Management:** Device records and certificate metadata managed in NetBox.
- **Network Access:** EAP-TLS authentication via FreeRADIUS, with dynamic policy assignment.
- **Infrastructure as Code:** All workflows orchestrated by Ansible, using REST APIs for idempotent automation.
- **Device Enrollment System Integration:** Interfaces with the EdgeSec-REST backend for device enrollment, using REST API or CLI, built with clean architecture and facade patterns.

## Features

- Vault namespace and PKI engine setup per tenant
- Device enrollment via Authentik (OIDC)
- Automated certificate issuance with Smallstep CA
- Device registration and metadata updates in NetBox
- FreeRADIUS reload and configuration sync for EAP-TLS authentication
- Integration with the EdgeSec-REST backend for device enrollment and orchestration

## Quick Start

1. **Configure endpoints and credentials:**  
	Define Vault, Authentik, Smallstep CA, NetBox, and FreeRADIUS settings in `defaults/main.yml` or group/host vars.

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
	The role can call the EdgeSec-REST backend via REST API or CLI for device enrollment and certificate operations. Example:
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

## Device Enrollment System (EdgeSec-REST)

The backend is built using clean architecture and facade patterns for modularity and testability:

- **Application Layer:** Core business logic (EnrollDevice use case)
- **Ports:** IntegrationPort interface for external system interaction
- **Infrastructure Layer:** IntegrationHub facade delegates to adapters
- **Adapters:** DeviceAdapter for low-level API calls to external services
- **Interface:** CLI and REST entry points for triggering use cases

### Key Files & Structure

```
src/
├── application/
│   ├── ports/IntegrationPort.ts
│   └── use-cases/device-enrollment/EnrollDevice.ts
├── infrastructure/
│   └── integrations/
│       ├── adapters/DeviceAdapter.ts
│       └── facades/IntegrationHub.ts
├── cli/
│   └── enrollDeviceCli.ts
tests/
└── modules/
	 ├── device-enrollment/EnrollDevice.test.ts
	 └── device-enrollment/IntegrationHub.test.ts
```

### Testing Strategy
- Module tests for EnrollDevice and IntegrationHub
- Mocked adapters to isolate logic
- Jest used for assertions and coverage

### CLI Runner
- Run with: `npm run enroll <deviceId>`
- Uses mock adapter for simulation
- Great for manual testing and debugging

### Benefits
- Decoupled layers for flexibility
- Fully testable with mocks
- Ready for REST, bot, or other interfaces
- Clean architecture with clear separation of concerns

## Best Practices

- Use dedicated Vault namespaces for each tenant.
- Store secrets and credentials securely (Ansible Vault, environment variables).
- Automate all workflows for repeatability and compliance.
- Use NetBox as the source of truth for device metadata.
- Integrate with EdgeSec-REST for extensible backend logic and orchestration.

## References

See `import/edgesec-radius.md` for full architecture, workflows, and integration details.
