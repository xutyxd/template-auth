#!/bin/bash
set -e

DB_SUFFIXES=("kratos" "hydra" "keto")

for suffix in "${DB_SUFFIXES[@]}"; do
  db="${POSTGRES_DB}_${suffix}"
  echo "Creating database if not exists: $db"

  psql --username "$POSTGRES_USER" --dbname=postgres <<-EOSQL
    SELECT 'CREATE DATABASE "$db"'
    WHERE NOT EXISTS (
      SELECT FROM pg_database WHERE datname = '$db'
    )\gexec
EOSQL

done
