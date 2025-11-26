{pkgs, ...}: {
  # Zig toolchain and language server
  home.packages = with pkgs; [
    zig
    zls
    pkg-config
  ];
}
