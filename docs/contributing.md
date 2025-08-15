# Contributing Guide

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
