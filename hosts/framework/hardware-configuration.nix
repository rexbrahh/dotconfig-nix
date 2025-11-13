{ lib, ... }:
let
  generated = ./hardware/generated.nix;
  example = ./hardware/generated.example.nix;
  hardwareModule = if builtins.pathExists generated then generated else example;
in
{
  imports = [ hardwareModule ];

  warnings = lib.optional (!builtins.pathExists generated)
    "hosts/framework/hardware/generated.nix missing — run `nixos-generate-config --show-hardware-config > hosts/framework/hardware/generated.nix` on the Framework laptop.";
}
