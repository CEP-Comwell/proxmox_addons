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

## Contributing
See the [root contributing guide](../../docs/contributing.md) for standards and prompt scaffolding.

---
For advanced Compose features (multiple services, networks, etc.), extend the role and template as needed.
