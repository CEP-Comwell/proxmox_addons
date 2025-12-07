#!/bin/bash
set -euo pipefail

# Idempotent OVN/OVS baseline installer for Proxmox/DEB systems.
# Adds preflight checks, unmasking of packaged-masked units, ensures br-int is UP,
# and writes verification output to a timestamped log.

TS=$(date +%s)
LOG=/tmp/ovn_baseline_${TS}.log
exec 3>&1
echo "Starting ovn_baseline.sh - log: ${LOG}"
echo "--- $(date -Is) ---" >"${LOG}"

log() { echo "[$(date -Is)] $*" | tee -a "${LOG}" >&3; }

is_debian() { command -v apt-get >/dev/null 2>&1 || return 1; }
pkg_installed() { dpkg -s "$1" >/dev/null 2>&1 || return 1; }

unmask_unit_if_present() {
  local u=$1
  if systemctl list-unit-files --type=service | awk '{print $1}' | grep -xq "${u}"; then
    log "Unmasking ${u}"
    systemctl unmask "${u}" 2>/dev/null || true
  fi
}

ensure_br_int_up() {
  if ip link show br-int >/dev/null 2>&1; then
    local state
    state=$(cat /sys/class/net/br-int/operstate 2>/dev/null || true)
    if [ "${state}" != "up" ]; then
      log "br-int exists but state=${state}; bringing up"
      ip link set dev br-int up || log "ip link set br-int up failed"
      sleep 1
    else
      log "br-int already up"
    fi
  else
    log "br-int not present; ovs-vswitchd will create it when started"
  fi
}

if is_debian; then
  log "Detected Debian/Ubuntu environment"
  log "Updating apt cache"
  apt-get update -y >>"${LOG}" 2>&1 || log "apt-get update failed"

  # Install packages idempotently. `ovn-host` may be a transitional package on some distros.
  if ! pkg_installed openvswitch-switch; then
    log "Installing openvswitch-switch and OVN host components"
    apt-get install -y openvswitch-switch ovn-host ovn-common >>"${LOG}" 2>&1 || \
      apt-get install -y openvswitch-switch ovn-host >>"${LOG}" 2>&1 || log "apt install (fallback) failed"
  else
    log "openvswitch-switch already installed"
  fi
else
  log "Non-debian system detected; please install openvswitch and ovn packages manually"
fi

# Ensure systemd sees any newly-installed units
systemctl daemon-reload || true

# Unmask OVS packaged-masked units which are common on Proxmox
unmask_unit_if_present ovs-vswitchd.service
unmask_unit_if_present ovsdb-server.service

# Start/enable OVS services
for svc in ovsdb-server ovs-vswitchd; do
  if systemctl list-unit-files --type=service | awk '{print $1}' | grep -xq "${svc}.service"; then
    log "Enabling and starting ${svc}"
    systemctl enable --now "${svc}" >>"${LOG}" 2>&1 || {
      log "systemctl enable/start ${svc} failed; attempting start"
      systemctl start "${svc}" >>"${LOG}" 2>&1 || log "start ${svc} failed"
    }
  else
    log "Unit ${svc} not present on this system"
  fi
done

# Ensure the integration bridge is up so ovn-controller can create/use br-int.mgmt
ensure_br_int_up

# Optional: install and enable OVN central listener on localhost TCP ports
# Set INSTALL_OVN_CENTRAL=1 in the environment to enable this behavior.
install_ovn_central_if_requested() {
  INSTALL=${INSTALL_OVN_CENTRAL:-0}
  if [ "${INSTALL}" = "1" ]; then
    log "INSTALL_OVN_CENTRAL=1 detected — configuring local OVN NB/SB TCP listener"
    if [ -x /usr/share/ovn/scripts/ovn-ctl ]; then
      # Ensure DB dir and DB files exist (create from schema if possible)
      mkdir -p /var/lib/ovn
      NB_DB=/var/lib/ovn/ovnnb_db.db
      SB_DB=/var/lib/ovn/ovnsb_db.db
      # Try known schema paths (Debian packages sometimes use different names)
      if [ -f /usr/share/ovn/ovnnb_db.ovsschema ]; then
        NB_SCHEMA=/usr/share/ovn/ovnnb_db.ovsschema
      elif [ -f /usr/share/ovn/ovn-nb.ovsschema ]; then
        NB_SCHEMA=/usr/share/ovn/ovn-nb.ovsschema
      else
        NB_SCHEMA=/usr/share/ovn/ovnnb_db.ovsschema
      fi
      if [ -f /usr/share/ovn/ovnsb_db.ovsschema ]; then
        SB_SCHEMA=/usr/share/ovn/ovnsb_db.ovsschema
      elif [ -f /usr/share/ovn/ovn-sb.ovsschema ]; then
        SB_SCHEMA=/usr/share/ovn/ovn-sb.ovsschema
      else
        SB_SCHEMA=/usr/share/ovn/ovnsb_db.ovsschema
      fi
      # If schema files are missing, attempt to install ovn-central package to provide them
      if [ ! -f "${NB_SCHEMA}" ] || [ ! -f "${SB_SCHEMA}" ]; then
        log "OVN schema files missing; attempting to install 'ovn-central' package"
        if is_debian; then
          apt-get update -y >>"${LOG}" 2>&1 || true
          apt-get install -y ovn-central ovn-common >>"${LOG}" 2>&1 || apt-get install -y ovn-central >>"${LOG}" 2>&1 || log "apt install ovn-central failed"
        else
          log "Non-debian system and schema files missing; please install ovn-central manually"
        fi
      fi
      if [ ! -f "${NB_DB}" ]; then
        if [ -f "${NB_SCHEMA}" ]; then
          log "Creating NB DB ${NB_DB} from schema ${NB_SCHEMA}"
          ovsdb-tool create "${NB_DB}" "${NB_SCHEMA}" >>"${LOG}" 2>&1 || log "ovsdb-tool create NB DB failed"
        else
          log "NB schema ${NB_SCHEMA} not found; NB DB won't be created automatically"
        fi
      else
        log "NB DB ${NB_DB} already exists"
      fi
      if [ ! -f "${SB_DB}" ]; then
        if [ -f "${SB_SCHEMA}" ]; then
          log "Creating SB DB ${SB_DB} from schema ${SB_SCHEMA}"
          ovsdb-tool create "${SB_DB}" "${SB_SCHEMA}" >>"${LOG}" 2>&1 || log "ovsdb-tool create SB DB failed"
        else
          log "SB schema ${SB_SCHEMA} not found; SB DB won't be created automatically"
        fi
      else
        log "SB DB ${SB_DB} already exists"
      fi
      chown -R openvswitch:openvswitch /var/lib/ovn 2>/dev/null || true

      U=/etc/systemd/system/ovn-central-listener.service
      log "Writing systemd unit ${U} to run full OVN stack (NB/SB/northd/controller)"
      cat >"${U}" <<'UNIT'
[Unit]
Description=OVN full stack (NB/SB/northd/controller) for standalone node
After=network.target

[Service]
ExecStart=/usr/share/ovn/scripts/ovn-ctl \
  --db-nb-addr=127.0.0.1 --db-nb-port=6641 --db-nb-create-insecure-remote=yes \
  --db-sb-addr=127.0.0.1 --db-sb-port=6642 --db-sb-create-insecure-remote=yes \
  start_northd
ExecStartPost=/usr/share/ovn/scripts/ovn-ctl start_controller
ExecStop=/usr/share/ovn/scripts/ovn-ctl stop_northd
ExecStopPost=/usr/share/ovn/scripts/ovn-ctl stop_controller
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
UNIT
      systemctl daemon-reload >>"${LOG}" 2>&1 || true
      systemctl enable --now ovn-central-listener >>"${LOG}" 2>&1 || {
        log "Failed to enable/start ovn-central-listener via systemctl; attempting start"
        systemctl start ovn-central-listener >>"${LOG}" 2>&1 || log "start ovn-central-listener failed"
      }
      log "ovn-central-listener unit configured; NB/SB should listen on 127.0.0.1:6641/6642"
    else
      log "/usr/share/ovn/scripts/ovn-ctl not present; cannot configure central listener"
    fi
  fi
}

install_ovn_central_if_requested

wait_for_br_int_mgmt() {
  # Wait for br-int management socket and for Interface br-int to have an ofport
  local timeout=30
  local elapsed=0
  while [ ${elapsed} -lt ${timeout} ]; do
    if [ -S /var/run/openvswitch/br-int.mgmt ]; then
      # try to read ofport
      ofport=$(ovs-vsctl --timeout=2 --if-exists get Interface br-int ofport 2>/dev/null || true)
      if [[ "${ofport}" =~ ^[0-9]+$ ]] && [ "${ofport}" -gt 0 ]; then
        log "br-int.mgmt present and ofport=${ofport}"
        return 0
      else
        log "br-int.mgmt present but ofport='${ofport}' not ready"
      fi
    else
      log "br-int.mgmt socket not present yet"
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done
  return 1
}

# Start ovn-controller if unit exists — wait for br-int management socket first
if systemctl list-unit-files --type=service | awk '{print $1}' | grep -xq "ovn-controller.service"; then
  log "Unmasking ovn-controller unit"
  systemctl unmask ovn-controller.service 2>/dev/null || true
  log "Waiting up to 30s for /var/run/openvswitch/br-int.mgmt and br-int ofport"
  if wait_for_br_int_mgmt; then
    log "Starting ovn-controller after br-int ready"
    systemctl enable --now ovn-controller >>"${LOG}" 2>&1 || systemctl start ovn-controller >>"${LOG}" 2>&1 || log "ovn-controller start failed"
  else
    log "Timeout waiting for br-int; starting ovn-controller anyway (it will retry)"
    systemctl enable --now ovn-controller >>"${LOG}" 2>&1 || systemctl start ovn-controller >>"${LOG}" 2>&1 || log "ovn-controller start failed"
  fi
else
  log "ovn-controller unit not present; ensure OVN host packages are installed"
fi

# Post-install verification
log "Verification: ovs-vsctl show"
ovs-vsctl show 2>&1 | tee -a "${LOG}" || true

log "Verification: dump-ports-desc br-int"
ovs-ofctl -O OpenFlow15 dump-ports-desc br-int 2>&1 | tee -a "${LOG}" || true

log "Verification: dump-flows br-int"
ovs-ofctl -O OpenFlow15 dump-flows br-int 2>&1 | tee -a "${LOG}" || true

log "Verification: systemctl status ovs-vswitchd ovn-controller"
systemctl status ovs-vswitchd --no-pager -l 2>&1 | tee -a "${LOG}" || true
systemctl status ovn-controller --no-pager -l 2>&1 | tee -a "${LOG}" || true

log "Completed ovn_baseline.sh (log: ${LOG})"

exit 0