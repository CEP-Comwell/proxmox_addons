# add_llm_guidance_to_roles.sh

Maintenance script to add LLM guidance sections to all Ansible role READMEs.

## Purpose

This script ensures that all Ansible role READMEs in the repository contain guidance for LLM (Large Language Model) code assistants. The guidance helps automated tools make informed architectural decisions about when to use Ansible/shell commands versus Proxmox API calls.

## When to Use

Run this script when:
- **Adding new Ansible roles** that need LLM guidance sections (use specific role path)
- **Bulk updating** all roles when guidance content changes (no arguments)
- **Ensuring consistency** after repository restructuring
- **Setting up** LLM guidance for the first time across all roles

## Prerequisites

- Bash shell
- Repository must be cloned locally
- Script must be run from the repository root directory

## Usage

### Basic Usage (All Roles)
```bash
# From repository root - processes all roles
./scripts/add_llm_guidance_to_roles.sh
```

### Specific Role Usage
```bash
# Process only a specific role
./scripts/add_llm_guidance_to_roles.sh roles/my_new_role

# Or with leading slash (automatically handled)
./scripts/add_llm_guidance_to_roles.sh /roles/my_new_role
```

### Verify Before Running
Check current status first:
```bash
# Count total role READMEs
find roles -name "README.md" | wc -l

# Count READMEs with LLM guidance
grep -l "## LLM/Code Assistant Guidance" roles/*/README.md | wc -l

# Find READMEs missing LLM guidance
find roles -name "README.md" | while read f; do
  if ! grep -q "## LLM/Code Assistant Guidance" "$f"; then
    echo "$f"
  fi
done
```

## What It Does

1. **Scans** all `roles/*/README.md` files
2. **Checks** for existing LLM guidance sections (skips if already present)
3. **Creates backups** of modified files (`.bak` extension)
4. **Adds** standardized LLM guidance section to each README
5. **Reports** progress and completion status

## Output Example

### All Roles Processing
```
Adding LLM guidance sections to all role READMEs...
Processing: /path/to/repo/roles/bgp/README.md
  Added LLM guidance section
Processing: /path/to/repo/roles/network_provision/README.md
  Skipping - LLM guidance already exists
...
Complete! All role READMEs now have LLM guidance sections.
Backups created with .bak extension.
```

### Specific Role Processing
```
Processing specific role: roles/my_new_role
Processing: /path/to/repo/roles/my_new_role/README.md
  Added LLM guidance section
Complete! Role roles/my_new_role now has LLM guidance section.
Backup created: /path/to/repo/roles/my_new_role/README.md.bak
```

### Error Handling
If you specify an invalid role path:
```
Processing specific role: invalid_role
ERROR: Role directory not found: /path/to/repo/invalid_role
Usage: ./scripts/add_llm_guidance_to_roles.sh [role_path]
Example: ./scripts/add_llm_guidance_to_roles.sh roles/my_new_role
```

## Safety Features

- **Duplicate Detection**: Won't add guidance if already present
- **Backup Creation**: Creates `.bak` files before modifying
- **Non-Destructive**: Preserves all existing content
- **Error Handling**: Stops on first error with `set -e`

## LLM Guidance Content

The script adds this section to each role README:

```markdown
## LLM/Code Assistant Guidance

When using LLM assistants or automated code tools to modify this role:

- **Review infrastructure automation guidelines**: Read "Infrastructure Automation: Ansible vs Proxmox API" in `docs/contributing.md`
- Follow the checklist in `docs/role_readme_template.md`
- Test changes with: `ansible-playbook --syntax-check` and `ansible-lint`
- Keep changes focused and include rationale in commit messages
```

## Troubleshooting

### Script Won't Run
```bash
# Make sure it's executable
chmod +x scripts/add_llm_guidance_to_roles.sh

# Run from repository root
cd /path/to/repo
./scripts/add_llm_guidance_to_roles.sh
```

### Restore from Backup
```bash
# Restore all modified files
find roles -name "*.bak" -exec bash -c 'mv "$1" "${1%.bak}"' _ {} \;

# Or restore specific file
mv roles/some_role/README.md.bak roles/some_role/README.md
```

### Check for Issues
```bash
# Find files with multiple LLM sections
grep -l "## LLM/Code Assistant Guidance" roles/*/README.md | \
  xargs grep -c "## LLM/Code Assistant Guidance" | \
  grep -v ":1$"
```

## Related Files

- `docs/contributing.md` - Central infrastructure automation guidelines
- `docs/role_readme_template.md` - Template with LLM checklist
- `roles/*/README.md` - Individual role documentation files