#!/usr/bin/env bash
set -euo pipefail

FLAKE_ROOT="${FLAKE_ROOT:-.}"
HOST="${NIXOS_HOST:-nixos-vm-m4}"

sudo nixos-rebuild switch --flake "${FLAKE_ROOT}#${HOST}" "$@"
