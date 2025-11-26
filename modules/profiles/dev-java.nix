{pkgs, ...}: {
  # Java toolchain(s) and build tools
  home.packages = with pkgs; [
    jdk21
    maven
    gradle
  ];
}
