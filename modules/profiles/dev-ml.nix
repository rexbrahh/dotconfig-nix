{ pkgs, ... }:
{
  # Minimal, global CLI/data tooling for ML workflows (no heavy frameworks).
  # Import this file under home-manager.users.<name>.imports to enable.
  home.packages = with pkgs; [
    # Exploration & notebooks (lean)
    jupyterlab

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

    # Storage / sync
    awscli2
    rclone

    # Secrets
    _1password-cli

    # Solana tooling
    solana-cli
  ];
}

