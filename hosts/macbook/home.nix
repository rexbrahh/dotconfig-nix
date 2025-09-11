{ config, pkgs, lib, ... }:

{
  # Home Manager release compatibility (don’t change lightly)
  home.stateVersion = "25.05";

  # Choose your login shell (per-user)
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -gx EDITOR nvim
      set -gx VISUAL nvim
      set -gx PAGER less
    '';
    shellAbbrs = {
      gs = "git status -sb";
      gl = "git pull --ff-only";
      gp = "git push";
      nrs = "darwin-rebuild switch --flake ~/.config/nix";
      hm  = "home-manager";
    };
  };
  # Or Zsh (toggle as you like)
  programs.zsh = {
    enable = false;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      export EDITOR=nvim
    '';
  };

  # Prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      scan_timeout = 50;
      format = "$all";
      aws.disabled = true;
      gcloud.disabled = true;
    };
  };

  # Direnv + nix-direnv (transparent nix shell activation)
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Fuzzy & navigation
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
  programs.bat.enable = true;
  programs.eza = { enable = true; git = true; icons = true; };

  # Git setup
  programs.git = {
    enable = true;
    userName  = "Your Name";
    userEmail = "you@example.com";
    delta.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      pull.ff = "only";
      push.autoSetupRemote = true;
    };
  };

  # GPG & SSH (optional scaffolding)
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 7200;
    enableSshSupport = true;
  };
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
        AddKeysToAgent yes
        UseKeychain yes
    '';
  };

  # Editor: Neovim with LSP helpers
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    withNodeJs = true;
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      nvim-lspconfig
      telescope-nvim
      nvim-treesitter
      which-key-nvim
      lualine-nvim
    ];
  };

  # Runtime/toolchains with "mise" (or swap for asdf)
  programs.mise = {
    enable = true;
    settings = {
      experimental = true;
    };
    # Pin versions here if you like, or use per-project .tool-versions
    # tools = { node = "lts"; python = "3.12"; rust = "stable"; };
  };

  # User packages (keep system ones minimal; install most here)
  home.packages = with pkgs; [
    # core
    git gh jq ripgrep fd sd curl wget htop btop tree rsync gnupg
    # dev
    uv # fast Python packager
    nodejs_20
    python312
    rustup
    go
    # nix helpers
    nixpkgs-fmt
    nixd # nix LSP
    nil  # alternative Nix LSP
    alejandra
    # quality-of-life
    neofetch
  ];

  # Dotfiles you want generated/managed
  xdg.enable = true;

  # Set macOS login shell to fish (optional; requires fish in /etc/shells via nix-darwin)
  programs.fish.loginShell = true;

  # HM-managed services you may want later (gui-daemons etc) can be added here
}

