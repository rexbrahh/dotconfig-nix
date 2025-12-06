# macOS restore automation (nix-darwin + Home Manager)

What can be automated reliably:
- Declarative installs: Homebrew brews/casks, MAS apps (`homebrew.masApps`; requires one-time MAS sign-in).
- CLI/dev env and dotfiles via Home Manager (`home.file`/`xdg.configFile`), including shells, toolchains, fonts, Quick Look plugins available as casks.
- Autostart/background apps via `launchd.user.agents` (nix-darwin) or Home Manager services when the app exposes a binary.
- System defaults exposed by nix-darwin (`system.defaults.*` for Dock/Finder/trackpad/etc.).

What is only partially automatable:
- Non-cask DMG/PKG apps: best handled by creating/using casks or a small activation script; requires upkeep.
- App settings: portable when stored as plain plist/JSON under `~/Library/Preferences` or `~/Library/Application Support`; manage with Home Manager. Encrypted or machine-bound prefs may not survive copying.
- Menubar presence: works if the app auto-starts and shows its icon by default; exact menubar ordering is not declarative.

What stays manual without MDM/root hacks:
- TCC permissions (Accessibility, Screen Recording, Full Disk Access, camera/mic), network extension approvals, login-item approvals. These are per-machine and signature-bound; SIP blocks reliable pre-seeding.
- Menubar layout and Control Center toggles (Dock is declarative; menubar order is not).

Practical rollout plan:
1) Inventory: `brew list --versions`, `brew list --cask --versions`, `mas list`; list DMG/PKG apps with URLs; mark which apps must auto-launch/menubar.
2) Declarative installs: add MAS apps to `homebrew.masApps`; add missing casks or a small activation script for DMG/PKG installs.
3) Autostart: create launchd user agents for menu-bar/background apps that do not self-start but should.
4) Config sync: manage portable prefs via Home Manager where the files are plain text/plist.
5) Accept manual steps: after a fresh machine, run a short checklist to grant TCC permissions and approve network/login items once.
