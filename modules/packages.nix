{ pkgs, ... }:
{
  # System-scoped packages installed at the macOS level.
  # Keep this list lean; prefer user tooling in Home Manager via `home.packages`.
  environment.systemPackages = with pkgs; [
    git
    zsh
    wget
    curl
    jq
    direnv
    tree
    tmux
    zoxide
    fd
    bat
    neovim
    devenv
    gnupg
    vim
  ];
}

