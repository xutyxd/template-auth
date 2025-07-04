**README\_ORY\_STACK.md**\
Detailed setup for PostgreSQL + ORY Kratos + ORY Hydra + ORY Keto via Docker Compose

---

## 🎯 Objective

This repository provides a **complete Docker Compose** stack to spin up:

- **PostgreSQL**: Shared relational database
- **ORY Kratos**: Identity and user management (registration, login)
- **ORY Hydra**: OAuth2 / OpenID Connect server (authorization)
- **ORY Keto**: Fine‑grained authorization (permission management)

Use this stack as a **foundation** for building applications with secure authentication, authorization, and user management.

---

## 🔌 Prerequisites

1. **Docker** ≥ 20.10
2. **Docker Compose** ≥ 1.29
3. **Git** (to clone this repo)
4. **OpenSSL** (for generating secrets)
5. A command‑line HTTP tool (e.g. `curl` or `httpie`)

---

## 📁 Directory Structure

```bash
├── docker-compose.yml
├── kratos/
│   ├── kratos.yml
│   └── identity.schema.json
├── keto/
│   └── keto.yml
└── README.md
```

---

## 🚀 Installation & Startup

1. **Clone the repo**:

   ```bash
   git clone https://github.com/xutyxd/template-auth.git && cd template-auth
   ```

2. **(Optional) Generate cryptographic secrets**:

   ```bash
   export KRATOS_SECRET=$(openssl rand -hex 32)
   export HYDRA_SYSTEM_SECRET=$(openssl rand -hex 32)
   export HYDRA_SALT=$(openssl rand -hex 32)
   ```

3. **Review** and ensure **no port conflicts** on your machine.

4. **Start the stack**:

   ```bash
   docker compose up -d
   ```

5. **Verify containers** are running:

   ```bash
   docker ps --filter "name=ory-"
   ```

---

## 🔧 Configuration

### 1. `docker-compose.yml`

Contains service definitions and shared network.

### 2. Kratos (`kratos/kratos.yml`)

- **DSN**: `postgres://ory:secret@postgres:5432/ory?sslmode=disable`
- **Secrets**: Replace `changeme` with `$KRATOS_SECRET`
- **Self‑service UI URLs**: Update `ui_url` to your front‑end endpoints

### 3. Kratos Identity Schema (`kratos/identity.schema.json`)

Defines user traits (e.g. email).

### 4. Keto (`keto/keto.yml`)

- **DSN**: same as Kratos
- **Namespaces**: Pre‑defined `default` namespace; add more as needed

---

## 🔐 Environment Variables & Secrets

| Service | Variable                                 | Description                           |
| ------- | ---------------------------------------- | ------------------------------------- |
| Kratos  | `DSN`                                    | Database connection string            |
|         | `SECRETS_DEFAULT`                        | Argon2 hashing secret (hex, 32 bytes) |
| Hydra   | `DSN`                                    | Database connection string            |
|         | `SECRETS_SYSTEM`                         | Hydra system secret (hex, 32 bytes)   |
|         | `OIDC_SUBJECT_IDENTIFIERS_PAIRWISE_SALT` | Pairwise salt (hex, 32 bytes)         |
| Keto    | `DSN`                                    | Database connection string            |

> **Tip**: Use `openssl rand -hex 32` to generate each secret.

---

## 🐞 Troubleshooting

- **Ports in use**: Change host ports in `docker-compose.yml` or stop conflicting services.
- **Database migrations fail**:
  ```bash
  docker logs ory-kratos | grep ERROR
  ```
- **Kratos UI unreachable**: Ensure your front‑end URLs match `ui_url` in `kratos.yml`.
- **Hydra clients not created**: Use the Admin API on port `4445` (e.g. `http://localhost:4445/clients`).
- **Keto permission errors**: Check namespace and tuple payload formats.

---

## 📚 Basic Tutorial: Realm, Users, Groups, Roles & Permissions

### 1. Create a Keto Namespace (Realm)

```bash
curl -X POST http://localhost:4467/namespaces/default
# Already exists by default; to add another:
curl -X POST http://localhost:4467/namespaces \
  -d '{"id": "projects"}' -H 'Content-Type: application/json'
```

### 2. Register a User in Kratos

```bash
curl -X POST http://localhost:4434/self-service/registration/api \
  -H 'Content-Type: application/json' \
  -d '{
    "method": "password",
    "traits": {"email": "alice@example.com"},
    "password": "P@ssw0rd"
  }'
```

### 3. Create a Group / Role (via Keto Relation Tuples)

```bash
# Define "group:admins" as a role in namespace "default"
# Assign user to group:
curl -X PUT http://localhost:4466/relation-tuples \
  -H 'Content-Type: application/json' \
  -d '{
    "namespace": "default",
    "object": "group:admins",
    "relation": "member",
    "subject_id": "user:alice@example.com"
  }'
```

### 4. Define Permissions on Resources

```bash
# Allow admins to manage "project:123"
curl -X PUT http://localhost:4466/relation-tuples \
  -H 'Content-Type: application/json' \
  -d '{
    "namespace": "default",
    "object": "project:123",
    "relation": "manage",
    "subject_set": {
      "namespace": "default",
      "object": "group:admins",
      "relation": "member"
    }
  }'
```

### 5. Check Permission

```bash
curl -G http://localhost:4466/check \
  --data-urlencode 'namespace=default' \
  --data-urlencode 'object=project:123' \
  --data-urlencode 'relation=manage' \
  --data-urlencode 'subject_id=user:alice@example.com'
# Expected: { "allowed": true }
```

---

**Enjoy building with ORY!**\
Feel free to extend schemas, namespaces, and permission rules as your application grows.

