# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix` / `flake.lock` — flake entry; defines inputs, `darwinConfigurations.macbook`, and app `.#switch`.
- `hosts/<host>/darwin-configuration.nix` — host-specific settings and Home Manager imports.
- `modules/` — reusable modules: `home.nix`, `homebrew.nix`, `ui.nix`, `packages.nix`, `vagrant.nix`.
  - `modules/profiles/` — opt-in language/tooling profiles (e.g., `dev-python.nix`, `dev-go.nix`, `dev-rust.nix`, `dev-ml.nix`).
  - ML helpers: `ml-env.nix`, `ml-remote.nix`, `ml-tunnels.nix`, `onepassword.nix`.
- `templates/` — starter templates (e.g., microservice devshells).

## Build, Test, and Development Commands
- `darwin-rebuild switch --flake . --dry-run` — preview changes.
- `nix build .#darwinConfigurations.macbook.system` — build system (no activation).
- `nix run .#switch` — apply current config (accepts flake config).
- `nix flake check` — evaluate flake and basic checks.
- `nix develop` — enter dev shell; then `pre-commit install` and `pre-commit run -a`.

## Coding Style & Naming Conventions
- Nix: 2-space indent, trailing semicolons, ~100-char soft wrap. Keep attributes stable where practical.
- Keep modules small and focused; host-specific values live only under `hosts/<host>/`.
- Prefer explicit composition via `modules/default.nix`. Run `nix fmt` (or `nixpkgs-fmt`) before commits.

## Testing Guidelines
- Always dry-run before switching; include the output when proposing changes.
- Run `nix flake check` locally; ensure all hosts evaluate.
- Format before PR: `nix develop` then `treefmt -c treefmt.toml --fix`.

## Commit & Pull Request Guidelines
- Commits: imperative, concise (e.g., `homebrew: add lazygit`). Group related edits by module/host.
- PRs include: purpose, key diffs, `--dry-run` output (when relevant), and migration notes.

## Security & Configuration Tips
- Secrets: never commit tokens/keys. Use 1Password CLI (`op`) or `sops-nix`; inject at runtime.
- SSH: verify host keys; limit agent forwarding. For tunnels, set `ml.tunnels.destination` to a trusted alias.
- Local tunnels/services are opt-in; disable when unused. Keep FileVault, firewall, and auto-updates enabled.

## Agent-Specific Notes
- Don’t enable modules globally in PRs; provide toggles with safe defaults and document host-side enablement.
- Avoid adding heavy runtime deps globally; prefer profiles and per-host imports.

