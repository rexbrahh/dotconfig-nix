{...}: {
  # Direnv + nix-direnv (transparent nix shell activation)
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      strict_env = true;
      hide_env_diff = true;
      warn_timeout = "1m";
    };
  };

  # Fuzzy & navigation
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
  programs.bat.enable = true;
  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };

  # Runtime/toolchains with "mise"
  programs.mise = {
    enable = true;
    settings = {experimental = true;};
  };
}
