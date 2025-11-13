# Linux + Home Manager Playbook

This repo now exposes both full NixOS hosts and standalone Home Manager profiles so you can bootstrap any Linux installation.

## NixOS VM (`.#nixos-vm-m4`)
1. Install NixOS inside your Apple Silicon VM.
2. Clone this repo to `~/.config/nix` and run `sudo nixos-generate-config --show-hardware-config > hosts/nixos-vm-m4/hardware/generated.nix`.
3. Review `hosts/nixos-vm-m4/configuration.nix` for VM-specific services (see `docs/nixos-vm-m4.md` for a full disk/ISO walkthrough).
4. Activate with `sudo nixos-rebuild switch --flake ~/.config/nix#nixos-vm-m4` or `scripts/nixos-switch.sh`.

## htznrpsnl (Ubuntu server, Home Manager)
1. Install the [Nix installer](https://nixos.org/download.html#nix-install-linux) on the Hetzner box.
2. Run `nix run nixpkgs#home-manager -- switch --flake ~/.config/nix#rxl@htznrpsnl` (or `./scripts/home-switch.sh`).
3. `hosts/htznrpsnl/home.nix` holds any server-specific overrides (e.g., disable desktop tooling, change username/path).

### Tips
- Use `nix develop .#default --system x86_64-linux` to test Linux devShell changes from macOS.
- Keep secrets in Agenix; add each Linux host's SSH public key to `secrets/secrets.nix` so it can decrypt.
- `nix flake check --all-systems` evaluates the Linux hosts without requiring a builder.
