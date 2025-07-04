#!/usr/bin/env bash
set -euo pipefail

ENV_FILE=".env"
FORCE=false

print_header() {
  echo "🔐 ORY Secrets Generator"
  echo "------------------------"
}

usage() {
  echo "Usage: $0 [--force]"
  echo "  --force     Overwrite existing secrets"
  exit 1
}

generate_secret() {
  openssl rand -hex 32
}

write_env_var() {
  local key=$1
  local value=$2

  if grep -q "^${key}=" "$ENV_FILE"; then
    if [ "$FORCE" = true ]; then
      echo "⚠️  Overwriting $key in $ENV_FILE"
      sed -i.backup "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
    else
      echo "✅ $key already exists in $ENV_FILE, skipping"
    fi
  else
    echo "$key=${value}" >> "$ENV_FILE"
    echo "✅ Added $key to $ENV_FILE"
  fi
}

# Parse arguments
for arg in "$@"; do
  case $arg in
    --force) FORCE=true ;;
    *) usage ;;
  esac
done

print_header

# Ensure .env exists
if [ ! -f "$ENV_FILE" ]; then
  echo "📄 Creating $ENV_FILE"
  touch "$ENV_FILE"
fi

# Generate and store secrets
write_env_var "POSTGRES_PASSWORD" "$(generate_secret)"
write_env_var "KRATOS_SECRET" "$(generate_secret)"
write_env_var "HYDRA_SYSTEM_SECRET" "$(generate_secret)"
write_env_var "HYDRA_SALT" "$(generate_secret)"

echo "✅ All secrets written to $ENV_FILE"
