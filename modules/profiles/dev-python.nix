{ pkgs, ... }:
{
  # Python developer tooling. Use project devshells for per-project deps.
  home.packages = with pkgs; [
    python312
    uv
    ruff
    pyright
    just
  ];
}
