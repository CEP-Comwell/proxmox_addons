#!/bin/bash
set -euo pipefail

LOG=/tmp/ensure_host_snat_$(date +%s).log
exec 3>&1
echo "Starting ensure_host_snat.sh - log: ${LOG}"
echo "--- $(date -Is) ---" >"${LOG}"

log(){ echo "[$(date -Is)] $*" | tee -a "${LOG}" >&3; }

TENANT_SUBNET=${TENANT_SUBNET:-10.255.0.0/24}
EGRESS_IP=${EGRESS_IP:-172.16.11.20}

command -v iptables >/dev/null 2>&1 || { echo "iptables not found" | tee -a "${LOG}"; exit 1; }

log "Enable ip forwarding"
sysctl -w net.ipv4.ip_forward=1 2>&1 | tee -a "${LOG}" || true

# Check existing SNAT (exact match)
if iptables -t nat -C POSTROUTING -s "${TENANT_SUBNET}" -j SNAT --to-source "${EGRESS_IP}" >/dev/null 2>&1; then
  log "SNAT rule already present: ${TENANT_SUBNET} -> ${EGRESS_IP}"
else
  log "Adding SNAT rule: ${TENANT_SUBNET} -> ${EGRESS_IP}"
  iptables -t nat -A POSTROUTING -s "${TENANT_SUBNET}" -j SNAT --to-source "${EGRESS_IP}" 2>&1 | tee -a "${LOG}" || true
fi

log "Current nat table"
iptables -t nat -S 2>&1 | tee -a "${LOG}"

log "Completed ensure_host_snat.sh (log: ${LOG})"
echo "${LOG}"

# Print current todo status (helper)
if [ -x "$(dirname "$0")/report_todo.sh" ]; then
  log "Current TODO status:"
  "$(dirname "$0")/report_todo.sh" | tee -a "${LOG}"
fi

exit 0
