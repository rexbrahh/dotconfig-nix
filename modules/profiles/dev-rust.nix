{ pkgs, ... }:
{
  # Rust toolchain and common utilities for development.
  home.packages = with pkgs; [
    rustup
    cargo
    cargo-expand
    cargo-watch
    just
  ];
}

