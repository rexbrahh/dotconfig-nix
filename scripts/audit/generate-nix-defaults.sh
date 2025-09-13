#!/usr/bin/env bash
set -euo pipefail

# Generate a nix-darwin system.defaults snippet from exported JSON files
# created by scripts/audit/macos-inventory.sh
#
# Usage: scripts/audit/generate-nix-defaults.sh /path/to/inventory-dir > snippet.nix

IN_DIR=${1:?"Provide inventory directory (from macos-inventory.sh)"}
need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing '$1'" >&2; exit 1; }; }
need jq

jget() { # file key
  local f="$1" k="$2"
  jq -er --arg k "$k" '.[$k] // empty' "$f" 2>/dev/null || true
}

emit_kv() { # domain key val
  local dom="$1" key="$2" val="$3"
  echo "      $key = $val;"
}

emit_str() { # quote string for nix
  printf '"%s"' "$1" | sed 's/"/\\"/g'
}

NS="$IN_DIR/NSGlobalDomain.json"
DOCK="$IN_DIR/dock.json"
FINDER="$IN_DIR/finder.json"
SC="$IN_DIR/screencapture.json"
TP="$IN_DIR/trackpad.json"
LOGIN="$IN_DIR/loginwindow.json"
SU="$IN_DIR/SoftwareUpdate.json"

echo '{'
echo '  system.defaults = {'

# NSGlobalDomain
if [ -f "$NS" ]; then
  echo '    NSGlobalDomain = {'
  for k in ApplePressAndHoldEnabled KeyRepeat InitialKeyRepeat AppleShowAllExtensions NSAutomaticSpellingCorrectionEnabled; do
    v=$(jget "$NS" "$k" || true)
    if [[ -n "${v:-}" ]]; then
      case "$v" in
        true|false|[0-9]*) emit_kv NSGlobalDomain "$k" "$v" ;;
        *) emit_kv NSGlobalDomain "$k" "$(emit_str "$v")" ;;
      esac
    fi
  done
  echo '    };'
fi

# Dock
if [ -f "$DOCK" ]; then
  echo '    dock = {'
  for k in orientation tilesize magnification largesize autohide show-recents mru-spaces minimize-to-application; do
    v=$(jget "$DOCK" "$k" || true)
    if [[ -n "${v:-}" ]]; then
      case "$v" in
        true|false|[0-9]*) emit_kv dock "$k" "$v" ;;
        *) emit_kv dock "$k" "$(emit_str "$v")" ;;
      esac
    fi
  done
  echo '    };'
fi

# Finder
if [ -f "$FINDER" ]; then
  echo '    finder = {'
  for k in FXPreferredViewStyle ShowPathbar ShowStatusBar; do
    v=$(jget "$FINDER" "$k" || true)
    if [[ -n "${v:-}" ]]; then
      case "$v" in
        true|false|[0-9]*) emit_kv finder "$k" "$v" ;;
        *) emit_kv finder "$k" "$(emit_str "$v")" ;;
      esac
    fi
  done
  echo '    };'
fi

# Screencapture
if [ -f "$SC" ]; then
  echo '    screencapture = {'
  for k in location disable-shadow type; do
    v=$(jget "$SC" "$k" || true)
    if [[ -n "${v:-}" ]]; then
      case "$v" in
        true|false|[0-9]*) emit_kv screencapture "$k" "$v" ;;
        *) emit_kv screencapture "$k" "$(emit_str "$v")" ;;
      esac
    fi
  done
  echo '    };'
fi

# Trackpad (AppleMultitouch)
if [ -f "$TP" ]; then
  echo '    trackpad = {'
  for k in Clicking TrackpadThreeFingerDrag; do
    v=$(jget "$TP" "$k" || true)
    if [[ -n "${v:-}" ]]; then
      case "$v" in
        true|false|[0-9]*) emit_kv trackpad "$k" "$v" ;;
        *) emit_kv trackpad "$k" "$(emit_str "$v")" ;;
      esac
    fi
  done
  echo '    };'
fi

# Login Window
if [ -f "$LOGIN" ]; then
  echo '    loginwindow = {'
  for k in GuestEnabled; do
    v=$(jget "$LOGIN" "$k" || true)
    if [[ -n "${v:-}" ]]; then
      case "$v" in
        true|false|[0-9]*) emit_kv loginwindow "$k" "$v" ;;
        *) emit_kv loginwindow "$k" "$(emit_str "$v")" ;;
      esac
    fi
  done
  echo '    };'
fi

# Software Update (best-effort)
if [ -f "$SU" ]; then
  echo '    SoftwareUpdate = {'
  for k in AutomaticallyInstallMacOSUpdates AutomaticCheckEnabled; do
    v=$(jget "$SU" "$k" || true)
    if [[ -n "${v:-}" ]]; then
      case "$v" in
        true|false|[0-9]*) emit_kv SoftwareUpdate "$k" "$v" ;;
        *) emit_kv SoftwareUpdate "$k" "$(emit_str "$v")" ;;
      esac
    fi
  done
  echo '    };'
fi

echo '  };'
echo '}'

