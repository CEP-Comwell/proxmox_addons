#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-pve1.comwell.edgesec.ca}"
INVENTORY="$(dirname "$0")/../../inventory"
PLAYBOOK="$(dirname "$0")/../../edgesec-sdn/playbooks/provision_ovs_only.yml"

echo "Running OVS idempotency test against host: $HOST"

CMD_BASE=(ansible-playbook -i "$INVENTORY" "$PLAYBOOK" -e "inventory_hostname=$HOST write_interfaces_file=true perform_reload=false ovs_create=false" --limit "$HOST" --tags deploy_ovs_bridges -v)

echo "--- First run ---"
"${CMD_BASE[@]}"

echo "Collecting md5 after first run..."
ansible -i "$INVENTORY" "$HOST" -m command -a "md5sum /etc/network/interfaces" --limit "$HOST" -o

echo "--- Second run ---"
"${CMD_BASE[@]}"

echo "Collecting md5 after second run..."
ansible -i "$INVENTORY" "$HOST" -m command -a "md5sum /etc/network/interfaces" --limit "$HOST" -o

echo "Checking /etc/network/interfaces.new existence and md5"
ansible -i "$INVENTORY" "$HOST" -m command -a "test -f /etc/network/interfaces.new && md5sum /etc/network/interfaces.new || echo 'NO_INTERFACES_NEW'" --limit "$HOST" -o

echo "Done. If the md5 after first and second run are identical, the role is idempotent. /etc/network/interfaces.new should exist only if the file changed on first run (or always_create_interfaces_new was set)."
