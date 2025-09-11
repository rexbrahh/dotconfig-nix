# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix` — entrypoint; inputs, overlays, linux‑builder, and app `.#switch`.
- `hosts/<host>/darwin-configuration.nix` — host‑specific nix‑darwin config (imports HM user modules).
- `modules/` — reusable modules: `home.nix`, `homebrew.nix`, `ui.nix`, `packages.nix`, `vagrant.nix`.
  - `modules/profiles/` — opt‑in HM profiles (languages, containers, databases, VMs).
  - `modules/dotfiles/` + `dotfiles/` — optional HM‑managed dotfiles (not auto‑imported).
- `scripts/` — dev helpers (`kind/`, `db/`).
- `overlays/` — local overrides; `pkgs.stable` exposed from 25.05.
- `templates/microservice/` — Kind + Postgres starter.
- `secrets/` — agenix scaffold (ciphertexts only).

## Build, Test, and Development Commands
- Build: `nix build .#darwinConfigurations.macbook.system`.
- Apply: `nix run --accept-flake-config .#switch`.
- Preview: `darwin-rebuild switch --flake .#macbook --dry-run`.
- Validate: `nix flake check`.
- Dev shells: `nix develop` (format/lint), `nix develop .#k8s`, `nix develop .#db`.
- Format: `nix develop -c treefmt -c treefmt.toml --fix`.

## Coding Style & Naming Conventions
- Nix: 2‑space indent, semicolons, <100–120 cols; format with `alejandra`.
- Lint: `statix` (style), `deadnix` (unused). Shell: `shfmt`; Lua: `stylua`; TOML: `taplo`; YAML: `yamlfmt`.
- Naming: `modules/<area>.nix`, `profiles/dev-*.nix`, `scripts/<area>/*.sh`. Keep HM vs Darwin options in the proper layer.

## Testing Guidelines
- Always run `nix flake check` and a `--dry-run` before PRs.
- For system changes, include the dry‑run summary; for modules, show the minimal diff and affected host(s).

## Commit & Pull Request Guidelines
- Commits: imperative mood with optional scope (e.g., `home: add fish abbr`). Keep diffs small and focused.
- PRs: purpose, linked issues, screenshots/logs when helpful, commands used (`flake check`, `--dry-run`).
- If changing packages, state whether from `pkgs` or `pkgs.stable`.

## Security & Configuration Tips
- Secrets live in `secrets/` via agenix (or sops‑nix, see README). Never commit private keys.
- Review dotfiles before enabling `modules/dotfiles/default.nix`. Host‑specific values stay in `hosts/<host>/`.
