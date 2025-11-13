{ lib, ... }:
{
  imports = [
    ../../home/users/rex/workstation.nix
  ];

  # Example Linux-specific overrides go here.
  ml.remote.enable = lib.mkDefault false;
}
