#!/usr/bin/env bash
set -euo pipefail

echo ">> Starting database setup..."

# a) Ensure database service is running
echo ">> Ensuring database container is running..."
docker compose up -d db

# b) Wait for PostgreSQL to be ready
echo ">> Waiting for PostgreSQL to be ready..."
docker compose exec -T db bash -c 'until pg_isready -U app -d alerta; do sleep 1; done'

# c) Identify DB container ID
echo ">> Detecting container ID..."
CONTAINER_ID=$(docker compose ps -q db)

if [ -z "$CONTAINER_ID" ]; then
  echo "ERROR: The db service is not running or container ID could not be retrieved."
  exit 1
fi

# d) Copy schema and CSV files into container
echo ">> Copying schema and data files into container..."
docker cp src/db/schema.sql        "$CONTAINER_ID":/tmp/schema.sql
docker cp imports/stores.csv       "$CONTAINER_ID":/tmp/stores.csv
docker cp imports/sales_2024.csv   "$CONTAINER_ID":/tmp/sales_2024.csv

# e) Apply schema
echo ">> Applying database schema..."
docker compose exec -T db psql -U app -d alerta -v ON_ERROR_STOP=1 -f /tmp/schema.sql

# f) Import CSV data
echo ">> Importing CSV data into tables..."
docker compose exec -T db psql -U app -d alerta -c "\copy public.stores FROM '/tmp/stores.csv' WITH (FORMAT csv, HEADER true)"
docker compose exec -T db psql -U app -d alerta -c "\copy public.sales  FROM '/tmp/sales_2024.csv' WITH (FORMAT csv, HEADER true)"

echo "Done! Database schema and data successfully applied."

