# edgesec-REST Backend

Implements the backend for device enrollment and integration, following clean architecture and facade patterns.

## Features
- Modular, testable TypeScript codebase
- Core business logic for device enrollment
- Integration hub and adapters for external systems (Vault, Authentik, etc.)
- CLI runner and Jest tests

See [../import/edgesec-radius.md](../import/edgesec-radius.md) for conceptual design.

## Directory Structure
- `src/application/` — Business logic and use cases
- `src/infrastructure/` — Integrations, adapters, facades
- `src/cli/` — CLI entry points
- `src/config.ts` — Main config for endpoints and credentials
- `tests/` — Jest tests for modules

## Quick Start

1. **Install dependencies:**
	```bash
	npm install
	```

2. **Configure endpoints and credentials:**
	Edit `src/config.ts` or set environment variables:
	- `VAULT_ADDR`, `VAULT_TOKEN`, `AUTHENTIK_URL`, `SMALLSTEP_CA_URL`, `FREERADIUS_SERVER`, `NETBOX_URL`, `CERT_TENANT`

3. **Enroll a device using the CLI:**
	```bash
	npm run enroll <deviceId>
	```
	Example:
	```bash
	npm run enroll device123
	```

4. **Run tests:**
	```bash
	npm test
	```

## Configuration

- **Main config:**
  - Use `src/config.ts` for API endpoints, credentials, and other settings.
  - You can also set environment variables for production or CI/CD.
- **Variables and credentials:**
  - Adapters (e.g., `DeviceAdapter.ts`) import settings from `src/config.ts`.

## References
See [../import/edgesec-radius.md](../import/edgesec-radius.md) for conceptual design and architecture.
