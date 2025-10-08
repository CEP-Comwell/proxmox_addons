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
