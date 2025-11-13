{ lib, ... }:
let
  generated = ./hardware/generated.nix;
  example = ./hardware/generated.example.nix;
  hardwareModule = if builtins.pathExists generated then generated else example;
 in
 {
   imports = [ hardwareModule ];

   warnings = lib.optional (!builtins.pathExists generated)
     "hosts/nixos-vm-m4/hardware/generated.nix missing — run nixos-generate-config in the VM to create it.";
 }
