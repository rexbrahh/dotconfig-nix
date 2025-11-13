# Framework (NixOS) Host

This directory holds the NixOS-specific bits for running the Framework laptop off the shared flake.

- Generate a fresh `hardware-configuration.nix` on the machine via `nixos-generate-config --show-hardware-config > hosts/framework/hardware/generated.nix`. The flake imports `hardware/generated.nix` when it exists and falls back to the checked-in example otherwise (with a warning).
- Adjust `configuration.nix` for host-only services (GPU drivers, power tweaks, etc.).
- Keep per-user overrides in `home.nix`; it imports the shared `home/users/rex/workstation.nix` module so you only need to add Linux-specific extras here.
