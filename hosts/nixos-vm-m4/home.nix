{ lib, ... }@args:
  (import ../../home/users/rex/workstation.nix args) // {
    home.username = lib.mkDefault "rxl";
    home.homeDirectory = lib.mkDefault "/home/rxl";
  }
