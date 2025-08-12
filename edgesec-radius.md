# EdgeSec-RADIUS Role

This role automates multi-tenant, certificate-based authentication using HashiCorp Vault, Authentik, Smallstep CA, FreeRADIUS, and NetBox.

- Vault namespace and PKI engine setup
- Device enrollment via Authentik (OIDC)
- Automated certificate issuance with Smallstep CA
- Device registration in NetBox
- FreeRADIUS reload for EAP-TLS authentication

See `import/edgesec-radius.md` for architecture and details.
