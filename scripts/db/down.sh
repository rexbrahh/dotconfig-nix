#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE="${COMPOSE:-docker compose}"
$COMPOSE -f "$DIR/compose.yml" down -v --remove-orphans
echo "Postgres stopped and volumes removed."

