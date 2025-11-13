#!/usr/bin/env bash
set -euo pipefail

FLAKE_ROOT="${FLAKE_ROOT:-.}"
HOST="${DARWIN_HOST:-macbook}"

darwin-rebuild switch --flake "${FLAKE_ROOT}#${HOST}" "$@"
