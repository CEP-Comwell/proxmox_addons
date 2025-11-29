#!/bin/sh
# ovs-vni-hook.sh — robust OVS VNI hook for Proxmox (POSIX /bin/sh)
# Usage (Proxmox hookscript): hookscript: /path/to/ovs-vni-hook.sh
# Env:
#   OFVER=OpenFlow13 (default)
#   HOOK_DRYRUN=0|1
#   HOOK_VERIFY=0|1  (require vxlan port present before adding flows; default=1)
#   VNI_MAP_FILE=/etc/pve/vni-map.conf (default)
#   VX_PREFIX=vx     (set to vxlan if you name ports vxlan<VNI>)
#   ALLOW_CREATE_VX=0|1 (allow dynamic create of vxlan ports; default 0)

set -eu
trap 'rc=$?; if [ "$rc" -ne 0 ]; then echo "[ovs-vni][ERROR] vm=${vmid:-unknown} phase=${phase:-unknown} :: exit=$rc" >&2; fi; exit $rc' INT TERM EXIT

OFVER="${OFVER:-OpenFlow13}"
# Accept either HOOK_DRYRUN (preferred) or plain DRYRUN for compatibility
DRYRUN="${HOOK_DRYRUN:-${DRYUN:-0}}" || DRYRUN="${HOOK_DRYRUN:-${DRYRUN:-0}}"
# default to VERIFY=1 for safe operation
VERIFY="${HOOK_VERIFY:-1}"
VNI_MAP_FILE="${VNI_MAP_FILE:-/etc/pve/vni-map.conf}"
VX_PREFIX="${VX_PREFIX:-vx}"
# Allow automated creation of vxlan ports only when explicitly enabled
ALLOW_CREATE_VX="${ALLOW_CREATE_VX:-0}"

vmid="${1:-}"
phase="${2:-}"

log()  { echo "[ovs-vni] vm=${vmid} phase=${phase} :: $*"; }
note() { echo "[ovs-vni][NOTE] vm=${vmid} phase=${phase} :: $*"; }
warn() { echo "[ovs-vni][WARN] vm=${vmid} phase=${phase} :: $*" >&2; }
dry()  { [ "$DRYRUN" = "1" ] && echo "[ovs-vni][DRYRUN] vm=${vmid} phase=${phase} :: $*"; }

# Minimal dependency hints
need() { command -v "$1" >/dev/null 2>&1 || note "Missing '$1' (may fail)"; }
need ovs-vsctl; need ovs-ofctl; need qm; need ip; need awk; need sed

bridge_vni_fallback() {
  case "$1" in
    vmbr1)  echo "10110" ;;
    vmbr99) echo "10102" ;;
    *)      echo "" ;;
  esac
}

vni_from_file() {
  [ -r "$VNI_MAP_FILE" ] || { echo ""; return; }
  vm="$1"; nic="$2"
  target="${vm}.${nic}"
  while IFS= read -r line; do
    case "$line" in
      ""|\#*) continue ;;
    esac
    lhs="${line%%=*}"
    rhs="${line#*=}"
    lhs="$(echo "$lhs" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    if [ "$lhs" = "$target" ]; then
      v="$(echo "$rhs" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
      echo "$v"
      return
    fi
  done < "$VNI_MAP_FILE"
  echo ""
}

list_vm_nics() {
  qm config "$vmid" 2>/dev/null | sed -n 's/^\(net[0-9][0-9]*\):.*/\1/p'
}

nic_mac_bridge() {
  nic="$1"
  line="$(qm config "$vmid" 2>/dev/null | sed -n "s/^${nic}:[[:space:]]*//p")"
  [ -z "$line" ] && { echo ""; return; }
  mac="$(echo "$line" | grep -o -i -E '([0-9a-f]{2}:){5}[0-9a-f]{2}' | tr '[:lower:]' '[:upper:]' | head -n1 || true)"
  br="$(echo "$line" | tr ',' '\n' | sed -n 's/^[[:space:]]*bridge=\([^[:space:],]*\).*$/\1/p' | head -n1 || true)"
  if [ -n "$br" ]; then echo "$mac $br"; fi
}

guess_iface() {
  nic="$1"
  idx="$(echo "$nic" | sed -E 's/^net([0-9]+)$/\1/')"
  fwpr="fwpr${vmid}p${idx}"
  tap="tap${vmid}i${idx}"
  ip link show "$fwpr" >/dev/null 2>&1 && { echo "$fwpr"; return; }
  ip link show "$tap"  >/dev/null 2>&1 && { echo "$tap";  return; }
  set -- $(nic_mac_bridge "$nic"); mac="${1:-}"
  [ -z "$mac" ] && { echo ""; return; }
  for iface in $(ovs-vsctl list Interface 2>/dev/null | sed -n 's/^name[[:space:]]*:[[:space:]]*"\?\([^" ]\+\)"\?/\1/p'); do
    mi="$(ovs-vsctl get Interface "$iface" mac_in_use 2>/dev/null || true)"
    mi="$(echo "$mi" | tr -d '"' | tr '[:upper:]' '[:lower:]')"
    [ -z "$mi" ] && continue
    lc_mac="$(echo "$mac" | tr '[:upper:]' '[:lower:]')"
    echo "$mi" | grep -qi "$lc_mac" && { echo "$iface"; return; }
  done
  for ifc in $(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | sed 's/@.*//'); do
    case "$ifc" in
      *${vmid}*|tap*${vmid}*|fwpr*${vmid}*) echo "$ifc"; return ;;
    esac
  done
}

iface_bridge() {
  ovs-vsctl iface-to-br "$1" 2>/dev/null || true
}

wait_member() {
  ifname="$1"; tries="${2:-20}"; sleep_ms="${3:-200}"
  i=0
  while [ "$i" -lt "$tries" ]; do
    br="$(iface_bridge "$ifname")"
    [ -n "$br" ] && { echo "$br"; return 0; }
    lbr="$(bridge link show dev "$ifname" 2>/dev/null | awk '/master/ {for (i=1;i<=NF;i++) if ($i=="master") print $(i+1)}' | sed 's/://')"
    [ -n "$lbr" ] && { echo "$lbr"; return 0; }
    usleep $((sleep_ms*1000)) 2>/dev/null || sleep "$(awk -v v="$sleep_ms" 'BEGIN{print v/1000}')"
    i=$((i+1))
  done
  echo ""; return 1
}

ofport() {
  br="$1"; ifname="$2"
  ovs-ofctl show "$br" 2>/dev/null | while IFS= read -r line; do
    case "$line" in
      *"($ifname)"*)
        num="$(echo "$line" | sed -n 's/^[[:space:]]*\([0-9][0-9]*\).*/\1/p')"
        [ -n "$num" ] && { echo "$num"; exit 0; }
        ;;
    esac
  done
}

vx_ofport() {
  br="$1"; vni="$2"; vx="${VX_PREFIX}${vni}"
  pn="$(ofport "$br" "$vx")"
  [ -n "$pn" ] && { echo "$pn"; return; }
  vname="$(ovs-vsctl list Interface 2>/dev/null | awk -v key="$vni" '
    BEGIN{ name=""; t=""; opts="" }
    /^name[[:space:]]*:/ { name=$0; sub(/^name[[:space:]]*:[[:space:]]*/, "", name) }
    /^type[[:space:]]*:/ { t=$0; sub(/^type[[:space:]]*:[[:space:]]*/, "", t) }
    /^options[[:space:]]*:/ {
      opts=$0
      if (match(opts, /key[[:space:]]*:[[:space:]]*([0-9]+)/, m)) k=m[1]
      if (t=="vxlan" && k==key && name!="") { print name; exit }
    }')"
  if [ -n "$vname" ]; then
    pn2="$(ofport "$br" "$vname")"
    [ -n "$pn2" ] && { echo "$pn2"; return; }
  fi
  echo ""
}

vni_from_external_ids() {
  iface="$1"; vni=""
  vni="$(ovs-vsctl --no-heading --bare get interface "$iface" external_ids 2>/dev/null || true)"
  if [ -n "$vni" ]; then
    echo "$vni" | sed -n 's/.*vni="\([0-9]*\)".*/\1/p' || echo ""
  else
    echo ""
  fi
}

tag_iface_vni() {
  ifname="$1"; vni="$2"
  [ "$DRYRUN" = "1" ] && { dry "Tag $ifname external_ids:vni=$vni"; return; }
  ovs-vsctl set interface "$ifname" external_ids:vni="$vni" && \
    log "Tagged $ifname vni=$vni" || warn "Failed to tag $ifname"
}

cookie_for_nic() {
  nic="$1"
  idx="$(echo "$nic" | sed -E 's/^net([0-9]+)$/\1/')"
  echo "${vmid}${idx}"
}

add_flows() {
  br="$1"; tapno="$2"; vxno="$3"; vni="$4"; cookie="$5"
  egress="cookie=${cookie},table=0,priority=100,in_port=${tapno},actions=set_field:${vni}->tun_id,output:${vxno}"
  ingress="cookie=${cookie},table=0,priority=90,in_port=${vxno},tun_id=${vni},actions=NORMAL"
  if [ "$DRYRUN" = "1" ]; then dry "ADD $br :: $egress"; dry "ADD $br :: $ingress"; return; fi
  ovs-ofctl -O "$OFVER" add-flow "$br" "$egress"  && log "Add egress $br tap=${tapno}->vx=${vxno} vni=${vni}" || note "Egress exists/failed"
  ovs-ofctl -O "$OFVER" add-flow "$br" "$ingress" && log "Add ingress $br vx=${vxno} vni=${vni}"            || note "Ingress exists/failed"
}

del_flows_by_cookie() {
  br="$1"; cookie="$2"
  [ "$DRYRUN" = "1" ] && { dry "DEL $br :: cookie=${cookie}/-1"; return; }
  ovs-ofctl -O "$OFVER" del-flows "$br" "cookie=${cookie}/-1" && log "Del flows cookie=${cookie}" || note "No flows cookie=${cookie}"
}

case "${phase}" in
  pre-start|pre-stop)
    log "${phase} (no-op)"; exit 0
    ;;

  post-start)
    for nic in $(list_vm_nics); do
      set -- $(nic_mac_bridge "$nic"); br="${2:-}"
      [ -z "$br" ] && { note "Skip $nic: no bridge"; continue; }
      ifname_guess="$(guess_iface "$nic")"
      vni=""
      if [ -n "$ifname_guess" ]; then
        vni="$(vni_from_external_ids "$ifname_guess" || true)"
      fi
      [ -z "$vni" ] && vni="$(vni_from_file "$vmid" "$nic")"
      [ -z "$vni" ] && vni="$(bridge_vni_fallback "$br")"
      [ -z "$vni" ] && { note "No VNI for ${vmid}.${nic} (bridge $br)"; continue; }

      ifname="${ifname_guess:-$(guess_iface "$nic")}" 
      [ -z "$ifname" ] && { note "No iface for $nic"; continue; }

      ovs_br="$(wait_member "$ifname" 20 200)"
      [ -z "$ovs_br" ] && { note "Iface $ifname not in OVS"; continue; }

      tapno="$(ofport "$ovs_br" "$ifname")"
      vxno="$(vx_ofport "$ovs_br" "$vni")"

      if [ -z "$vxno" ]; then
        if [ "$ALLOW_CREATE_VX" = "1" ]; then
          note "Attempting dynamic create of ${VX_PREFIX}${vni} on $ovs_br (ALLOW_CREATE_VX=1)"
          local_ip_var="LOCAL_IP_${ovs_br}"
          local_ip=""
          eval "local_ip=\${${local_ip_var}:-}"
          if [ -z "$local_ip" ]; then
            case "$ovs_br" in
              vmbr1) local_ip="10.255.0.1" ;;
              vmbr2) local_ip="10.255.0.2" ;;
              vmbr99) local_ip="10.255.0.99" ;;
              *) local_ip="" ;;
            esac
          fi
          vxname="${VX_PREFIX}${vni}"
          if [ "$DRYRUN" = "1" ]; then dry "ovs-vsctl --may-exist add-port $ovs_br $vxname -- set interface $vxname type=vxlan options:key=$vni options:remote_ip=flow options:local_ip=$local_ip options:nolearning=true options:csum=true"; fi
          if [ "$DRYRUN" != "1" ]; then
            ovs-vsctl --may-exist add-port "$ovs_br" "$vxname" -- \
              set interface "$vxname" type=vxlan options:key="$vni" options:remote_ip=flow options:local_ip="$local_ip" options:nolearning=true options:csum=true || note "dynamic create failed"
          fi
          vxno="$(vx_ofport "$ovs_br" "$vni")"
        else
          [ "$VERIFY" = "1" ] && { warn "${VX_PREFIX}${vni} not on $ovs_br (VERIFY=1)"; continue; }
          note "${VX_PREFIX}${vni} not on $ovs_br (flows may fail)"
        fi
      fi

      [ -z "$tapno" ] && { note "No ofport for $ifname on $ovs_br"; continue; }
      [ -z "$vxno" ]  && { note "No ofport for ${VX_PREFIX}${vni} on $ovs_br"; continue; }

      tag_iface_vni "$ifname" "$vni"
      cookie="$(cookie_for_nic "$nic")"
      add_flows "$ovs_br" "$tapno" "$vxno" "$vni" "$cookie"
    done
    exit 0
    ;;

  post-stop)
    for nic in $(list_vm_nics); do
      set -- $(nic_mac_bridge "$nic"); br="${2:-}"
      [ -z "$br" ] && continue
      vni="$(vni_from_file "$vmid" "$nic")"
      [ -z "$vni" ] && vni="$(bridge_vni_fallback "$br")"
      [ -z "$vni" ] && continue

      ifname="$(guess_iface "$nic")"
      [ -z "$ifname" ] && continue

      ovs_br="$(wait_member "$ifname" 10 200)"
      [ -z "$ovs_br" ] && continue

      cookie="$(cookie_for_nic "$nic")"
      del_flows_by_cookie "$ovs_br" "$cookie"
    done
    exit 0
    ;;

  *)
    note "Unknown phase '${phase}' (no-op)"; exit 0
    ;;
esac
