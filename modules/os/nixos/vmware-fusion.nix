{ lib, ... }:
{
  # Tuning for VMware Fusion guests on Apple Silicon: prefer native VMware tools.
  boot.loader.systemd-boot.consoleMode = lib.mkDefault "0";

  # Pick VMware guest tools over qemu guest agent.
  services.qemuGuest.enable = lib.mkDefault false;
  virtualisation.vmware.guest.enable = lib.mkDefault true;
}
