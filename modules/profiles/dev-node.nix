{pkgs, ...}: {
  # Node.js + frontend tooling
  home.packages = with pkgs; [
    nodejs_20
    bun
    just
  ];
}
