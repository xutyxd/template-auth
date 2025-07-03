# Generate secrets (at least 32+ chars recommended)
mkdir -p data/authelia/secrets

head -c 32 /dev/urandom | base64 | tr -d '\n' > data/authelia/secrets/JWT_SECRET
head -c 32 /dev/urandom | base64 | tr -d '\n' > data/authelia/secrets/SESSION_SECRET
head -c 32 /dev/urandom | base64 | tr -d '\n' > data/authelia/secrets/STORAGE_PASSWORD
head -c 32 /dev/urandom | base64 | tr -d '\n' > data/authelia/secrets/STORAGE_ENCRYPTION_KEY