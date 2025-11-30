#!/usr/bin/env python3
import json,subprocess,shlex
subprocess.call(shlex.split('ovs-vsctl --format=json list Interface > /tmp/interfaces.json'))
j=json.load(open('/tmp/interfaces.json'))
cols=j['headings']
idx_name=cols.index('name')
for row in j['data']:
    name=row[idx_name]
    if isinstance(name,list) and name:
        name=name[0]
    if not (isinstance(name,str) and name.startswith('vx')):
        continue
    try:
        br = subprocess.check_output(['ovs-vsctl','port-to-br',name], stderr=subprocess.DEVNULL).decode().strip()
    except Exception:
        br = ''
    local_ip = ''
    if br == 'vmbr99':
        local_ip = '10.255.0.99'
    elif br == 'vmbr1':
        local_ip = '10.255.0.1'
    cmd = f'ovs-vsctl set Interface {name} type=vxlan options:key="flow" options:remote_ip=flow'
    if local_ip:
        cmd += f' options:local_ip="{local_ip}"'
    print('RUN:',cmd)
    subprocess.call(shlex.split(cmd))
print('done')
