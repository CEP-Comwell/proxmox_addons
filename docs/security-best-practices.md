# EdgeSec Platform Security Best Practices

## Secrets Management
- Use HashiCorp Vault for all credentials, API tokens, and certificates.
- Create isolated namespaces for each tenant in Vault.
- Use Ansible Vault to encrypt sensitive playbook variables and inventory files.

## Secure Deployment
- Never commit secrets or credentials to version control.
- Limit access to configuration and inventory files to trusted users.
- Regularly rotate credentials and audit playbooks for exposure.
- Use role-based access control (RBAC) in Vault and NetBox.

## Compliance & Auditing
- Enable Vault audit devices for tracking access and changes.
- Log all device enrollment and certificate issuance events.
- Document and review integration flows for compliance.

## References
- [Vault Documentation](https://developer.hashicorp.com/vault/docs)
- [Ansible Vault Documentation](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
- [NetBox Security](https://netbox.readthedocs.io/en/stable/administration/security/)
