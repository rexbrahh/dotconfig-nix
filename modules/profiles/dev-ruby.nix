{pkgs, ...}: {
  # Ruby toolchain. Use `gem` for bundler if preferred.
  home.packages = with pkgs; [
    ruby
    rubocop
  ];
}
