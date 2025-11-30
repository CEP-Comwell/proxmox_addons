#!/usr/bin/env python3
import json,subprocess,shlex
j=json.load(open('/tmp/interfaces.json'))
cols=j['headings']
idx_name=cols.index('name')
idx_type=cols.index('type')
idx_options=cols.index('options')
for row in j['data']:
    name=row[idx_name]
    if isinstance(name,list) and name:
        name=name[0]
    if not (isinstance(name,str) and name.startswith('vx')):
        continue
    t=row[idx_type]
    opts=row[idx_options]
    has_flow=False
    if isinstance(opts,list) and len(opts)>1 and isinstance(opts[1],list):
        for k,v in opts[1]:
            if k=='key' and v=='flow':
                has_flow=True
    if isinstance(t,str) and t=='vxlan' and has_flow:
        print(f"SKIP {name} (ok)")
        continue
    print(f"PROCESS {name} (type={t} options={opts})")
    # backup
    subprocess.call(shlex.split(f"ovs-vsctl --format=json list Interface {name}"), stdout=open(f"/tmp/{name}.json","w"))
    # find bridge
    br = ''
    try:
        br = subprocess.check_output(shlex.split(f"ovs-vsctl port-to-br {name}"), stderr=subprocess.DEVNULL).decode().strip()
    except Exception:
        br = ''
    print(f"DELPORT {br} {name}")
    if br:
        subprocess.call(shlex.split(f"ovs-vsctl --if-exists del-port {br} {name}"))
    else:
        subprocess.call(shlex.split(f"ovs-vsctl --if-exists del-port {name}"))
print('done')
