{lib, ...} @ args:
(import ../../home/users/rex/workstation.nix args)
// {
  home.username = lib.mkDefault "rexliu";
  home.homeDirectory = lib.mkDefault "/home/rexliu";
}
