| Priority | Category                      | Function Name                        | Description                                                                 |
|----------|-------------------------------|-----------------------------------------------------------------------------|
| 1        | Security & RBAC              | `authenticate_user_jwt()`            | Verify JWTs and attach identity to requests                                |
| 2        | Security & RBAC              | `enforce_tenant_context()`           | Apply tenant scoping to all operations                                     |
| 3        | Security & RBAC              | `authorize_action_rbac()`            | Enforce role-based access control                                          |
| 4        | Security & RBAC              | `log_audit_event()`                  | Record security-relevant and administrative actions                        |
| 5        | Observability & Ops          | `health_check()`                     | Provide liveness/readiness endpoints                                       |
| 6        | Observability & Ops          | `export_prometheus_metrics()`        | Expose Prometheus metrics for monitoring                                   |
| 7        | Observability & Ops          | `trace_request_flow()`               | Trace request/operation lifecycle for debugging                            |
| 8        | Integration & Extensibility  | `fetch_secret_from_vault()`          | Retrieve secrets from HashiCorp Vault (short-lived tokens)                 |
| 9        | API & Protocol Extensions    | `get_async_job_status()`             | Query background job status (queued/running/succeeded/failed)              |
| 10       | Inventory & Source Sync      | `sync_inventory_proxmox()`           | Gather VM/container/host metadata from Proxmox VE                          |
| 11       | Inventory & Source Sync      | `normalize_inventory_data()`         | Harmonize raw source payloads into a validated normalized model            |
| 12       | Inventory & Source Sync      | `cache_inventory_snapshot()`         | Create point-in-time snapshots of normalized inventory                     |
| 13       | Inventory & Source Sync      | `sync_inventory_netbox()`            | Ingest devices/interfaces/IPs from NetBox                                  |
| 14       | Inventory & Source Sync      | `sync_inventory_datto_rmm()`         | Pull asset/device data from Datto RMM (with pagination/backoff)            |
| 15       | API & Protocol Extensions    | `trigger_event_hook()`               | Emit hooks on system events (sync complete, errors, snapshots)             |
| 16       | Integration & Extensibility  | `send_notification()`                | Send alerts (e.g., Teams/email) on job results or incidents                |
| 17       | Orchestration & Automation   | `run_ansible_playbook()`             | Execute Ansible playbooks with tenant context and Vault-fetched secrets    |
| 18       | Orchestration & Automation   | `execute_workflow_pipeline()`        | Run multi-step orchestration pipelines (e.g., fetch→normalize→notify)      |
| 19       | Orchestration & Automation   | `rollback_last_operation()`          | Revert the last change/deployment using stored operation data              |
| 20       | Orchestration & Automation   | `handle_orchestration_error()`       | Centralize error capture, correlation, and recovery for pipelines          |
| 21       | Data Model & Context Mgmt    | `validate_context_schema()`          | Meta-validate proposed context/normalized JSON Schemas                     |
| 22       | Data Model & Context Mgmt    | `version_context_model()`            | Track and activate versions of the context/normalized model per tenant     |
| 23       | Data Model & Context Mgmt    | `extend_context_model()`             | Add domain-specific extensions to the normalized model with guardrails     |
| 24       | API & Protocol Extensions    | `register_custom_endpoint()`         | Dynamically add new REST endpoints (extensions)                            |
| 25       | Integration & Extensibility  | `load_plugin()`                      | Load external plugin modules at startup/runtime                            |
| 26       | Integration & Extensibility  | `call_external_api()`                | Hardened outbound HTTP (retries, jitter, timeouts, circuit breaker)        |
| 27       | Observability & Ops          | `log_system_event()`                 | Record operational events (deploys, migrations, throttling)               |
| 28       | Observability & Ops          | `render_admin_dashboard()`           | Admin UI for health, metrics, jobs, inventory counts, audits              |
| 29       | DevOps & CI/CD               | `build_docker_image()`               | Build reproducible service container images                                |
| 30       | DevOps & CI/CD               | `execute_integration_tests()`        | Run integration/E2E test suites (compose/mocked externals)                 |
| 31       | DevOps & CI/CD               | `run_ci_pipeline()`                  | Orchestrate CI (lint, typecheck, tests, scans)                             |
| 32       | DevOps & CI/CD               | `deploy_service_stack()`             | Deploy via Compose/Kubernetes with environment-scoped config               |
