# docker_app_deploy — Universal Ansible Role for Secure Docker App Deployment

## Overview
This role deploys any Dockerized application using a variable-driven approach, with support for:
- Dynamic docker-compose generation
- HashiCorp Vault secret injection
- Traefik label auto-injection for reverse proxying
- Portainer or native Compose deployment
- App-specific config templating

## Directory Structure
```
roles/
  docker_app_deploy/
    defaults/
      main.yml
    tasks/
      main.yml
      fetch_secrets.yml
      deploy_app.yml
    templates/
      docker-compose.yml.j2
      # (add app config templates as needed)
    README.md
```

## Variables (set in playbook, group_vars, or host_vars)

- `app_name`: Name of the app/service (required)
- `image`: Docker image (required)
- `env_vars`: Dict of environment variables
- `volumes`: List of volume mappings
- `ports`: List of port mappings
- `labels`: List of extra container labels
- `configs`: List of config templates to render (see below)
- `vault_secrets`: Dict of secrets to fetch from Vault
- `use_portainer`: Deploy via Portainer API (default: false)
- `portainer_url`, `portainer_token`: Portainer API details

### Traefik Integration
- `docker_app_deploy__traefik_enable`: Auto-label for Traefik (default: true)
- `docker_app_deploy__traefik_router_host`: Hostname for Traefik rule
- `docker_app_deploy__traefik_entrypoints`: Traefik entrypoints
- `docker_app_deploy__traefik_service_port`: Service port for Traefik
- `docker_app_deploy__traefik_labels_extra`: List of extra Traefik labels


## Running the Playbook

To deploy an app using this role, run the following command from your project root:

```bash
ansible-playbook -i <inventory_file> edgesec-deploy/edgesec-deploy-docker.yml
```

- Replace `<inventory_file>` with your Ansible inventory (e.g., `inventory`, `hosts`, or an inline host string).
- You can override variables at the command line with `-e` if needed:

```sh
# Example: Deploy Plex with this universal role
ansible-playbook -i inventory edgesec-deploy/edgesec-deploy-docker.yml \
  -e app_name=plex \
  -e image=linuxserver/plex
```

## Example Usage

**Playbook:**
```yaml
- hosts: myapps
  roles:
    - role: docker_app_deploy
      vars:
        app_name: dashy
        image: lissy93/dashy:latest
        env_vars:
          NODE_ENV: "production"
        volumes:
          - ./conf.yml:/app/public/conf.yml:ro
        ports:
          - "8081:80"
        docker_app_deploy__traefik_router_host: "dashy.mydomain.com"
        docker_app_deploy__traefik_entrypoints: "websecure"
        docker_app_deploy__traefik_labels_extra:
          - "traefik.http.routers.dashy.tls=true"
        configs:
          - src: conf.yml.j2
            dest: /opt/dashy/conf.yml
            mode: "0640"
        vault_secrets:
          dashy_conf: "secret/data/dashy/conf conf"
```

**App Config Template Example (`templates/conf.yml.j2`):**
```jinja
{{ dashy_conf }}
```

## Notes
- Store per-app variables in playbooks, `group_vars/`, or `host_vars/`.
- Add app config templates to `roles/docker_app_deploy/templates/` as needed.
- All secrets are fetched securely from Vault and never stored in version control.
- Traefik labels are injected by default for reverse proxying.

---
For advanced Compose features (multiple services, networks, etc.), extend the role and template as needed.

---

## Firewalld Baseline Deployment

`edgesec-deploy/playbooks/firewalld.yml` hardens a host firewall by enforcing a locked-down `ztna_drop` zone, enabling only SSH access plus ICMP echo replies, and layering a default Fail2Ban configuration. Use it to bootstrap freshly provisioned hosts before exposing them to the fabric.

### Prerequisites
- Target hosts reachable over SSH; defaults assume the `ssh` service is required.
- Privileged connection (the play escalates with `become: true`).
- Python 3.x on the remote host for Ansible modules.

### Quick Start
Run the play against a single host using an inline inventory string:

```bash
ansible-playbook \
  -i '172.16.10.53,' \
  -u cpadmin \
  -b \
  edgesec-deploy/playbooks/firewalld.yml
```

Replace the inventory string and SSH username as needed. Use your project inventory file instead of an inline string for multi-host runs.

### Customisation
- `allowed_services`: list of firewalld services to keep reachable in the `ztna_drop` zone (default: `ssh`).
- `allowed_rich_rules`: list of rich rules applied permanently; includes an ICMP echo-request rule so the host answers pings.
- `firewalld_masquerade_enabled`: set to `false` to skip enabling NAT masquerade (default: `true`).
- `firewalld_masquerade_zone`: zone where masquerade should be enabled (default: `ztna_drop`; set to `public` if you prefer the stock zone).

Override either variable at runtime with `-e` or via `group_vars` / `host_vars` if a host needs additional exposure, e.g.:

```bash
ansible-playbook -i inventory edgesec-deploy/playbooks/firewalld.yml \
  -e '{"allowed_services":["ssh","https"]}'
```

### Verification
From another node on the same network, confirm that only the expected endpoints respond:

- `nmap -Pn -sS 172.16.10.53` — TCP SYN scan across Nmap's top ports; should report only `ssh` as open.
- `nmap -Pn -sU --top-ports 50 172.16.10.53` — quick UDP sweep; expect the ports to be filtered.
- `nmap -Pn --top-ports 100 --reason 172.16.10.53` — shows whether closed ports are dropped or rejected.
- `ping 172.16.10.53` — succeeds because the play enables ICMP echo replies.

Investigate any additional open or `open|filtered` ports that appear; add them to `allowed_services` only when intentionally exposing a service.

### Docker Host Considerations
If the host will also run Docker or Portainer, keep enforcement in firewalld so the firewall baseline stays authoritative:

- Bind Docker's bridge into a dedicated zone once the engine is installed, for example:
  - `firewall-cmd --permanent --zone=docker --change-interface=docker0`
  - Persist this via Ansible using a `command`/`firewalld` task guarded by `when: docker_installed`.
- Update the playbook variables to NAT traffic for that zone by setting `firewalld_masquerade_zone: docker` (and leaving `firewalld_masquerade_enabled: true`).
- Expose container services intentionally either by name (for well-known services) or by port. Examples using `-e` overrides:

```bash
# Allow HTTPS (port 443) in addition to SSH
ansible-playbook -i inventory edgesec-deploy/playbooks/firewalld.yml \
  -e '{"allowed_services":["ssh","https"],"firewalld_masquerade_zone":"docker"}'

# Allow Portainer UI on TCP 9443 via a rich rule
ansible-playbook -i inventory edgesec-deploy/playbooks/firewalld.yml \
  -e '{"firewalld_masquerade_zone":"docker",
        "allowed_services":["ssh"],
        "allowed_rich_rules":["rule icmp-type name=\"echo-request\" accept",
                               "rule family=\"ipv4\" port protocol=\"tcp\" port=\"9443\" accept"]}'
```

For recurring custom ports, add them to `group_vars` / `host_vars` so the rich rules are version-controlled. Keep the zone target at `DROP` so only these explicit exceptions pass through.

When Docker's own iptables management is disabled (`"iptables": false` in `/etc/docker/daemon.json`), firewalld remains the single source of truth. If you retain Docker's default iptables behavior, monitor `iptables-save` outputs to ensure additional ACCEPT rules do not conflict with the locked-down zones.
