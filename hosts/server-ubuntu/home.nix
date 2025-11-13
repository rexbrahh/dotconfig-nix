{ lib, ... }:
let
  defaults = {
    username = "server";
    homeDirectory = "/home/server";
    enableRemoteMl = false;
  };
  localFile = ./local.nix;
  overrides = if builtins.pathExists localFile then import localFile else { };
  cfg = defaults // overrides;
 in
 {
   imports = [
     ../../home/users/rex/workstation.nix
   ];

   home.username = cfg.username;
   home.homeDirectory = cfg.homeDirectory;

   ml.remote.enable = lib.mkDefault cfg.enableRemoteMl;
 }
