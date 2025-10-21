# Role README template

Use this template as the canonical guidance for role README files. Keep role READMEs short and point contributors to `docs/contributing.md` for the full checklist.

Contributing checklist (role maintainers)

- Read the repository contributing guide: `docs/contributing.md`

- Before submitting a PR, run these checks from the repository root (adjust paths as needed):

  yamllint (enforce 2-space indentation, no tabs):

  ```bash
  yamllint -d "extends: default, rules: {line-length: {max: 160}, indentation: {spaces: 2}}" roles/<role>/tasks/*.yml
  ```

  ansible-lint:

  ```bash
  ansible-lint roles/<role>
  ```

  ansible syntax check (use a playbook that exercises the role):

  ```bash
  ansible-playbook -i inventory path/to/playbook.yml --syntax-check
  ```

- Manual rules (important):
  - Use 2-space indentation for YAML (no tabs).
  - Do not include code fences (```yaml```) in `roles/*/tasks/*.yml` files.
  - Do not place handlers inside `tasks/*.yml`; use `roles/<role>/handlers/main.yml` and `notify:` from tasks.
  - Avoid duplicate YAML document markers (`---`) inside a single `tasks/*.yml` file unless intentionally providing multiple documents.

Add a one-line pointer at the top of each role README directing contributors to this file and the central `docs/contributing.md`.