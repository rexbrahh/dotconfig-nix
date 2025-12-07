{lib, pkgs, ...}: {
  # VM-friendly defaults; override per-host as needed.
  services.qemuGuest.enable = lib.mkDefault true;

  # Speed boot and make serial console usable in headless runs.
  boot.kernelParams = lib.mkDefault ["console=ttyS0" "panic=1"];
  boot.initrd.availableKernelModules = lib.mkDefault ["virtio_pci" "virtio_blk" "virtio_net"];

  # Keep NetworkManager predictable on virt by using eth0-style names.
  networking.usePredictableInterfaceNames = lib.mkDefault false;

  # Disable over-waiting on network; VM boots fast.
  systemd.network.wait-online.enable = lib.mkDefault false;

  # Ensure basic tooling is present in initrd for debugging if needed.
  environment.systemPackages = lib.mkDefault [pkgs.qemu_guest_agent];
}
