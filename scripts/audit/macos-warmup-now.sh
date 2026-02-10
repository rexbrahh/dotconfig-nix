#!/usr/bin/env bash
set -euo pipefail

# Fast "mac-warming" helper for post-restore macOS.
# - Reads background item identifiers from restore baseline
# - Maps likely app bundle IDs to installed .app paths
# - Optionally opens each app once to trigger permission/login/background prompts
#
# Usage:
#   scripts/audit/macos-warmup-now.sh [--open] [BASELINE_DIR]
#
# Defaults:
#   BASELINE_DIR=~/restore-audit/macos-state-latest

OPEN_APPS=0
if [[ "${1:-}" == "--open" ]]; then
  OPEN_APPS=1
  shift
fi

BASELINE_DIR="${1:-$HOME/restore-audit/macos-state-latest}"
IDS_FILE="$BASELINE_DIR/background-item-bundle-ids.txt"

if [[ ! -f "$IDS_FILE" ]]; then
  echo "Missing baseline file: $IDS_FILE" >&2
  echo "Run: /Users/rexliu/.config/nix/scripts/audit/macos-restore-baseline.sh $BASELINE_DIR" >&2
  exit 1
fi

OUT_FILE="$BASELINE_DIR/warmup-app-candidates.txt"

python3 - "$IDS_FILE" "$OUT_FILE" "$OPEN_APPS" <<'PY'
import pathlib
import re
import subprocess
import sys
import time
import plistlib

ids_path = pathlib.Path(sys.argv[1])
out_path = pathlib.Path(sys.argv[2])
open_apps = sys.argv[3] == "1"

raw_ids = [line.strip() for line in ids_path.read_text().splitlines() if line.strip()]

skip_prefixes = (
    "com.apple.",
    "org.nixos.",
    "org.nix-community.",
    "homebrew.mxcl.",
    "systems.determinate.",
)

skip_substrings = (
    ".helper",
    ".Helper",
    ".agent",
    ".Agent",
    ".daemon",
    ".Daemon",
    ".privhelper",
    ".QuickLook",
    ".Thumbnail",
    ".Spotlight",
    ".Importer",
    ".DockTilePlugin",
)

bundle_re = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]*\.[A-Za-z0-9._-]+$")

candidate_ids = []
for item in raw_ids:
    if not bundle_re.match(item):
        continue
    if item.startswith(skip_prefixes):
        continue
    if any(s in item for s in skip_substrings):
        continue
    candidate_ids.append(item)

seen = set()
candidate_ids = [x for x in candidate_ids if not (x in seen or seen.add(x))]

def find_app_spotlight(bundle_id: str) -> str | None:
    query = (
        'kMDItemContentType == "com.apple.application-bundle" '
        f'&& kMDItemCFBundleIdentifier == "{bundle_id}"'
    )
    try:
        out = subprocess.check_output(["mdfind", query], text=True).splitlines()
    except subprocess.CalledProcessError:
        return None
    for p in out:
        if p.endswith(".app"):
            return p
    return None

def build_plist_index() -> dict[str, str]:
    app_roots = [
        pathlib.Path("/Applications"),
        pathlib.Path.home() / "Applications",
        pathlib.Path("/Applications/Utilities"),
        pathlib.Path("/Library/Objective-See"),
        pathlib.Path.home() / "Library/Application Support/Google/GoogleUpdater",
    ]
    idx: dict[str, str] = {}
    seen_paths: set[str] = set()
    for root in app_roots:
        if not root.exists():
            continue
        for app in root.rglob("*.app"):
            app_str = str(app)
            if app_str in seen_paths:
                continue
            seen_paths.add(app_str)
            info = app / "Contents" / "Info.plist"
            if not info.exists():
                continue
            try:
                with info.open("rb") as f:
                    data = plistlib.load(f)
            except Exception:
                continue
            bid = data.get("CFBundleIdentifier")
            if isinstance(bid, str) and bid and bid not in idx:
                idx[bid] = app_str
    return idx

plist_index = build_plist_index()

def find_app(bundle_id: str) -> str | None:
    app = find_app_spotlight(bundle_id)
    if app:
        resolved = app
    else:
        resolved = plist_index.get(bundle_id)
    if not resolved:
        return None
    marker = "/Contents/Library/LoginItems/"
    if marker in resolved:
        return resolved.split(marker, 1)[0]
    return resolved

rows = []
for bundle_id in candidate_ids:
    app_path = find_app(bundle_id)
    rows.append((bundle_id, app_path or ""))

lines = []
lines.append(f"candidate_bundle_ids={len(candidate_ids)}")
lines.append(f"resolved_apps={sum(1 for _, p in rows if p)}")
lines.append("")
for bid, app in rows:
    if app:
        lines.append(f"{bid}\t{app}")
    else:
        lines.append(f"{bid}\tMISSING")
out_path.write_text("\n".join(lines) + "\n")

print(f"Wrote: {out_path}")
print(f"Resolved apps: {sum(1 for _, p in rows if p)} / {len(rows)}")

if open_apps:
    print("")
    print("Opening resolved apps to trigger prompts...")
    for bid, app in rows:
        if not app:
            continue
        print(f"OPEN {bid} -> {app}")
        subprocess.run(["open", app], check=False)
        time.sleep(1.0)

PY

echo
echo "Top candidates:"
sed -n '1,40p' "$OUT_FILE"
echo
echo "Next:"
echo "  - Review $OUT_FILE"
echo "  - If not opened yet, run: $0 --open \"$BASELINE_DIR\""
echo "  - Then go to System Settings -> Privacy & Security and approve pending prompts"
