{...}: {
  # Home Manager release compatibility (don’t change lightly)
  home.stateVersion = "25.05";
  # This flake pins nixpkgs independently of Home Manager, so suppress the
  # release-mismatch warning and rely on `nix flake check` instead.
  home.enableNixpkgsReleaseCheck = false;
  programs.home-manager.enable = true;

  home.sessionVariables = {
    SHELL = "/run/current-system/sw/bin/zsh";
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
  };

  # Dotfiles you want generated/managed
  xdg.enable = true;
}
