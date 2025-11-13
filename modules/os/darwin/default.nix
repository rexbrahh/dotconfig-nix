{ ... }:
{
  # Darwin-specific modules extend the common base with UI/Homebrew tweaks.
  imports = [
    ../../common/default.nix
    ../../ui.nix
    ../../homebrew.nix
  ];
}
