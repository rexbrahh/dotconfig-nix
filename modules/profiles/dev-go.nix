{ pkgs, ... }:
{
  # Go toolchain and helpers
  home.packages = with pkgs; [
    go
    gopls
    delve
    golangci-lint
    gotools
    just
  ];
}

