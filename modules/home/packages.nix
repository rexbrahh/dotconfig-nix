{pkgs, ...}: {
  # User-scoped packages managed by Home Manager
  home.packages = with pkgs; [
    git
    gh
    jq
    ripgrep
    fd
    sd
    curl
    wget
    htop
    btop
    tree
    rsync
    gnupg
    uv

    # nodejs_20

    python312
    rustup
    go
    nixpkgs-fmt
    nixd
    nil
    alejandra
    nh
    nvd
    nix-tree
    nix-output-monitor
    pre-commit
    neofetch
    carapace
  ];
}
