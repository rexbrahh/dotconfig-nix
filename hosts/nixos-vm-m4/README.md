# nixos-vm-m4

Apple Silicon (aarch64) VM target. See `docs/nixos-vm-m4.md` for the full bootstrap walkthrough using the minimal NixOS ISO.

Key defaults:
- user `rxl` (initial password `changeme`, part of `wheel` and `networkmanager`)
- qemu guest agent enabled
- `nix develop` tooling via shared modules
- hardware file expected at `hosts/nixos-vm-m4/hardware/generated.nix`
