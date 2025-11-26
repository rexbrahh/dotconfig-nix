{pkgs, ...}: {
  # C/C++ toolchain (Clang) and common build utilities.
  home.packages = with pkgs; [
    clang
    clang-tools # clangd, clang-tidy, clang-format, etc.
    lld
    lldb
    cmake
    ninja
    pkg-config
    bear # generate compile_commands.json
    gnumake
  ];
}
