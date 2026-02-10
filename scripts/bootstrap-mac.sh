#!/usr/bin/env bash
# Bootstrap a macOS host: install Nix (Determinate), ensure /nix is mounted,
# keep a working Nix daemon, and run the flake switch.
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This bootstrap script is for macOS." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLAKE_REF="${FLAKE_REF:-${REPO_ROOT}#macbook}"
FLAKE_PATH="${FLAKE_REF%%#*}"
FLAKE_HOST="${FLAKE_REF##*#}"
if [[ "${FLAKE_HOST}" == "${FLAKE_REF}" ]]; then
  FLAKE_HOST="macbook"
fi

ensure_nix_in_shell() {
  if command -v nix >/dev/null 2>&1; then
    return
  fi
  if [[ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # shellcheck source=/dev/null
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
}

nix_bin() {
  if command -v nix >/dev/null 2>&1; then
    command -v nix
    return
  fi
  if [[ -x /nix/var/nix/profiles/default/bin/nix ]]; then
    echo "/nix/var/nix/profiles/default/bin/nix"
    return
  fi
  return 1
}

install_nix_if_missing() {
  if [[ -x /nix/var/nix/profiles/default/bin/nix ]] && [[ -d /nix ]]; then
    return
  fi
  if command -v nix >/dev/null 2>&1 && [[ -d /nix ]]; then
    return
  fi
  echo "Installing Nix via Determinate installer..."
  curl -L https://install.determinate.systems/nix | sh -s -- install
  ensure_nix_in_shell
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

remove_legacy_nix_daemons() {
  local -a plists=(
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

restore_determinate_daemon() {
  local active_plist="/Library/LaunchDaemons/systems.determinate.nix-daemon.plist"
  local disabled_plist="/Library/LaunchDaemons/disabled.determinate/systems.determinate.nix-daemon.plist"

  if [[ ! -e "${active_plist}" && -e "${disabled_plist}" ]]; then
    echo "Restoring Determinate daemon plist: ${active_plist}"
    sudo cp "${disabled_plist}" "${active_plist}"
    sudo chown root:wheel "${active_plist}"
    sudo chmod 0644 "${active_plist}"
  fi

  if [[ -e "${active_plist}" ]] && ! launchctl print system/systems.determinate.nix-daemon >/dev/null 2>&1; then
    echo "Bootstrapping Determinate Nix daemon..."
    sudo launchctl bootstrap system "${active_plist}" || true
    sudo launchctl kickstart -k system/systems.determinate.nix-daemon || true
  fi

  if [[ ! -S /var/run/nix-daemon.socket ]]; then
    echo "Warning: nix daemon socket is unavailable at /var/run/nix-daemon.socket" >&2
  fi
}

run_switch() {
  ensure_nix_in_shell
  local nix_cmd
  nix_cmd="$(nix_bin)" || {
    echo "Error: nix binary not found after installation. Open a new shell or source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh." >&2
    exit 1
  }

  # Use the flake app if available; fall back to darwin-rebuild directly.
  if NIXPKGS_ALLOW_UNFREE=1 "${nix_cmd}" run --extra-experimental-features 'nix-command flakes' "${FLAKE_REF}"#switch; then
    return
  fi

  echo "Falling back to built darwin-rebuild..." >&2
  local out_link
  out_link="$(mktemp -u /tmp/darwin-system.XXXXXX)"
  NIXPKGS_ALLOW_UNFREE=1 "${nix_cmd}" build --impure "${FLAKE_PATH}#darwinConfigurations.${FLAKE_HOST}.system" --out-link "${out_link}"
  sudo NIXPKGS_ALLOW_UNFREE=1 "${out_link}/sw/bin/darwin-rebuild" switch --impure --flake "${FLAKE_PATH}#${FLAKE_HOST}"
}

install_nix_if_missing
ensure_nix_volume
remove_legacy_nix_daemons
restore_determinate_daemon
run_switch
