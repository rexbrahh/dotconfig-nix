{ lib, inputs, config, pkgs, ... }:
let
  secretsModule = ../../secrets/secrets.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/os/nixos/default.nix
  ] ++ lib.optional (builtins.pathExists secretsModule) secretsModule;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "framework";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Los_Angeles";

  users.users.rex = {
    isNormalUser = true;
    description = "Rex Liu";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
  };

  services.openssh.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "rex" ];
    auto-optimise-store = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.rex = import ./home.nix;
  };

  system.stateVersion = "24.11"; # set to the NixOS version originally installed
}
