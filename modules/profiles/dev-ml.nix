{ pkgs, ... }:
{
  # Minimal, global CLI/data tooling for ML workflows (no heavy frameworks).
  # Import this file under home-manager.users.<name>.imports to enable.
  home.packages = with pkgs; [
    # Exploration & notebooks (lean)
    (pkgs.python312Packages.jupyterlab or pkgs.python3Packages.jupyterlab)

    # Data wrangling & formats
    duckdb
    parquet-tools
    qsv
    miller

    # CLIs & QoL
    jq
    ripgrep
    fd
    hyperfine
    pv
    procs
    tmux

    # Storage / sync (prefer stable build to avoid long source builds)
    pkgs.stable.awscli2
    rclone

    # Secrets
    _1password-cli

    # Solana tooling (install via Homebrew to avoid large Nix build)
    # solana-cli
  ];
}
