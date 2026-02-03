{...}: {
  imports = [
    ./core.nix
    ./shells.nix
    ./tools.nix
    ./git.nix
    ./security.nix
    ./neovim.nix
    ./packages.nix
    ./sops.nix
  ];
}
