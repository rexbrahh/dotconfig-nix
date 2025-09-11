{ ... }:
{
  # Darwin-level aggregator. Import Home Manager modules separately under
  # `home-manager.users.<name>.imports` to avoid option namespace conflicts.
  imports = [
    ./ui.nix
    ./homebrew.nix
    ./packages.nix
  ];
}
