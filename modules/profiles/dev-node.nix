{pkgs, ...}: {
  # Node.js + frontend tooling
  home.packages = with pkgs; [
    nodejs_20
    corepack # provides pnpm/yarn via `corepack enable`
    bun
    just
  ];
}
