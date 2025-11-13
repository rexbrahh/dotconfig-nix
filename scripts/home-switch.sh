#!/usr/bin/env bash
set -euo pipefail

FLAKE_ROOT="${FLAKE_ROOT:-.}"
PROFILE="${HOME_PROFILE:-server@ubuntu}"

home-manager switch --flake "${FLAKE_ROOT}#${PROFILE}" "$@"
