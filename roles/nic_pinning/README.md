# NIC Pinning Role

Automates network interface pinning and naming for Proxmox VE 9.

## Usage
Include this role to manage NIC pinning and custom naming.

## Variables
List any variables and defaults here.

### Provision template generation
This role will render a suggested provision assignment file after it generates normalized NIC names. The output path defaults to the `provision` role default `provision_template_path` (usually `/tmp/provision_nic_assignments-<inventory_hostname>.yml`).

If you run `nic_pinning` before `provision`, the generated template can be edited and used by the `provision` role to control bridge assignments.

## Example
```yaml
- hosts: all
  roles:
    - nic_pinning
```

---

## Contributing
See the [root contributing guide](../../docs/contributing.md) for standards and prompt scaffolding.

For a canonical role README checklist/template, see `../../docs/role_readme_template.md`.