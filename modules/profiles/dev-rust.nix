{ pkgs, ... }:
{
  # Rust toolchain and common utilities for development.
  home.packages = with pkgs; [
    rustup          # provides rustc/cargo toolchain via `rustup`
    cargo-expand
    cargo-watch
    just
  ];
}
