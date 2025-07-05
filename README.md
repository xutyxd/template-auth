## Basic Description

This repository provides a fully integrated Identity and Access Management (IAM) stack leveraging the ORY suite (Kratos, Hydra, Keto) alongside essential infrastructure services. All components are orchestrated via Docker Compose, enabling rapid deployment of:

- **ORY Kratos** for user management (registration, login, recovery).
- **ORY Hydra** for OAuth2 and OpenID Connect flows.
- **ORY Keto** for fine-grained role-based access control (RBAC) and permission management.
- **PostgreSQL** as the shared datastore for all ORY services.
- **Cloudflared** for secure tunneling (e.g., exposing local services through Cloudflare Tunnels).

This setup ensures a scalable, secure, and modular authentication and authorization foundation suitable for production-grade applications in enterprise environments.

---

## Services Overview

### 1. cloudflared

**Use:** Establishes a secure tunnel to expose local services over the internet using Cloudflare's network.

**Why Required:** Provides easy and secure access to internal services (e.g., ORY endpoints) without managing public DNS or firewall rules. Ideal for demos, development, or staging environments.

### 2. postgres

**Use:** Runs PostgreSQL 16 (Alpine), serving as the persistent datastore for Kratos, Hydra, and Keto.

**Why Required:** Centralized, reliable SQL database ensures data consistency and supports migrations. Environment variables configure separate schemas for each ORY service to avoid conflicts.

### 3. kratos-migrate

**Use:** Executes schema migrations for ORY Kratos before the main service starts.

**Why Required:** Automates database bootstrapping and ensures that the `kratos` service has the correct tables and indices. The migration container runs only once per deploy.

### 4. kratos

**Use:** Provides the Identity API (registration, login, profile management, session handling).

**Why Required:** Core identity management service handling self-service flows via REST endpoints. Configured via `config/kratos/kratos.yml`.

**Example Usage:**

1. **Initialize Registration Flow**

   ```bash
   # Start a browser-based registration flow
   curl \
     -X GET "http://localhost:4433/self-service/registration/browser" \
     -c "cookies.txt"
   ```

2. **Submit Registration Form**

   ```bash
   curl \
     -X POST "http://localhost:4433/self-service/registration?flow=<FLOW_ID>" \
     -b "cookies.txt" -c "cookies.txt" \
     -H "Content-Type: application/json" \
     -d '{"traits": {"email": "user@example.com"}, "password": "P@ssw0rd!"}'
   ```

3. **Login Flow**

   ```bash
   # Initialize
   curl -X GET "http://localhost:4433/self-service/login/browser" -c cookies.txt

   # Submit
   curl -X POST "http://localhost:4433/self-service/login?flow=<FLOW_ID>" \
     -b cookies.txt -c cookies.txt \
     -H "Content-Type: application/json" \
     -d '{"identifier": "user@example.com", "password": "P@ssw0rd!"}'
   ```

---

### 5. hydra-migrate

**Use:** Applies database migrations for ORY Hydra.

**Why Required:** Ensures that the Hydra database schema is up-to-date before serving OAuth2 requests.

### 6. hydra

**Use:** OAuth2 and OpenID Connect provider handling client management, consent dialogues, and token issuance.

**Why Required:** Implements industry-standard protocols to secure API access. Configured in `config/hydra` and runs in developer mode for rapid iterations.

**Example Usage:**

1. **Register an OAuth2 Client**

   ```bash
   hydra clients create \
     --endpoint http://localhost:4445 \
     --id my-client \
     --secret s3cr3t \
     --grant-types authorization_code,refresh_token \
     --response-types code,id_token \
     --scope openid,offline \
     --callbacks http://localhost:3000/callback
   ```

2. **Authorize and Obtain Code**

   ```bash
   # Open in browser:
   http://localhost:4444/oauth2/auth?response_type=code&client_id=my-client&scope=openid%20offline&redirect_uri=http://localhost:3000/callback
   ```

3. **Exchange Code for Tokens**

   ```bash
   curl -X POST "http://localhost:4444/oauth2/token" \
     -u my-client:s3cr3t \
     -d grant_type=authorization_code \
     -d code=<CODE> \
     -d redirect_uri=http://localhost:3000/callback
   ```

---

### 7. keto-migrate

**Use:** Applies migrations for ORY Keto's permission storage.

**Why Required:** Prepares the permissions database schema to support policy definitions and enforcement.

### 8. keto

**Use:** Fine-grained authorization engine supporting Access Control Lists (ACLs), Role-Based Access Control (RBAC), and more.

**Why Required:** Decouples authorization logic from application code, offering high performance and consistency.

**Example Usage:**

1. **Define a Permission Policy**

   ```bash
   # Create a JSON policy file (policy.json)
   cat <<EOF > policy.json
   {
     "id": "document:read",
     "description": "Allow reading documents",
     "subjects": ["user:alice"],
     "resources": ["document:123"],
     "actions": ["read"]
   }
   EOF

   # Apply policy via Keto Admin API
   curl -X PUT "http://localhost:4467/engines/acp/ory/policies/document:read" \
     -H "Content-Type: application/json" \
     -d @policy.json
   ```

2. **Check a Permission**

   ```bash
   curl -X POST "http://localhost:4466/engines/acp/ory/allowed" \
     -H "Content-Type: application/json" \
     -d '{"subject": "user:alice", "resource": "document:123", "action": "read"}'
   ```

---

## Getting Started

1. **Prerequisites**

   - Docker Engine >= 24.x
   - Docker Compose CLI
   - Environment variables file (`.env`) with credentials and secrets (e.g., `POSTGRES_USER`, `HYDRA_SYSTEM_SECRET`, etc.)

2. **Launching the Stack**

   ```bash
   docker-compose up -d
   ```

3. **Verify Services**

   ```bash
   docker-compose ps
   ```

4. **Access Dashboards and Endpoints**

   - Kratos Public: [http://localhost:4433](http://localhost:4433)
   - Kratos Admin: [http://localhost:4434](http://localhost:4434)
   - Hydra Public: [http://localhost:4444](http://localhost:4444)
   - Hydra Admin: [http://localhost:4445](http://localhost:4445)
   - Keto Read API: [http://localhost:4466](http://localhost:4466)
   - Keto Admin API: [http://localhost:4467](http://localhost:4467)

---

## Best Practices

- **Secrets Management:** Integrate with a secret manager (e.g., Vault) instead of storing `.env` in version control.
- **TLS Everywhere:** Terminate TLS at Cloudflare or via a sidecar to secure all traffic.
- **Production Mode:** Replace `--dev` flags and configure distributed Datastores, persistent volumes, and backup strategies.
- **Monitoring & Logging:** Integrate with Prometheus/Grafana and structured logging for observability.

---