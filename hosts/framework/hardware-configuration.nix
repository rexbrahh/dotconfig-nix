{ lib, ... }:
{
  imports = [ ];

  # Replace these with the values from `nixos-generate-config` on the host.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-uuid/00000000-0000-4000-8000-000000000000";
    fsType = "ext4";
  };

  swapDevices = [ ];
}
