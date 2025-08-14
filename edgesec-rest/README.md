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

	# edgesec-REST

	A Fastify v5 TypeScript API hub for edge security automation and orchestration.

	This service integrates Datto RMM, NetBox, NetBird, Proxmox VE 9, Ollama/OpenWebUI, and Microsoft Teams for inventory, SDN, HCI, and AI-driven workflows.

	---

	## Architecture Overview

	**Option A migration:** Fastify v5 is the single API service, with an optional `@fastify/express` bridge for legacy routes. The design is plugin-based, with connectors for Datto, NetBox, NetBird, Proxmox, Ollama, and Teams.

	```mermaid
	graph TD
		A[Fastify Core] --> B[Datto RMM Plugin]
		A --> C[NetBox Plugin]
		A --> D[NetBird Plugin]
		A --> E[Proxmox Plugin]
		A --> F[Ollama Plugin]
		A --> G[Teams Plugin]
	```

	---

	## Key Features

	- **Inventory sync:** Datto RMM → NetBox
	- **SDN automation:** NetBird peers/groups/policies
	- **HCI orchestration:** Proxmox VE (VM, SDN, ZFS datasets)
	- **AI integration:** Ollama (Mistral, OpenWebUI)
	- **Notifications:** Microsoft Teams (Graph API or Workflows webhooks)

	---

	## Tech Stack

	- Fastify v5 + TypeScript
	- JSON Schema validation
	- Docker & Docker Compose
	- Optional Next.js UI (future)
	- Node.js 20+ required

	---

	## Getting Started

	**Prerequisites:** Node.js 20+, npm

	```bash
	npm ci
	npm run dev
	npm run build
	npm start
	npm run lint
	npm test
	```

	---

	## Docker & Compose

	Build and run with Docker:

	```bash
	docker build -t edgesec-rest .
	docker compose up --build
	```

	The `docker-compose.yml` includes optional services for Ollama and OpenWebUI.

	---

	## Environment Variables

	Set these in your `.env` file (see `.env.example`):

	| Variable             | Description                       |
	|----------------------|-----------------------------------|
	| PORT                 | API port (default: 3001)          |
	| LOG_LEVEL            | Log level (info, debug, etc)      |
	| NETBOX_BASE_URL      | NetBox API base URL               |
	| NETBOX_TOKEN         | NetBox API token                  |
	| DATTO_BASE_URL       | Datto RMM API base URL            |
	| DATTO_PUBLIC_KEY     | Datto RMM public key              |
	| DATTO_SECRET_KEY     | Datto RMM secret key              |
	| NETBIRD_BASE_URL     | NetBird API base URL              |
	| NETBIRD_PAT          | NetBird personal access token      |
	| PVE_HOST             | Proxmox VE host                   |
	| PVE_TOKEN_ID         | Proxmox API token ID              |
	| PVE_TOKEN_SECRET     | Proxmox API token secret          |
	| OLLAMA_BASE_URL      | Ollama API base URL               |
	| GRAPH_TENANT_ID      | Microsoft Graph tenant ID         |
	| GRAPH_CLIENT_ID      | Microsoft Graph client ID         |
	| GRAPH_CLIENT_SECRET  | Microsoft Graph client secret     |

	---

	## Roadmap

	- **Phase 1:** Fastify migration complete
	- **Phase 2:** Connector plugins (Datto, NetBox, NetBird, Proxmox, Ollama, Teams)
	- **Phase 3:** Next.js UI (dashboard)
	- **Phase 4:** Advanced workflows (AI-assisted automation)

	---

	## License

	<!-- Keep existing license/legal info below this line -->
