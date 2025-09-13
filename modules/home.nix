{ config, pkgs, lib, ... }:

{
  # Home Manager release compatibility (don’t change lightly)
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  # Choose your login shell (per-user)
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # PATH & basics
      if test -d /opt/homebrew/bin
        fish_add_path -g /opt/homebrew/bin /opt/homebrew/sbin
      end

      # EDITOR (SSH-aware) + VISUAL/PAGER
      if set -q SSH_CONNECTION
        set -gx EDITOR vim
      else
        set -gx EDITOR nvim
      end

      set -gx VISUAL nvim
      fish_add_path -g /run/current-system/sw/bin

      set -gx PAGER less
      umask 077

      # Auto-attach tmux when launching an interactive shell in Ghostty
      # - skip if already inside tmux
      # - skip for SSH sessions
      if status is-interactive \
        and not set -q TMUX \
        and test -t 0 \
        and test "$TERM_PROGRAM" = "Ghostty"
        tmux attach -t main 2>/dev/null; or tmux new -s main
      end
    '';
    shellAbbrs = {
      gs = "git status -sb";
      gl = "git pull --ff-only";
      gp = "git push";
      nrs = "darwin-rebuild switch --flake ~/.config/nix";
      hm  = "home-manager";
      nhs = "nh os switch -- --flake ~/.config/nix";
      nhb = "nh os boot -- --flake ~/.config/nix";
      nhc = "nh clean all";
      # Vagrant QoL
      vgu = "vagrant up";
      vgh = "vagrant halt";
      vgd = "vagrant destroy -f";
      vgr = "vagrant reload --provision";
      vgs = "vagrant ssh";
      vgp = "vagrant plugin list";
      # Packer
      pkb = "packer build";
      # Nix helpers
      nhd = "nh os diff";
      # K8s minimal helpers
      k = "kubectl";
      kctx = "kubectx";
      kns = "kubens";
      kl = "kubectl logs -f";
      ka = "kubectl apply -f";
    };
    functions = {
      extract = {
        description = "Extract many archive types by extension";
        body = ''
          for file in $argv
            switch $file
              case '*.tar.bz2'
                tar xjf $file
              case '*.tar.gz'
                tar xzf $file
              case '*.bz2'
                bunzip2 $file
              case '*.rar'
                unrar x $file
              case '*.gz'
                gunzip $file
              case '*.tar'
                tar xf $file
              case '*.tbz2'
                tar xjf $file
              case '*.tgz'
                tar xzf $file
              case '*.zip'
                unzip $file
              case '*.7z'
                7z x $file
              case '*'
                echo "cannot extract $file"
            end
          end
        '';
      };
      y = {
        description = "Run yazi and cd into the chosen directory";
        body = ''
          set tmp (mktemp -t yazi-cwd.XXXXXX)
          yazi $argv --cwd-file="$tmp"
          if test -s "$tmp"
            set cwd (cat "$tmp")
            if test -d "$cwd"
              cd "$cwd"
            end
          end
          rm -f "$tmp"
        '';
      };
    };
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

  # Git setup
  programs.git = {
    enable = true;
    userName  = "Rex Liu";
    userEmail = "hi@r3x.sh";
    delta.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      pull.ff = "only";
      push.autoSetupRemote = true;
      gpg.format = "ssh";
      commit.gpgsign = true;
      user.signingKey = "~/.ssh/id_ed25519.pub";
    };
  };

  # GPG & SSH
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 7200;
    enableSshSupport = false;
  };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
      extraOptions = {
        AddKeysToAgent = "ask";
        IdentitiesOnly = "yes";
        UseKeychain = "yes";
        ForwardAgent = "no";
        StrictHostKeyChecking = "yes";
        UpdateHostKeys = "yes";
        HashKnownHosts = "yes";
      };
    };
    matchBlocks."gpu-box".extraOptions.ForwardAgent = "yes";
  };

  # Ensure tmux log dir exists for user launchd agent
  home.activation.tmuxLogDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/Library/Logs/tmux"
  '';

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

  # Runtime/toolchains with "mise"
  programs.mise = {
    enable = true;
    settings = { experimental = true; };
  };

  # User-scoped packages managed by Home Manager
  home.packages = with pkgs; [
    git gh jq ripgrep fd sd curl wget htop btop tree rsync gnupg
    uv nodejs_20 python312 rustup go
    nixpkgs-fmt nixd nil alejandra nh nvd nix-tree nix-output-monitor
    pre-commit
    neofetch
  ];

  # Dotfiles you want generated/managed
  xdg.enable = true;

  # Set macOS login shell to fish (optional)
  # programs.fish.loginShell = true;
}
