#!/bin/bash

# Initialize environment
echo "⚙️  Initializing environment..."
mkdir -p backups

# Generate passwords if not exists
if [ ! -f .env ]; then
  echo "🔑 Generating new credentials..."
  cat > .env <<EOL
KEYCLOAK_DOMAIN=auth.example.com
ADMIN_PASSWORD=$(openssl rand -base64 24)
DB_PASSWORD=$(openssl rand -base64 24)
EOL
fi

# Start services
echo "🚀 Starting services..."
docker-compose up -d

# Wait for Keycloak initialization
echo "⏳ Waiting for Keycloak to start (30 seconds)..."
sleep 30

# Initialize realm (example)
echo "🏰 Creating initial realm..."
docker-compose exec keycloak /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8080 \
  --realm master \
  --user admin \
  --password ${ADMIN_PASSWORD}

docker-compose exec keycloak /opt/keycloak/bin/kcadm.sh create realms \
  -s realm=origin-app \
  -s enabled=true

echo "✅ Deployment complete!"
echo "Admin URL: https://${KEYCLOAK_DOMAIN}/admin"
echo "Admin Password: ${ADMIN_PASSWORD}"