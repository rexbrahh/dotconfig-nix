{ ... }:
{
  # Example hardware file. Inside the VM, run:
  #   nixos-generate-config --show-hardware-config > hosts/nixos-vm-m4/hardware/generated.nix
  # then commit the generated file.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-4000-8000-000000000000";
    fsType = "ext4";
  };

  swapDevices = [ ];
}
