# macOS Settings Audit Scripts

These helpers export your current macOS preferences and generate a nix-darwin
`system.defaults` snippet from them. They avoid guessing — you review and pick
only the keys you care about.

## 1) Collect current settings

Run the inventory and note the output directory:

```
scripts/audit/macos-inventory.sh /tmp/macos-inventory
```

Outputs JSON files per domain (Dock, Finder, NSGlobalDomain, etc.), plus lists
of apps, Homebrew packages, MAS apps, and more.

## 2) Generate a nix-darwin snippet (optional)

Produce a starter `system.defaults` snippet from the JSON:

```
scripts/audit/generate-nix-defaults.sh /tmp/macos-inventory > /tmp/ui-defaults.nix
```

Review `/tmp/ui-defaults.nix`, copy desired parts into `modules/ui.nix`, and
test with:

```
darwin-rebuild switch --flake . --dry-run
```

Notes
- The generator covers common keys; unsupported or app-specific preferences
  should be managed via Home Manager dotfiles or activation scripts.
- Sensitive items (Apple ID, Touch ID, TCC permissions) remain manual.

