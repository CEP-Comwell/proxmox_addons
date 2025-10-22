#!/bin/bash
# Maintenance script to add LLM guidance section to all role READMEs
# This ensures LLM assistants have explicit guidance for each role
# Run this script from the repository root: ./scripts/add_llm_guidance_to_roles.sh [role_path]

# Exit immediately if any command fails
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the repository root directory (parent of scripts directory)
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Check for command line argument (specific role path)
SPECIFIC_ROLE="$1"

if [ -n "$SPECIFIC_ROLE" ]; then
    # Remove leading slash if present
    SPECIFIC_ROLE="${SPECIFIC_ROLE#/}"
    # Construct full path
    ROLE_PATH="$REPO_ROOT/$SPECIFIC_ROLE"
    README_PATH="$ROLE_PATH/README.md"

    echo "Processing specific role: $SPECIFIC_ROLE"

    # Validate the role path exists
    if [ ! -d "$ROLE_PATH" ]; then
        echo "ERROR: Role directory not found: $ROLE_PATH"
        echo "Usage: $0 [role_path]"
        echo "Example: $0 roles/my_new_role"
        exit 1
    fi

    # Validate README exists
    if [ ! -f "$README_PATH" ]; then
        echo "ERROR: README.md not found: $README_PATH"
        exit 1
    fi

    # Process only this specific role
    readme_file="$README_PATH"
    echo "Processing: $readme_file"

    # Check if LLM guidance already exists (more comprehensive check)
    if grep -q "## LLM.*[Gg]uidance\|[Aa]utomated.*[Cc]ode.*[Aa]ssistant\|[Cc]ode.*[Aa]ssistant.*[Gg]uidance" "$readme_file"; then
        echo "  Skipping - LLM guidance already exists"
        exit 0
    fi

    # Create backup
    cp "$readme_file" "${readme_file}.bak"

    # Add LLM guidance section (same logic as before)
    if grep -q "^---$" "$readme_file"; then
        # File has final --- separator, replace it with LLM guidance + ---
        sed -i '/^---$/i \
## LLM/Code Assistant Guidance\
\
When using LLM assistants or automated code tools to modify this role:\
\
- **Review infrastructure automation guidelines**: Read "Infrastructure Automation: Ansible vs Proxmox API" in `docs/contributing.md`\
- Follow the checklist in `docs/role_readme_template.md`\
- Test changes with: `ansible-playbook --syntax-check` and `ansible-lint`\
- Keep changes focused and include rationale in commit messages\
\
---' "$readme_file"
        # Remove the duplicate --- that was created by the insertion above
        sed -i '/^---$/d' "$readme_file"
    else
        # No final separator, add at end
        echo "" >> "$readme_file"
        echo "## LLM/Code Assistant Guidance" >> "$readme_file"
        echo "" >> "$readme_file"
        echo "When using LLM assistants or automated code tools to modify this role:" >> "$readme_file"
        echo "" >> "$readme_file"
        echo "- **Review infrastructure automation guidelines**: Read \"Infrastructure Automation: Ansible vs Proxmox API\" in \`docs/contributing.md\`" >> "$readme_file"
        echo "- Follow the checklist in \`docs/role_readme_template.md\`" >> "$readme_file"
        echo "- Test changes with: \`ansible-playbook --syntax-check\` and \`ansible-lint\`" >> "$readme_file"
        echo "- Keep changes focused and include rationale in commit messages" >> "$readme_file"
    fi

    echo "  Added LLM guidance section"
    echo "Complete! Role $SPECIFIC_ROLE now has LLM guidance section."
    echo "Backup created: ${readme_file}.bak"
else
    # No argument provided - process all roles (original behavior)
    echo "Adding LLM guidance sections to all role READMEs..."

# Find all README.md files in the roles directory and process each one
find "$REPO_ROOT/roles" -name "README.md" | while read -r readme_file; do
    echo "Processing: $readme_file"

        # Check if LLM guidance already exists using a comprehensive regex pattern
    # This looks for various forms of "LLM guidance", "automated code assistant", or "code assistant guidance"
    if grep -q "## LLM.*[Gg]uidance\|[Aa]utomated.*[Cc]ode.*[Aa]ssistant\|[Cc]ode.*[Aa]ssistant.*[Gg]uidance" "$readme_file"; then
        echo "  Skipping - LLM guidance already exists"
        continue
    fi

    # Create a backup of the original file before making changes
    cp "$readme_file" "${readme_file}.bak"

    # Check if the file ends with a markdown separator (---)
    if grep -q "^---$" "$readme_file"; then
        # File has final --- separator - insert LLM guidance before it
        # Use sed to insert the new content before the --- line
        sed -i '/^---$/i \
## LLM/Code Assistant Guidance\
\
When using LLM assistants or automated code tools to modify this role:\
\
- **Review infrastructure automation guidelines**: Read "Infrastructure Automation: Ansible vs Proxmox API" in `docs/contributing.md`\
- Follow the checklist in `docs/role_readme_template.md`\
- Test changes with: `ansible-playbook --syntax-check` and `ansible-lint`\
- Keep changes focused and include rationale in commit messages\
\
---' "$readme_file"
        # Remove the duplicate --- that was created by the insertion above
        sed -i '/^---$/d' "$readme_file"
    else
        # No final separator - append LLM guidance to the end of the file
        echo "" >> "$readme_file"  # Add blank line for spacing
        echo "## LLM/Code Assistant Guidance" >> "$readme_file"
        echo "" >> "$readme_file"
        echo "When using LLM assistants or automated code tools to modify this role:" >> "$readme_file"
        echo "" >> "$readme_file"
        echo "- **Review infrastructure automation guidelines**: Read \"Infrastructure Automation: Ansible vs Proxmox API\" in \`docs/contributing.md\`" >> "$readme_file"
        echo "- Follow the checklist in \`docs/role_readme_template.md\`" >> "$readme_file"
        echo "- Test changes with: \`ansible-playbook --syntax-check\` and \`ansible-lint\`" >> "$readme_file"
        echo "- Keep changes focused and include rationale in commit messages" >> "$readme_file"
    fi

    echo "  Added LLM guidance section"
done

echo "Complete! All role READMEs now have LLM guidance sections."
echo "Backups created with .bak extension."
fi