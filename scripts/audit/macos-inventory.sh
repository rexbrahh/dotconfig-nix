#!/usr/bin/env bash
set -euo pipefail

# macOS preferences and software inventory collector.
# Usage: scripts/audit/macos-inventory.sh [OUTPUT_DIR]
# If OUTPUT_DIR is omitted, a temp dir under /tmp is used.

ts=$(date +%Y%m%d-%H%M%S)
OUT_DIR=${1:-/tmp/macos-inventory-$ts}
mkdir -p "$OUT_DIR"

echo "Writing inventory to: $OUT_DIR" >&2

need() {
  command -v "$1" >/dev/null 2>&1 || echo "Warning: '$1' not found; some data may be missing" >&2
}

need defaults
need plutil
need jq

export_domain() {
  local domain="$1" alias="$2"
  if defaults domains | grep -q "$domain" || [ "$domain" = "NSGlobalDomain" ]; then
    # Export as XML and convert to JSON for easy diffing
    if defaults export "$domain" - 2>/dev/null | plutil -convert json -o "$OUT_DIR/$alias.json" - -r 2>/dev/null; then
      :
    else
      echo '{}' >"$OUT_DIR/$alias.json"
    fi
  else
    echo '{}' >"$OUT_DIR/$alias.json"
  fi
}

# Core domains
export_domain NSGlobalDomain NSGlobalDomain
export_domain com.apple.dock dock
export_domain com.apple.finder finder
export_domain com.apple.screencapture screencapture
export_domain com.apple.loginwindow loginwindow
export_domain com.apple.Spotlight Spotlight
export_domain com.apple.symbolichotkeys symbolichotkeys
export_domain com.apple.universalaccess universalaccess
export_domain com.apple.AppleMultitouchTrackpad trackpad
export_domain com.apple.driver.AppleBluetoothMultitouch.trackpad bttrackpad
export_domain com.apple.HIToolbox HIToolbox
export_domain com.apple.desktopservices desktopservices
export_domain com.apple.SoftwareUpdate SoftwareUpdate

# Default app handlers (LaunchServices)
LS_PLIST="$HOME/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"
if [ -f "$LS_PLIST" ]; then
  plutil -convert json -o - "$LS_PLIST" 2>/dev/null | jq '.' >"$OUT_DIR/launchservices.json" || true
fi

# Applications and services
if command -v brew >/dev/null 2>&1; then
  brew list --formula >"$OUT_DIR/brew-formulae.txt" 2>/dev/null || true
  brew list --cask >"$OUT_DIR/brew-casks.txt" 2>/dev/null || true
  brew services list >"$OUT_DIR/brew-services.txt" 2>/dev/null || true
fi

if command -v mas >/dev/null 2>&1; then
  mas list >"$OUT_DIR/mas.txt" 2>/dev/null || true
fi

ls -1 /Applications 2>/dev/null | sort >"$OUT_DIR/applications-root.txt" || true
ls -1 "$HOME/Applications" 2>/dev/null | sort >"$OUT_DIR/applications-user.txt" || true

# QuickLook plugins
if command -v qlmanage >/dev/null 2>&1; then
  qlmanage -m >"$OUT_DIR/quicklook.txt" 2>/dev/null || true
fi

# Fonts
ls -1 /Library/Fonts 2>/dev/null | sort >"$OUT_DIR/fonts-system.txt" || true
ls -1 "$HOME/Library/Fonts" 2>/dev/null | sort >"$OUT_DIR/fonts-user.txt" || true

# Launch agents
ls -1 /Library/LaunchAgents 2>/dev/null | sort >"$OUT_DIR/launchagents-system.txt" || true
ls -1 "$HOME/Library/LaunchAgents" 2>/dev/null | sort >"$OUT_DIR/launchagents-user.txt" || true

cat >"$OUT_DIR/README.txt" <<EOF
This directory contains a point-in-time snapshot of macOS preferences and
software inventory to help translate your settings into nix-darwin options.

Files:
- *json: exported defaults domains (converted to JSON for readability)
- brew-*.txt: Homebrew packages and services
- mas.txt: Mac App Store apps (if 'mas' is installed)
- applications-*.txt: Applications installed for all users and current user
- launchservices.json: default app handlers database (LSHandlers)
- quicklook.txt: QuickLook generators (if available)
- fonts-*.txt: Installed fonts (system and user)
- launchagents-*.txt: LaunchAgents present on system and user scope

Suggested next step:
1) Review the JSON in a diff tool and pick only keys you care about.
2) Use scripts/audit/generate-nix-defaults.sh to emit a nix-darwin snippet.
3) Commit curated changes into modules/ui.nix and test with 'darwin-rebuild --dry-run'.
EOF

echo "Done. Review files under: $OUT_DIR" >&2

