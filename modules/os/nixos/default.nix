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
  services.openssh.settings = {
    PasswordAuthentication = lib.mkDefault false;
    PermitRootLogin = lib.mkDefault "no";
  };
  programs.fish.enable = lib.mkDefault true;
  programs.zsh.enable = lib.mkDefault true;

  environment.shells = lib.mkDefault [ pkgs.fish pkgs.zsh pkgs.bashInteractive ];

  # Mutate users via Nix, not imperatively, and require sudo passwords by default.
  users.mutableUsers = lib.mkDefault false;
  security.sudo.wheelNeedsPassword = lib.mkDefault true;

  # Keep a firewall on by default; allow SSH explicitly.
  networking.firewall = {
    enable = lib.mkDefault true;
    allowedTCPPorts = lib.mkDefault [ 22 ];
  };
}
