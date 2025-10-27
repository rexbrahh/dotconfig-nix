#!/usr/bin/env bash
set -euo pipefail

RESTORE_SCRIPT="${HOME}/.tmux/plugins/tmux-resurrect/scripts/restore.sh"
GUARD_SESSION="__resurrect_guard"

# Ensure the restore script exists before proceeding.
if [[ ! -x "${RESTORE_SCRIPT}" ]]; then
  tmux display-message "tmux-resurrect: restore script missing at ${RESTORE_SCRIPT}"
  exit 1
fi

# Create a temporary guard session so the server never has zero sessions
# even if restore.sh removes the currently active one.
if ! tmux has-session -t "${GUARD_SESSION}" 2>/dev/null; then
  tmux new-session -d -s "${GUARD_SESSION}" -c "${HOME}" >/dev/null
fi

status=0
"${RESTORE_SCRIPT}" || status=$?

# Always drop the guard session once restore completes.
tmux kill-session -t "${GUARD_SESSION}" >/dev/null 2>&1 || true

if [[ ${status} -ne 0 ]]; then
  tmux display-message "tmux-resurrect restore failed (exit ${status})"
  exit "${status}"
fi
