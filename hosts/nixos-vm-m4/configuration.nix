{ lib, inputs, config, pkgs, ... }:
let
  secretsModule = ../../secrets/secrets.nix;
 in
 {
   imports = [
     ./hardware-configuration.nix
     ../../modules/os/nixos/default.nix
     ../../modules/os/nixos/vmware-fusion.nix
     ../../modules/os/nixos/desktop.nix
     ../../modules/os/nixos/docker.nix
   ] ++ lib.optional (builtins.pathExists secretsModule) secretsModule;

   nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

   boot.loader.systemd-boot.enable = true;
   boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-vm-m4";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Los_Angeles";
  console.keyMap = "us";

  users.users.rexliu = {
    isNormalUser = true;
    description = "Rex Liu";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.fish;
    home = "/home/rexliu";
    initialPassword = "changeme";
  };

  services.openssh.enable = true;
  services.qemuGuest.enable = false;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "rexliu" ];
    auto-optimise-store = true;
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.rexliu = import ./home.nix;
  };

  system.stateVersion = "24.11";
}
