#!/usr/bin/env bash
set -euo pipefail

# Persistent macOS restore baseline exporter.
# Usage: scripts/audit/macos-restore-baseline.sh [OUTPUT_DIR]
#
# OUTPUT_DIR defaults to:
#   ~/restore-audit/macos-state-YYYYMMDD-HHMMSS
#
# The script reuses macos-inventory.sh and adds restore-critical state:
# - login items and background task data
# - launchd snapshot
# - TCC permission databases (best effort; system DB may require sudo/FDA)
# - system extension snapshot

ts="$(date +%Y%m%d-%H%M%S)"
OUT_DIR="${1:-$HOME/restore-audit/macos-state-$ts}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$OUT_DIR"
echo "Writing restore baseline to: $OUT_DIR" >&2

if [[ -f "$SCRIPT_DIR/macos-inventory.sh" ]]; then
  bash "$SCRIPT_DIR/macos-inventory.sh" "$OUT_DIR"
else
  echo "Warning: $SCRIPT_DIR/macos-inventory.sh is missing" >&2
fi

{
  echo "timestamp_utc: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "timestamp_local: $(date +%Y-%m-%dT%H:%M:%S%z)"
  echo
  sw_vers 2>/dev/null || true
  echo
  uname -a
} >"$OUT_DIR/system-info.txt"

# Login items (GUI startup apps)
osascript -e 'tell application "System Events" to get the name of every login item' \
  >"$OUT_DIR/login-items.raw.txt" 2>"$OUT_DIR/login-items.stderr.txt" || true
osascript -e 'tell application "System Events" to get the properties of every login item' \
  >"$OUT_DIR/login-items.properties.txt" 2>"$OUT_DIR/login-items.properties.stderr.txt" || true
python3 - "$OUT_DIR" <<'PY'
import json
import pathlib
import subprocess
import sys

out_dir = pathlib.Path(sys.argv[1])
items = []
error = None
try:
    raw = subprocess.check_output(
        ["osascript", "-e", 'tell application "System Events" to get the name of every login item'],
        text=True,
    ).strip()
    items = [x.strip() for x in raw.split(",") if x.strip()]
except Exception as exc:  # pragma: no cover
    error = str(exc)

payload = {
    "login_items": items,
    "count": len(items),
    "error": error,
}
(out_dir / "login-items.json").write_text(json.dumps(payload, indent=2) + "\n")
PY

# launchd snapshots (user + system)
uid="$(id -u)"
launchctl list >"$OUT_DIR/launchctl-user-list.txt" 2>&1 || true
launchctl print "gui/$uid" >"$OUT_DIR/launchctl-user-print.txt" 2>&1 || true
launchctl print-disabled "gui/$uid" >"$OUT_DIR/launchctl-user-disabled.txt" 2>&1 || true
launchctl print system >"$OUT_DIR/launchctl-system-print.txt" 2>&1 || true
launchctl print-disabled system >"$OUT_DIR/launchctl-system-disabled.txt" 2>&1 || true

# Background items (Login Items -> Allow in the Background)
if command -v sfltool >/dev/null 2>&1; then
  sfltool dumpbtm >"$OUT_DIR/background-items.txt" 2>&1 || true
  awk -F': ' '/^[[:space:]]+Identifier: / {print $2}' "$OUT_DIR/background-items.txt" \
    | sed 's/^16\.//' \
    | sed '/^$/d' \
    | sort -u >"$OUT_DIR/background-item-identifiers.txt" || true
  awk '{s=$0; sub(/^[0-9]+\./,"",s); if (s ~ /^[A-Za-z0-9][A-Za-z0-9._-]+\.[A-Za-z0-9._-]+/) print s}' \
    "$OUT_DIR/background-item-identifiers.txt" \
    | rg -v '^(com\.apple\.|org\.nixos\.|org\.nix-community\.|homebrew\.mxcl\.)' \
    | sort -u >"$OUT_DIR/background-item-bundle-ids.txt" || true
fi

# System extensions (network/security/system extension state)
if command -v systemextensionsctl >/dev/null 2>&1; then
  systemextensionsctl list >"$OUT_DIR/system-extensions.txt" 2>&1 || true
fi

dump_tcc_sqlite() {
  local scope="$1"
  local db_path="$2"
  local out_prefix="$OUT_DIR/tcc-${scope}"

  python3 - "$db_path" "$out_prefix" <<'PY'
import csv
import json
import os
import sqlite3
import sys

db_path = sys.argv[1]
out_prefix = sys.argv[2]
meta = {"db_path": db_path, "readable": False, "tables": [], "errors": {}}

def to_csv_value(value):
    if isinstance(value, (bytes, bytearray)):
        return "0x" + bytes(value).hex()
    return value

if not os.path.exists(db_path):
    meta["errors"]["open"] = "database file not found"
    with open(f"{out_prefix}-meta.json", "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=2)
        f.write("\n")
    sys.exit(0)

try:
    # Use direct path connect for compatibility with spaces in macOS paths.
    conn = sqlite3.connect(db_path)
except Exception as exc:
    meta["errors"]["open"] = str(exc)
    with open(f"{out_prefix}-meta.json", "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=2)
        f.write("\n")
    sys.exit(0)

meta["readable"] = True
cur = conn.cursor()
cur.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY 1")
tables = [row[0] for row in cur.fetchall()]
meta["tables"] = tables

for table in ("access", "active_policy", "policies"):
    if table not in tables:
        continue
    try:
        cur.execute(f"SELECT * FROM {table}")
        cols = [d[0] for d in cur.description]
        rows = cur.fetchall()
    except Exception as exc:
        meta["errors"][table] = str(exc)
        continue

    with open(f"{out_prefix}-{table}.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(cols)
        for row in rows:
            writer.writerow([to_csv_value(v) for v in row])

    if table == "access" and "service" in cols:
        service_idx = cols.index("service")
        key_services = {
            "kTCCServiceAccessibility",
            "kTCCServiceAppleEvents",
            "kTCCServiceCamera",
            "kTCCServiceDeveloperTool",
            "kTCCServiceListenEvent",
            "kTCCServiceMicrophone",
            "kTCCServicePostEvent",
            "kTCCServiceScreenCapture",
            "kTCCServiceSystemPolicyAllFiles",
            "kTCCServiceSystemPolicyDesktopFolder",
            "kTCCServiceSystemPolicyDocumentsFolder",
            "kTCCServiceSystemPolicyDownloadsFolder",
            "kTCCServiceSystemPolicyNetworkVolumes",
            "kTCCServiceSystemPolicyRemovableVolumes",
        }
        with open(
            f"{out_prefix}-access-key-services.csv", "w", newline="", encoding="utf-8"
        ) as f:
            writer = csv.writer(f)
            writer.writerow(cols)
            for row in rows:
                if row[service_idx] in key_services:
                    writer.writerow([to_csv_value(v) for v in row])

with open(f"{out_prefix}-meta.json", "w", encoding="utf-8") as f:
    json.dump(meta, f, indent=2)
    f.write("\n")
PY
}

# TCC snapshots (best effort)
dump_tcc_sqlite "user" "$HOME/Library/Application Support/com.apple.TCC/TCC.db"

# System TCC usually requires root/FDA.
if [[ -r "/Library/Application Support/com.apple.TCC/TCC.db" ]]; then
  dump_tcc_sqlite "system" "/Library/Application Support/com.apple.TCC/TCC.db"
else
  cat >"$OUT_DIR/tcc-system-meta.json" <<'EOF'
{
  "db_path": "/Library/Application Support/com.apple.TCC/TCC.db",
  "readable": false,
  "errors": {
    "open": "needs sudo and Full Disk Access to read system TCC database"
  }
}
EOF
fi

cat >"$OUT_DIR/RESTORE-CHECKLIST.md" <<'EOF'
# Restore Baseline Checklist

1. Rebuild declarative state:
   - `cd ~/.config/nix && sudo NIXPKGS_ALLOW_UNFREE=1 ./result/sw/bin/darwin-rebuild switch --impure --flake "$PWD#macbook"`
2. Reinstall/verify Homebrew and MAS inventory from:
   - `brew-formulae.txt`, `brew-casks.txt`, `mas.txt`
3. Re-add Login Items and background helpers from:
   - `login-items.json`, `background-items.txt`
4. Re-grant privacy permissions from:
   - `tcc-user-access-key-services.csv` and `tcc-system-access-key-services.csv` (if available)
5. Restore launchd app/service behavior from:
   - `launchctl-user-print.txt`, `launchctl-user-disabled.txt`
6. Validate system extensions/network filters from:
   - `system-extensions.txt`
7. Re-check declarative safety:
   - ensure `modules/homebrew.nix` keeps `homebrew.onActivation.cleanup = "none"`
EOF

echo "Done. Baseline saved to: $OUT_DIR" >&2
