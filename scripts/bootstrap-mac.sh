#!/usr/bin/env bash
# Bootstrap a macOS host: install Nix (Determinate), remove the installer’s daemon plist,
# ensure /nix is mounted, and run the flake switch. Keeps nix-darwin as the daemon owner.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This bootstrap script is for macOS." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLAKE_REF="${FLAKE_REF:-${REPO_ROOT}#macbook}"

install_nix_if_missing() {
  if command -v nix >/dev/null 2>&1 && [[ -d /nix ]]; then
    return
  fi
  echo "Installing Nix via Determinate installer..."
  curl -L https://install.determinate.systems/nix | sh -s -- install
}

ensure_nix_volume() {
  if mount | grep -q " on /nix "; then
    return
  fi

  local pw uuid
  pw="$(security find-generic-password -w -s "Nix Store Volume Password" 2>/dev/null || true)"
  if [[ -z "${pw}" ]]; then
    pw="$(security find-generic-password -w -s "Nix Volume Password" 2>/dev/null || true)"
  fi
  uuid="$(diskutil apfs list | awk '/Nix Store/ {uuid=$NF} END{print uuid}')"

  if [[ -n "${pw}" && -n "${uuid}" ]]; then
    sudo diskutil apfs unlockVolume "${uuid}" -passphrase "${pw}" || true
    sudo diskutil apfs mount "${uuid}" || true
  fi

  if ! mount | grep -q " on /nix "; then
    echo "Warning: /nix is not mounted; unlock it manually with diskutil." >&2
  fi
}

bootout_determinate_daemon() {
  local -a plists=(
    "/Library/LaunchDaemons/systems.determinate.nix-daemon.plist"
    "/Library/LaunchDaemons/io.determinate.nix.daemon.plist"
    "/Library/LaunchDaemons/org.nixos.nix-daemon.plist"
    "/Library/LaunchDaemons/nix-daemon.plist"
  )

  for plist in "${plists[@]}"; do
    if [[ -e "${plist}" ]]; then
      echo "Booting out existing daemon: ${plist}"
      sudo launchctl bootout system "${plist}" || true
      sudo rm -f "${plist}"
    fi
  done
}

run_switch() {
  # Use the flake app if available; fall back to darwin-rebuild directly.
  if NIXPKGS_ALLOW_UNFREE=1 nix run --extra-experimental-features 'nix-command flakes' "${FLAKE_REF}"#switch; then
    return
  fi
  echo "Falling back to darwin-rebuild..." >&2
  NIXPKGS_ALLOW_UNFREE=1 darwin-rebuild switch --flake "${FLAKE_REF}"
}

install_nix_if_missing
ensure_nix_volume
bootout_determinate_daemon
run_switch
