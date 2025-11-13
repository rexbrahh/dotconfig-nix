{ lib, pkgs, ... }:
{
  imports = [
    ../../common/default.nix
  ];

  nixpkgs.config.allowUnfree = lib.mkDefault true;

  nix.settings = {
    experimental-features = lib.mkDefault [ "nix-command" "flakes" ];
    auto-optimise-store = lib.mkDefault true;
  };

  services.openssh.enable = lib.mkDefault true;
  programs.fish.enable = lib.mkDefault true;
  programs.zsh.enable = lib.mkDefault true;

  environment.shells = lib.mkDefault [ pkgs.fish pkgs.zsh pkgs.bashInteractive ];
}
