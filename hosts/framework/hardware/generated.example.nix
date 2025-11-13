{ ... }:
{
  # Example file; run `nixos-generate-config --show-hardware-config > hosts/framework/hardware/generated.nix`
  # on the Framework laptop and commit the result to replace these defaults.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-4000-8000-000000000000";
    fsType = "ext4";
  };

  swapDevices = [ ];
}
