#!/usr/bin/env python3
import yaml, subprocess, sys

f = '/tmp/ovn_geneve_ports.yml'

def main():
    try:
        with open(f) as fh:
            d = yaml.safe_load(fh)['ipam']
    except Exception as e:
        print('failed to read', f, e, file=sys.stderr)
        return 2

    for k, v in d.items():
        # prefer explicit logical_switch then fall back to vnet
        vnet = v.get('logical_switch') or v.get('vnet')
        cidr = v.get('subnet')
        gw = v.get('gateway')
        domain = v.get('dns_zone')
        idname = 'dvx' + k
        portname = 'dhcp-' + k

        # ensure logical switch exists (ls-add will noop/fail harmlessly if already present)
        ensure_ls = f"ovn-nbctl ls-add {vnet} || true"
        subprocess.run(ensure_ls, shell=True)

        # create DHCP_Options row and set its options, then create LSP and attach
        # create dhcp options and capture UUID
        create_cmd = f"ovn-nbctl dhcp-options-create {cidr}"
        print('RUNNING:', create_cmd)
        subprocess.run(create_cmd, shell=True)
        # grab last-created dhcp-options UUID (best-effort; assumes single operator)
        p = subprocess.run("ovn-nbctl dhcp-options-list | tail -n1", shell=True, capture_output=True, text=True)
        dhcp_uuid = p.stdout.strip().split()[0] if p.stdout else ''
        if not dhcp_uuid:
            print('failed to get dhcp uuid for', cidr, file=sys.stderr)
            continue
        # sometimes ovn-nbctl returns the uuid wrapped or with extra text; normalize
        if dhcp_uuid:
            dhcp_uuid = dhcp_uuid.split()[0].strip().strip('"')

        # set options on the DHCP_Options UUID
        opts = []
        if gw:
            opts.append(f"router={gw}")
            opts.append(f"server_id={gw}")
        if domain:
            opts.append(f"domain_name={domain}")
        if opts:
            # join options as KEY=VALUE arguments
            opts_str = ' '.join(opts)
            set_opts_cmd = f"ovn-nbctl dhcp-options-set-options {dhcp_uuid} {opts_str}"
            print('RUNNING:', set_opts_cmd)
            subprocess.run(set_opts_cmd, shell=True)

        # add logical switch port and attach dhcp options
        lsp_add = f"ovn-nbctl lsp-add {vnet} {portname} || true"
        print('RUNNING:', lsp_add)
        subprocess.run(lsp_add, shell=True)

        attach_cmd = f"ovn-nbctl lsp-set-dhcpv4-options {portname} {dhcp_uuid}"
        print('RUNNING:', attach_cmd)
        r = subprocess.run(attach_cmd, shell=True)
        if r.returncode != 0:
            print('attach dhcp options failed', r.returncode, file=sys.stderr)

    return 0

if __name__ == '__main__':
    sys.exit(main())
