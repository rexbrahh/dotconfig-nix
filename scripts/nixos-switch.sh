#!/usr/bin/env bash
set -euo pipefail

FLAKE_ROOT="${FLAKE_ROOT:-.}"
HOST="${NIXOS_HOST:-framework}"

sudo nixos-rebuild switch --flake "${FLAKE_ROOT}#${HOST}" "$@"
