#!/usr/bin/env bash
# LLM and Automated Assistant Instructions (embedded)
# ================================================
#
# Purpose
# -------
# This file is the canonical, machine-readable instruction for automated
# code assistants (LLMs, bots) and humans working on this repository. Before
# making edits, an assistant should read this file and `docs/contributing.md`.
#
# Required checks (what the assistant must do before changing repo files)
# - Read `docs/contributing.md` and `docs/role_readme_template.md` in full.
# - Verify that the role you plan to modify has a one-line pointer to the
#   role template in `roles/<role>/README.md` (the pointer should reference
#   `docs/role_readme_template.md`).
# - Run `scripts/validate_role_readmes.py` to confirm all role READMEs
#   include the pointer.
# - Run YAML and Ansible checks where appropriate (examples below).
#
# Commands the assistant or contributor should run locally (from repo root)
# ```
# python3 scripts/validate_role_readmes.py
# yamllint -d "extends: default, rules: {line-length: {max: 160}, indentation: {spaces: 2}}" roles/<role>/tasks/*.yml
# ansible-lint roles/<role>
# ansible-playbook -i inventory path/to/playbook.yml --syntax-check
# ```
#
# Behavioral notes for automated assistants
# - Do not assume role README pointers exist. Validate and, if missing,
#   either add the one-line pointer (create a commit) or prompt the human
#   maintainer.
# - Do not modify `docs/contributing.md` or `docs/role_readme_template.md`
#   without explicit human review.
# - Prefer using Ansible modules instead of raw shell commands where possible;
#   shell tasks can complicate syntax-checks.
#
# If you are an automated tool (CI, bot, or LLM integration), this repository
# expects you to run `scripts/validate_role_readmes.py` and fail fast if the
# pointer is missing. This makes the pointer a dependable signal for both
# humans and assistants.
#
# Location: `.assistant_instructions.md` (repo root)
#
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <role-name> [playbook-path]

Runs:
  - yamllint on files under roles/<role>/tasks/
  - ansible-lint on roles/<role>
  - optional: ansible-playbook -i inventory <playbook-path> --syntax-check

Examples:
  $(basename "$0") nic_pinning
  $(basename "$0") vxlan playbooks/deploy_vxlan.yml
EOF
  exit 2
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  usage
fi

ROLE="$1"
PLAYBOOK="${2:-}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ROLE_DIR="$ROOT_DIR/roles/$ROLE"

if [ ! -d "$ROLE_DIR" ]; then
  echo "ERROR: role directory not found: $ROLE_DIR" >&2
  exit 3
fi

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

fail=0

echo "Running role checks for: $ROLE"

if ! command_exists yamllint; then
  echo "ERROR: yamllint not found in PATH. Install with 'pip install yamllint'" >&2
  fail=1
else
  # collect tasks YAML files
  mapfile -t task_files < <(find "$ROLE_DIR" -type f \( -name '*.yml' -o -name '*.yaml' \) -path '*/tasks/*' | sort)
  if [ ${#task_files[@]} -eq 0 ]; then
    echo "No task YAML files found under $ROLE_DIR/tasks - skipping yamllint"
  else
    echo "Running yamllint on ${#task_files[@]} file(s)"
    # Create a temporary yamllint config file to avoid inline parsing issues
    tmpcfg=$(mktemp /tmp/yamllint.XXXXXX)
    cat > "$tmpcfg" <<'YAMLLINT'
extends: default
rules:
  line-length:
    max: 160
  indentation:
    spaces: 2
YAMLLINT
    # ensure cleanup
    trap 'rm -f "$tmpcfg"' EXIT
    yamllint -c "$tmpcfg" "${task_files[@]}" || fail=1
    rm -f "$tmpcfg" || true
    trap - EXIT
  fi
fi

if ! command_exists ansible-lint; then
  echo "ERROR: ansible-lint not found in PATH. Install with 'pip install ansible-lint'" >&2
  fail=1
else
  echo "Running ansible-lint on $ROLE_DIR"
  ansible-lint "$ROLE_DIR" || fail=1
fi

if [ -n "$PLAYBOOK" ]; then
  if ! command_exists ansible-playbook; then
    echo "ERROR: ansible-playbook not found in PATH. Install Ansible to run syntax checks." >&2
    fail=1
  else
    echo "Running ansible-playbook --syntax-check for playbook: $PLAYBOOK"
    # run syntax check relative to repo root
    (cd "$ROOT_DIR" && ansible-playbook -i inventory "$PLAYBOOK" --syntax-check) || fail=1
  fi
else
  echo "No playbook supplied: skipping ansible-playbook --syntax-check"
fi

if [ "$fail" -ne 0 ]; then
  echo "One or more checks failed." >&2
  exit 4
fi

echo "All role checks passed for: $ROLE"
exit 0
