{ lib, ... }:
{
  imports = [
    ../../home/users/rex/workstation.nix
  ];

  home.username = "rex";
  home.homeDirectory = "/home/rex";

  # Disable GUI-specific bits if needed
  ml.remote.enable = lib.mkDefault false;
}
