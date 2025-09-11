#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE="${COMPOSE:-docker compose}"

if ! command -v docker >/dev/null; then
  echo "docker not found. Use Orbstack/Colima/Docker Desktop or set COMPOSE='podman compose'"
fi

$COMPOSE -f "$DIR/compose.yml" up -d
echo "Postgres is up on localhost:5432 (postgres/postgres)"

