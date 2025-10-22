# Ceph Network Role

Automates Ceph network configuration for Proxmox nodes.

## Usage
Include this role in your playbook to configure Ceph networking.

## Variables
List any variables and defaults here.

## Example
```yaml
- hosts: all
  roles:
    - ceph_network
```

## LLM/Code Assistant Guidance

When using LLM assistants or automated code tools to modify this role:

- **Review infrastructure automation guidelines**: Read "Infrastructure Automation: Ansible vs Proxmox API" in `docs/contributing.md`
- Follow the checklist in `docs/role_readme_template.md`
- Test changes with: `ansible-playbook --syntax-check` and `ansible-lint`
- Keep changes focused and include rationale in commit messages


## Contributing
See the [root contributing guide](../../docs/contributing.md) for standards and prompt scaffolding.

For a canonical role README checklist/template, see `../../docs/role_readme_template.md`.