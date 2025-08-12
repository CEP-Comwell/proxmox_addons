# Certificate-Based Multi-Tenant Authentication Role

This role automates the setup and integration of a multi-tenant, certificate-based authentication system using HashiCorp Vault, Authentik, Smallstep CA, FreeRADIUS, and NetBox.

## Features
- Vault namespace and PKI engine setup for tenant isolation
- Device enrollment via Authentik (OIDC)
- Automated certificate issuance with Smallstep CA
- Device registration in NetBox
- FreeRADIUS reload for EAP-TLS authentication

## Usage
Add `cert_auth` to your playbook roles:

```yaml
- hosts: all
  roles:
    - cert_auth
```

## Variables
See `defaults/main.yml` for configurable options:
- `vault_addr`, `vault_token`, `vault_namespace`
- `authentik_url`, `smallstep_ca_url`, `freeradius_server`, `netbox_url`, `cert_tenant`

## Example Workflow
1. Ensure Vault namespace exists for tenant
2. Configure PKI secrets engine
3. Enroll device in Authentik
4. Issue certificate via Smallstep CA
5. Register device in NetBox
6. Reload FreeRADIUS

## References
See `import/edgesec-radius.md` for conceptual design and architecture.
