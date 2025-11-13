{ lib, ... }:
{
  imports = [
    ../../home/users/rex/workstation.nix
  ];

  home.username = "rxl";
  home.homeDirectory = "/home/rxl";

  # Disable GUI-specific bits if needed
  ml.remote.enable = lib.mkDefault false;
}
