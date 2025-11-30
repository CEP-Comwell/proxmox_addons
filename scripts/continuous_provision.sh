#!/usr/bin/env bash
set -euo pipefail

# Continuous provision runner: activates venv, runs provision playbook,
# logs output, and collects diagnostics on failure.

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
VENV="$ROOT_DIR/.venv"
ANSIBLE_PLAYBOOK="$VENV/bin/ansible-playbook"
ANSIBLE_BIN="$VENV/bin/ansible"
PLAYBOOK="edgesec-sdn/playbooks/provision_ovs_only.yml"
EXTRA_VARS_FILE="/tmp/provision_vars.yml"
LOG_DIR="$ROOT_DIR/logs/continuous_provision"
mkdir -p "$LOG_DIR"
TS=$(date -u +"%Y%m%dT%H%M%SZ")
LOG="$LOG_DIR/provision_${TS}.log"

echo "[$(date -u +%FT%TZ)] Starting provision run" | tee -a "$LOG"

if [ ! -x "$ANSIBLE_PLAYBOOK" ]; then
  echo "Ansible-playbook not found at $ANSIBLE_PLAYBOOK" | tee -a "$LOG"
  exit 2
fi

echo "Running: $ANSIBLE_PLAYBOOK -i inventory $PLAYBOOK -l pve1.comwell.edgesec.ca -u root -e @$EXTRA_VARS_FILE" | tee -a "$LOG"
set +e
$ANSIBLE_PLAYBOOK -i inventory "$PLAYBOOK" -l pve1.comwell.edgesec.ca -u root -e @"$EXTRA_VARS_FILE" -vv 2>&1 | tee -a "$LOG"
RC=${PIPESTATUS[0]}
set -e

if [ "$RC" -ne 0 ]; then
  echo "[$(date -u +%FT%TZ)] Playbook failed with rc=$RC — collecting diagnostics" | tee -a "$LOG"
  echo "--- OVS show ---" | tee -a "$LOG"
  $ANSIBLE_BIN -i inventory pve1.comwell.edgesec.ca -u root -m shell -a "ovs-vsctl show" 2>&1 | tee -a "$LOG"
  echo "--- OVS list-br ---" | tee -a "$LOG"
  $ANSIBLE_BIN -i inventory pve1.comwell.edgesec.ca -u root -m shell -a "ovs-vsctl list-br" 2>&1 | tee -a "$LOG"
  echo "--- journal (openvswitch-switch) ---" | tee -a "$LOG"
  $ANSIBLE_BIN -i inventory pve1.comwell.edgesec.ca -u root -m shell -a "journalctl -u openvswitch-switch -n 200 --no-pager" 2>&1 | tee -a "$LOG"
  echo "--- systemctl status openvswitch-switch ---" | tee -a "$LOG"
  $ANSIBLE_BIN -i inventory pve1.comwell.edgesec.ca -u root -m shell -a "systemctl status openvswitch-switch --no-pager" 2>&1 | tee -a "$LOG"
  echo "--- /etc/network/interfaces ---" | tee -a "$LOG"
  $ANSIBLE_BIN -i inventory pve1.comwell.edgesec.ca -u root -m shell -a "cat /etc/network/interfaces || true" 2>&1 | tee -a "$LOG"
  echo "--- Proxmox SDN zones ---" | tee -a "$LOG"
  $ANSIBLE_BIN -i inventory pve1.comwell.edgesec.ca -u root -m shell -a "pvesh get /cluster/sdn/zones --output-format json" 2>&1 | tee -a "$LOG"
  echo "--- qm list ---" | tee -a "$LOG"
  $ANSIBLE_BIN -i inventory pve1.comwell.edgesec.ca -u root -m shell -a "qm list" 2>&1 | tee -a "$LOG"
  echo "Diagnostics collected to $LOG"
else
  echo "[$(date -u +%FT%TZ)] Playbook finished successfully" | tee -a "$LOG"
fi

echo "Exit code: $RC"
exit "$RC"
