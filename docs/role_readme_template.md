# Role README template

Use this template as the canonical guidance for role README files. Keep role READMEs short and point contributors to `docs/contributing.md` for the full checklist.

This template also includes a short checklist for edits produced by LLMs or automated code assistants — see the "LLM/code-assistant checklist" section below.

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

## LLM/code-assistant checklist (for automated edits)

When a language model or automated code assistant edits role files, ensure the following before committing or opening a PR:

- Keep changes focused to a single role or small, related set of files.
- Run formatting and lint checks:
  - `yamllint -d "extends: default, rules: {line-length: {max: 160}, indentation: {spaces: 2}}" roles/<role>/tasks/*.yml`
  - `ansible-lint roles/<role>`
  - `ansible-playbook -i inventory path/to/playbook.yml --syntax-check`
- Do NOT include Markdown fences (```yaml```) or code fences inside YAML role files.
- Ensure there is only one YAML document per `roles/<role>/tasks/*.yml` file (avoid stray `---` markers unless intentionally using multiple documents and splitting files accordingly).
- If the assistant edits templates or Jinja2 files, validate with a small render using sample variables (or a dry-run) and ensure there are no unescaped braces causing parse errors.
- Add a short note in the commit/PR description listing the automated tool used and the high-level rationale for the edit.

Following this checklist keeps automated edits reviewable and prevents common parsing errors introduced by naive copy-paste.