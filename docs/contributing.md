# Contributing Guide

## General Recommendations
- Follow Ansible best practices for role and playbook structure:
  - Place tasks in `tasks/main.yml` and handlers in `handlers/main.yml` within each role.
  - Do not include handlers directly in task files; use `notify` to trigger handlers.
  - Use `roles:` in playbooks to import roles, ensuring modularity and reusability.
  - Reference roles by name only; Ansible will locate them via `ansible.cfg`.
  - Use `loop_control` for loop indices and avoid deprecated or invalid YAML constructs.
  - Ensure all YAML files are properly indented and formatted to avoid syntax errors.
  - Place templates in the `templates/` directory and use the `template` module for rendering.
  - Store shared variables in `defaults/main.yml` or `vars/main.yml` for each role.
  - Use `group_vars/` and `host_vars/` for inventory-wide variables.
  - Always test changes with `ansible-playbook --syntax-check` before submitting.
- For Docker Compose and other automation, follow the same modular directory structure and naming conventions.

## Commit Standards
- Use [Conventional Commits](https://www.conventionalcommits.org/) for all commits.
- Run linting and tests before submitting a PR.

## Coding Standards
- Use ESLint and Prettier for all TypeScript/JavaScript code.
- Follow the directory structure and naming conventions in the onboarding guide.

## Pull Requests
- Reference the related issue or task in your PR description.
- Ensure all CI checks pass before requesting review.

## Secrets
- Never commit real secrets. Use `.env.example` for templates.

---

For more, see `/docs/onboarding.md` and `/docs/security-best-practices.md`.

---

## Ansible & Docker Compose Project Structure

This repository uses a modular structure for automation projects. Please follow these guidelines when contributing Ansible or Docker Compose code:

### Playbooks
- Place all playbooks in the appropriate subproject directory (e.g., `edgesec-tapx/playbooks/`, `edgesec-sdn/playbooks/`).
- Do not keep playbooks in the project root.

### Roles
- All reusable roles must be placed in the top-level `roles/` directory.
- Reference roles in playbooks using their name only (Ansible will find them via `ansible.cfg`).

### Tasks
- Shared task files (for `include_tasks`) should be placed in the top-level `tasks/` directory.
- Reference them with a relative path from your playbook (e.g., `../../tasks/my_task.yml`).

### Variables & Handlers
- Use `group_vars/` and `host_vars/` for inventory-wide variables.
- Use `vars_files:` in playbooks to include shared variable files (e.g., `../../config.yml`).
- Define handlers inside roles whenever possible for modularity.

### ansible.cfg
- Each subproject's `playbooks/` directory must have an `ansible.cfg` with:
	````markdown
	# Contributing Guide

	## General Recommendations
	- Follow Ansible best practices for role and playbook structure:
	  - Place tasks in `tasks/main.yml` and handlers in `handlers/main.yml` within each role.
	  - Do not include handlers directly in task files; use `notify` to trigger handlers.
	  - Use `roles:` in playbooks to import roles, ensuring modularity and reusability.
	  - Reference roles by name only; Ansible will locate them via `ansible.cfg`.
	  - Use `loop_control` for loop indices and avoid deprecated or invalid YAML constructs.
	  - Ensure all YAML files are properly indented and formatted to avoid syntax errors.
	  - Place templates in the `templates/` directory and use the `template` module for rendering.
	  - Store shared variables in `defaults/main.yml` or `vars/main.yml` for each role.
	  - Use `group_vars/` and `host_vars/` for inventory-wide variables.
	  - Always test changes with `ansible-playbook --syntax-check` before submitting.
	- For Docker Compose and other automation, follow the same modular directory structure and naming conventions.

	## Commit Standards
	- Use [Conventional Commits](https://www.conventionalcommits.org/) for all commits.
	- Run linting and tests before submitting a PR.

	## Coding Standards
	- Use ESLint and Prettier for all TypeScript/JavaScript code.
	- Follow the directory structure and naming conventions in the onboarding guide.

	## Pull Requests
	- Reference the related issue or task in your PR description.
	- Ensure all CI checks pass before requesting review.

	## Secrets
	- Never commit real secrets. Use `.env.example` for templates.

	---

	For more, see `/docs/onboarding.md` and `/docs/security-best-practices.md`.

	---

	## Ansible & Docker Compose Project Structure

	This repository uses a modular structure for automation projects. Please follow these guidelines when contributing Ansible or Docker Compose code:

	### Playbooks
	- Place all playbooks in the appropriate subproject directory (e.g., `edgesec-tapx/playbooks/`, `edgesec-sdn/playbooks/`).
	- Do not keep playbooks in the project root.

	### Roles
	- All reusable roles must be placed in the top-level `roles/` directory.
	- Reference roles in playbooks using their name only (Ansible will find them via `ansible.cfg`).

	### Tasks
	- Shared task files (for `include_tasks`) should be placed in the top-level `tasks/` directory.
	- Reference them with a relative path from your playbook (e.g., `../../tasks/my_task.yml`).

	### Variables & Handlers
	- Use `group_vars/` and `host_vars/` for inventory-wide variables.
	- Use `vars_files:` in playbooks to include shared variable files (e.g., `../../config.yml`).
	- Define handlers inside roles whenever possible for modularity.

	### ansible.cfg
	- Each subproject's `playbooks/` directory must have an `ansible.cfg` with:
		```ini
		[defaults]
		roles_path = ../../roles
		```
	- This ensures playbooks always find the shared roles.

	### Docker Compose
	- Place shared Compose files in a central `docker/` or `compose/` directory, or within each subproject if project-specific.

	### Running Playbooks
	- From a subproject's playbooks directory:
		```bash
		ansible-playbook -i ../../inventory my_playbook.yml
		```
	- Or from the root:
		```bash
		ansible-playbook -i inventory subproject/playbooks/my_playbook.yml
		```

---

For a canonical role README template and checklist, see `docs/role_readme_template.md`.

## Infrastructure Automation: Ansible vs Proxmox API

When developing automation for Proxmox environments, choose the appropriate tool based on the operation type. This guidance helps maintain clean separation between direct system management and API-based infrastructure management.

### Use Ansible/Shell Commands When:

1. **Direct File System Operations**
   - Editing `/etc/network/interfaces`, `/etc/udev/rules.d/`, or system config files
   - Creating custom udev rules for interface renaming
   - Managing systemd services or udev rule reloading

2. **Low-Level Network Configuration**
   - Running `ip link`, `brctl`, or `ethtool` commands for interface management
   - Complex interface detection using `ls -1 /sys/class/net` with filters
   - Manual bridge creation/destruction during troubleshooting

3. **Proxmox Version Compatibility Issues**
   - When Proxmox API behavior changes between versions
   - Working around API limitations or bugs
   - Implementing custom workarounds for specific Proxmox versions

4. **Complex Shell-Based Logic**
   - Parsing `ethtool` output for link speed detection
   - Multi-step operations requiring shell piping or conditional logic
   - One-time setup tasks before API management

### Use Proxmox API When:

1. **VM/Container Lifecycle Management**
   - Creating, starting, stopping VMs/containers
   - Managing VM configurations, disk attachments, network interfaces
   - Bulk operations across multiple VMs

2. **Cluster Management**
   - Managing cluster membership, HA configurations
   - Resource pool management and permissions
   - Backup scheduling and storage management

3. **Network Bridge Management**
   - Creating/managing Linux bridges through Proxmox's abstraction layer
   - Managing bridge properties and attached VMs
   - SDN integration and firewall rules

4. **Storage Operations**
   - Creating/managing storage pools, volumes, and backups
   - Storage migration and replication
   - iSCSI/LVM/ZFS configuration

5. **Monitoring and Metrics**
   - Accessing performance metrics and logs
   - Health monitoring and alerting
   - Resource usage tracking

6. **User/Access Management**
   - Managing users, groups, and API tokens
   - Permission and role assignments
   - Authentication configuration

7. **Declarative Infrastructure**
   - Ongoing configuration management and drift detection
   - Automated remediation of configuration changes
   - Integration with infrastructure-as-code workflows

### Hybrid Approach (Recommended):

8. **Bootstrap with Shell, Manage with API**
   - Use shell commands for initial network setup and interface renaming
   - Switch to Proxmox API for ongoing VM/network management
   - Example: Shell commands for complex interface renaming logic, API for VM lifecycle

9. **API with Shell Fallbacks**
   - Primary operations via API, shell commands as fallbacks
   - Use API for standard operations, shell for edge cases
   - Log API failures and automatically retry with shell methods

### Key Decision Factors:

- **Stability**: API for production stability, shell for troubleshooting
- **Version Compatibility**: Shell commands when API changes between Proxmox versions
- **Complexity**: API for simple operations, shell for complex parsing/logic
- **Idempotency**: API generally better for idempotent operations
- **Debugging**: Shell commands provide better visibility during development

---

## Guidance for LLMs and automated code assistants

**Important**: Before making any infrastructure automation changes, review the "Infrastructure Automation: Ansible vs Proxmox API" section above to choose the appropriate tool for each task type. This ensures consistent architectural decisions across the codebase.

We encourage using automated tools (including LLM-based code assistants) to speed development, but to keep the repository stable please ensure the following when an LLM or automated editor makes changes:

	- Small, focused changes: prefer narrow PRs that change one role or one small area rather than sweeping edits across many files.
	- Run local checks after any generated change:
		- `yamllint` for YAML formatting
		- `ansible-lint` for role/playbook best-practices
		- `ansible-playbook --syntax-check` for any playbooks that include edited roles
	- Do not insert Markdown code fences (```yaml```) inside YAML files. Tasks files must be pure YAML.
	- Avoid duplicate YAML document separators (`---`) inside role task files; if multiple documents are required, split into separate files.
	- Add an explanatory commit message and PR description summarizing what the assistant changed and why (include the exact files edited).
	- Where possible include or update small verification steps (syntax checks or a tiny run in `--check` mode) as part of the PR so reviewers can quickly validate correctness.
	- Preserve repository conventions (2-space YAML indentation, role layout, `defaults/main.yml` for defaults).

	If an automated change introduces a parsing error, the remediation checklist is:

	1. Run `ansible-playbook --syntax-check` targeting the playbook that failed to identify the problematic file and line.
	2. Inspect the flagged file(s) for stray Markdown fences, duplicate `---` markers, or duplicated blocks.
	3. Re-run `yamllint` and `ansible-lint` locally, fix issues, and re-run the syntax check.

	Including this guidance in PRs created by assistants makes reviews faster and reduces back-and-forth.

	````
