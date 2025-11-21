#!/usr/bin/env bash
set -euo pipefail

# Create a tarball of SSH and GPG keys for migration. Trust the network you copy this over.
# The tarball is written to ./backup.tar.gz relative to repo root.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/backup.tar.gz"

if [[ -e "$OUT" ]]; then
  echo "Refusing to overwrite existing $OUT; move it first." >&2
  exit 1
fi

umask 077

tar -czf "$OUT" \
  --directory="$HOME" \
  --exclude='.ssh/environment' \
  --exclude='.gnupg/.#*' \
  --exclude='.gnupg/S.*' \
  --exclude='.gnupg/*.conf' \
  .ssh \
  .gnupg

chmod 600 "$OUT"
echo "Wrote $OUT (permissions 600). Keep it offline and delete after use."
