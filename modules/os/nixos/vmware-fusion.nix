{ lib, pkgs, config, ... }:
{
  # Tuning for VMware Fusion guests on Apple Silicon: prefer native VMware tools.
  boot.loader.systemd-boot.consoleMode = lib.mkDefault "0";

  # Pick VMware guest tools over qemu guest agent.
  services.qemuGuest.enable = lib.mkDefault false;
  services.vmwareGuest.enable = lib.mkDefault true;

  environment.systemPackages = lib.mkIf config.services.vmwareGuest.enable [
    pkgs.open-vm-tools
  ];
}
