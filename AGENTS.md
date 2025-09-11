# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix` / `flake.lock` — entrypoint; defines inputs and the `macbook` darwin configuration and an app `.#switch`.
- `hosts/<host>/darwin-configuration.nix` — host-specific settings (users, networking, packages).
- `modules/` — reusable Nix modules split by concern: `home.nix`, `homebrew.nix`, `ui.nix`, `packages.nix` (imported by hosts).
  - `modules/profiles/` — optional Home Manager language profiles: `dev-containers.nix`, `dev-databases.nix`, `dev-cpp.nix`, `dev-zig.nix`, `dev-rust.nix`, `dev-go.nix`, `dev-node.nix`, `dev-python.nix`, `dev-java.nix`, `dev-kotlin.nix`, `dev-php.nix`, `dev-ruby.nix`, `dev-elixir.nix`.
- `home/` and `darwin/` — reserved for user/darwin submodules; keep host-agnostic code in `modules/`.

## Build, Test, and Development Commands
- `nix build .#darwinConfigurations.macbook.system` — build the macOS system derivation for `macbook`.
- `nix run .#switch` — apply the current config (wrapper for `darwin-rebuild switch --flake .`).
- `darwin-rebuild switch --flake .` — switch to the latest build immediately.
- `darwin-rebuild build --flake .` — build only (no activation).
- `darwin-rebuild switch --flake . --dry-run` — preview changes.
- `nix flake check` — validate flake and evaluate modules.
- `nix develop` — enter repo dev shell (treefmt, statix, deadnix, shfmt, stylua, taplo, yamlfmt, jq, pre-commit).
- `pre-commit install` then `pre-commit run -a` — enforce formatting & nix linting.

## Coding Style & Naming Conventions
- Nix files: 2-space indent, trailing semicolons, 100-char soft wrap, attributes in stable order where practical.
- Keep modules small and focused; prefer `modules/<area>.nix` (e.g., `ui.nix`, `homebrew.nix`).
- Host-specific values live only under `hosts/<host>/`.
- Prefer explicit imports via `modules/default.nix` for composition.
- Run `nix fmt` (or `nixpkgs-fmt`) before committing.

## Testing Guidelines
- Use `darwin-rebuild ... --dry-run` before switching; include output when proposing changes.
- Run `nix flake check` locally; ensure evaluation succeeds across all hosts.
- Naming: test changes with a temporary branch; avoid committing experimental toggles without guards/comments.
- Formatting: `nix develop` then `treefmt -c treefmt.toml --fix` before PR.

## Commit & Pull Request Guidelines
- Commit messages: imperative mood, concise summary; scope prefix optional (e.g., `homebrew: add lazygit`).
- Group related edits per commit (module/host); avoid large mixed commits.
- PRs should include: purpose, key diffs, `--dry-run` output (when relevant), and any migration notes.

## Security & Configuration Tips
- Do not commit secrets or machine-specific tokens; externalize via environment or a secrets manager.
- If adding new hosts, mirror the pattern in `hosts/macbook/` and keep credentials out of the repo.
