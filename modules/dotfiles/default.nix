{ lib, ... }:
{
  # Do not import this module automatically. Opt in from your host HM imports
  # after reviewing. These entries copy your existing dotfiles into the flake
  # so Home Manager can recreate them on a fresh machine.

  home.file = {
    # Helix editor
    ".config/helix/config.toml" = {
      source = ../../dotfiles/helix/config.toml;
    };
    ".config/helix/languages.toml" = {
      source = ../../dotfiles/helix/languages.toml;
    };

    # Yazi file manager
    ".config/yazi/yazi.toml" = {
      source = ../../dotfiles/yazi/yazi.toml;
    };
    ".config/yazi/theme.toml" = {
      source = ../../dotfiles/yazi/theme.toml;
    };
    ".config/yazi/package.toml" = {
      source = ../../dotfiles/yazi/package.toml;
    };

    # Yabai + skhd (tiling WM & hotkeys)
    ".config/yabai/yabairc" = {
      source = ../../dotfiles/yabai/yabairc;
      executable = true;
    };
    # Ensure default path is present for service defaults
    ".yabairc" = {
      source = ../../dotfiles/yabai/yabairc;
      executable = true;
    };
    ".config/skhd/skhdrc" = {
      source = ../../dotfiles/skhd/skhdrc;
    };
    # Provide legacy default path for skhd
    ".skhdrc" = {
      source = ../../dotfiles/skhd/skhdrc;
    };
  };
}
