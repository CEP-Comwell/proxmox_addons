#!/bin/bash
set -euo pipefail

cat <<'TODOS'
OVN Proxmox VE 9.11 baseline TODO status:
- [x] 1: Project: OVN Proxmox VE 9.11 baseline (ovn-pve-base)
- [x] 2: Implement bash baseline installer (`roles/ovn-prereqs/ovn_baseline.sh`)
- [x] 3: Add minimal OVN topology deploy script (`roles/ovn-prereqs/ovn_deploy_minimal.sh`)
- [x] 4: Validate baseline on NB host (run baseline + deploy)
- [x] 5: Start/enable OVN central TCP listener (optional)
- [~] 6: Validate flow programming on compute hosts — IN-PROGRESS
- [x] 7: Add host SNAT egress rule (idempotent)
- [ ] 8: Harden scripts and logging
- [ ] 9: Convert to Ansible role
- [ ] 10: Automated verification and docs

Current active step: 6 — "Validate flow programming on compute hosts"
TODOS

exit 0
