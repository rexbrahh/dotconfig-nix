# nixos-vm-m4 (NixOS VM)

Apple Silicon VM target that runs the shared configuration. Generate hardware info inside the VM:

```
sudo nixos-generate-config --show-hardware-config > hosts/nixos-vm-m4/hardware/generated.nix
```

The flake automatically imports that file; until you add it, `nix flake check` will emit a warning.
