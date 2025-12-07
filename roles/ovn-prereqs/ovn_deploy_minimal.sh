#!/bin/bash
set -euo pipefail

LOG=/tmp/ovn_deploy_minimal_$(date +%s).log
exec 3>&1
echo "Starting ovn_deploy_minimal.sh - log: ${LOG}"
echo "--- $(date -Is) ---" >"${LOG}"

log() { echo "[$(date -Is)] $*" | tee -a "${LOG}" >&3; }

command -v ovn-nbctl >/dev/null 2>&1 || { echo "ovn-nbctl not found; install ovn packages"; exit 1; }

LS=tenant1-switch
LR=tenant1-router
GW_EXT=172.16.11.20
TENANT_SUBNET=10.255.0.0/24

log "Create logical switch ${LS}"
ovn-nbctl --may-exist ls-add "${LS}" >>"${LOG}" 2>&1

log "Create logical router ${LR}"
ovn-nbctl --may-exist lr-add "${LR}" >>"${LOG}" 2>&1

# Create router port and connect to switch via router-type logical port
LRP_NAME=${LR}-to-${LS}
LRP_IP=172.16.11.1/24
LRP_MAC=02:aa:bb:cc:dd:01

log "Add logical router port ${LRP_NAME} ${LRP_MAC} ${LRP_IP}"
ovn-nbctl --if-exists lrp-del "${LR}" "${LRP_NAME}" >/dev/null 2>&1 || true
ovn-nbctl --may-exist lrp-add "${LR}" "${LRP_NAME}" "${LRP_MAC}" "${LRP_IP}" >>"${LOG}" 2>&1

SW_LSP_NAME=router-to-${LS}
log "Add logical switch port ${SW_LSP_NAME} and link to router-port ${LRP_NAME}"
ovn-nbctl --may-exist lsp-add "${LS}" "${SW_LSP_NAME}" >>"${LOG}" 2>&1
ovn-nbctl lsp-set-type "${SW_LSP_NAME}" router >>"${LOG}" 2>&1
ovn-nbctl lsp-set-options "${SW_LSP_NAME}" "router-port=${LRP_NAME}" >>"${LOG}" 2>&1

# Add LSPs for vm200 and vm201 (logical ports expected to match iface-id on hosts)
for vm in vm200 vm201; do
  case "$vm" in
    vm200)
      MAC=BC:24:11:AF:E3:71; IP=10.255.0.200
      ;;
    vm201)
      MAC=BC:24:11:EC:0C:23; IP=10.255.0.201
      ;;
  esac
  log "Add logical switch port ${vm} with addresses ${MAC} ${IP}"
  ovn-nbctl --may-exist lsp-add "${LS}" "${vm}" >>"${LOG}" 2>&1
  ovn-nbctl lsp-set-addresses "${vm}" "${MAC} ${IP}" >>"${LOG}" 2>&1
  ovn-nbctl lsp-set-port-security "${vm}" "${MAC} ${IP}" >>"${LOG}" 2>&1
  ovn-nbctl lsp-set-enabled "${vm}" enabled >>"${LOG}" 2>&1 || true
done

# Add SNAT for tenant subnet -> external gateway IP
log "Add SNAT for ${TENANT_SUBNET} -> ${GW_EXT} on router ${LR}"
# remove existing identical SNAT if present
existing_snat=$(ovn-nbctl --format=json lr-nat-list "${LR}" 2>/dev/null | grep -E "${TENANT_SUBNET}" || true)
if [ -n "${existing_snat}" ]; then
  log "SNAT for ${TENANT_SUBNET} already exists; skipping add"
else
  ovn-nbctl lr-nat-add "${LR}" snat "${TENANT_SUBNET}" "${GW_EXT}" >>"${LOG}" 2>&1 || true
fi

log "Final OVN NB state"
ovn-nbctl show >>"${LOG}" 2>&1 || true
ovn-nbctl lr-nat-list "${LR}" >>"${LOG}" 2>&1 || true

log "Completed ovn_deploy_minimal.sh (log: ${LOG})"
echo "Log: ${LOG}"

exit 0
