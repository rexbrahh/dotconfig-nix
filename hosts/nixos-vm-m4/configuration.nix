{ lib, inputs, config, pkgs, ... }:
let
  secretsModule = ../../secrets/secrets.nix;
 in
 {
   imports = [
     ./hardware-configuration.nix
     ../../modules/os/nixos/default.nix
   ] ++ lib.optional (builtins.pathExists secretsModule) secretsModule;

   nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

   boot.loader.systemd-boot.enable = true;
   boot.loader.efi.canTouchEfiVariables = true;

   networking.hostName = "nixos-vm-m4";
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

   system.stateVersion = "24.11";
 }
