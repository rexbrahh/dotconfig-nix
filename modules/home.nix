{
  config,
  pkgs,
  lib,
  ...
}: let
  anthropicKeyPath = "${config.home.homeDirectory}/.config/secrets/anthropic_api_key";
  zshrcPath = ../dotfiles/zsh/.zshrc;
  fishConfigPath = ../dotfiles/fish/config.fish;
  nushellConfigPath = ../dotfiles/nushell/config.nu;
  nushellEnvPath = ../dotfiles/nushell/env.nu;
in {
  # Home Manager release compatibility (don’t change lightly)
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  # Choose your login shell (per-user)
  programs.fish = {
    enable = false;
    interactiveShellInit = builtins.readFile fishConfigPath;
    shellAbbrs = {
      gs = "git status -sb";
      gl = "git pull --ff-only";
      gp = "git push";
      nrs = "darwin-rebuild switch --flake ~/.config/nix";
      hm = "home-manager";
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

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      ${builtins.readFile zshrcPath}
      if command -v comma >/dev/null; then
        alias ,="comma"
      fi
    '';
  };

  home.file.".zprofile".text = ''
    # OrbStack CLI hooks
    if [ -r "$HOME/.orbstack/shell/init.zsh" ]; then
      source "$HOME/.orbstack/shell/init.zsh"
    fi
  '';
  home.file.".p10k.zsh".source = ../dotfiles/zsh/.p10k.zsh;

  programs.nushell = {
    enable = true;
    package = pkgs.nushell;
    envFile.source = nushellEnvPath;
    configFile.source = nushellConfigPath;
    plugins = let
      np = pkgs.nushellPlugins;
    in
      lib.flatten [
        (lib.optional (np ? nu_plugin_query) np.nu_plugin_query)
        (lib.optional (np ? nu_plugin_polars) np.nu_plugin_polars)
        (lib.optional (np ? nu_plugin_formats) np.nu_plugin_formats)
        (lib.optional (np ? nu_plugin_gstat) np.nu_plugin_gstat)
        (lib.optional (np ? nu_plugin_custom_values) np.nu_plugin_custom_values)
      ];
  };

  # Provide stub init files so Nushell's parser can source them even if binaries are absent
  home.file.".cache/starship/init.nu".text = "# starship nushell stub; overwritten at runtime if starship is installed\n";
  home.file.".cache/zoxide/init.nu".text = "# zoxide nushell stub; overwritten at runtime if zoxide is installed\n";

  home.sessionVariables = {
    SHELL = "/run/current-system/sw/bin/zsh";
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
  };

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    escapeTime = 20;
    historyLimit = 2000000000;
    extraConfig = builtins.readFile ../dotfiles/tmux/tmux.conf;
  };

  # Prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      scan_timeout = 50;
      format = "$directory$git_branch$git_status$fill$hostname$time$line_break$character";
      right_format = "$status$jobs$hostname$time$zig$rust$golang$nodejs$python$docker_context$package$nix_shell$custom.nixver";

      aws.disabled = true;
      gcloud.disabled = true;

      fill.symbol = " ";

      directory = {
        style = "fg:#7aa2f7 bold";
        truncation_length = 3;
        truncate_to_repo = true;
        read_only = " ";
        format = "[$path]($style) ";
      };

      git_branch = {
        symbol = " ";
        style = "fg:#7dcfff bold";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "fg:#7dcfff";
        format = "[$all_status$ahead_behind]($style)";
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname](fg:#9aa5ce) ";
      };

      time = {
        disabled = false;
        format = "[$time](fg:#565f89)";
        time_format = "%H:%M";
      };

      character = {
        success_symbol = "[❯](fg:#85befd)";
        error_symbol = "[❯](fg:#f7768e)";
        vicmd_symbol = "[❮](fg:#85befd)";
      };

      package = {
        format = "[$symbol$version]($style) ";
        style = "fg:#9aa5ce";
      };

      nix_shell = {
        format = "[❄️ $name]($style) ";
        style = "fg:#9aa5ce";
      };

      zig = {
        symbol = "🦎 ";
        format = "[$symbol$version]($style) ";
        style = "fg:#7dcfff";
      };

      rust = {
        symbol = "🦀 ";
        format = "[$symbol$version]($style) ";
        style = "fg:#e0af68";
      };

      golang = {
        symbol = "🐹 ";
        format = "[$symbol$version]($style) ";
        style = "fg:#7dcfff";
      };

      nodejs = {
        symbol = "⬢ ";
        format = "[$symbol$version]($style) ";
        style = "fg:#9ece6a";
      };

      python = {
        symbol = "🐍 ";
        format = "[$symbol$version]($style) ";
        style = "fg:#c0caf5";
      };

      ruby = {
        symbol = "💎 ";
        format = "[$symbol$version]($style) ";
        style = "fg:#f7768e";
      };

      docker_context = {
        symbol = "🐳 ";
        format = "[$symbol$context]($style) ";
        style = "fg:#7dcfff";
      };

      custom.nixver = {
        command = "nix --version | head -n1 | awk '{print $3}'";
        detect_files = [ "flake.nix" "shell.nix" ];
        style = "fg:#9aa5ce";
        format = "[❄️ $output]($style) ";
      };

      status = {
        style = "fg:#f7768e";
        format = "[✖ $status]($style) ";
        disabled = false;
        map_symbol = true;
      };

      jobs = {
        symbol = " ";
        style = "fg:#9aa5ce";
        format = "[$symbol$number]($style) ";
        number_threshold = 1;
      };
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
    userName = "Rex Liu";
    userEmail = "hi@r3x.sh";
    delta.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      pull.ff = "only";
      push.autoSetupRemote = true;
      # Global default: GPG/OpenPGP signing
      gpg.format = "openpgp";
      commit.gpgsign = true;
      user.signingKey = "F6E1D95B5DE90338";
      # Keep SSH verification support for per-repo overrides
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
  };

  # GPG & SSH
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 7200;
    enableSshSupport = false;
    pinentry.package =
      if pkgs.stdenv.isDarwin
      then pkgs.pinentry_mac
      else pkgs.pinentry;
  };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
      extraOptions =
        {
          AddKeysToAgent = "ask";
          IdentitiesOnly = "yes";
          ForwardAgent = "no";
          StrictHostKeyChecking = "yes";
          UpdateHostKeys = "yes";
          HashKnownHosts = "yes";
        }
        // lib.optionalAttrs pkgs.stdenv.isDarwin {
          UseKeychain = "yes";
        };
    };
    matchBlocks."gpu-box".extraOptions.ForwardAgent = "yes";
  };

  # Ensure tmux log dir exists for user launchd agent
  home.activation.tmuxLogDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/Library/Logs/tmux"
  '';

  # Import GPG public key + ownertrust (safe: public material only)
  home.activation.importGpgKey = lib.hm.dag.entryAfter ["tmuxLogDir"] ''
    if command -v gpg >/dev/null; then
      gpg --quiet --import ${../dotfiles/gpg/public.asc} || true
      gpg --quiet --import-ownertrust ${../dotfiles/gpg/ownertrust.txt} || true
    fi
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
    settings = {experimental = true;};
  };

  # User-scoped packages managed by Home Manager
  home.packages = with pkgs; [
    git
    gh
    jq
    ripgrep
    fd
    sd
    curl
    wget
    htop
    btop
    tree
    rsync
    gnupg
    uv
    nodejs_20
    python312
    rustup
    go
    nixpkgs-fmt
    nixd
    nil
    alejandra
    nh
    nvd
    nix-tree
    nix-output-monitor
    pre-commit
    neofetch
    carapace
  ];

  # Dotfiles you want generated/managed
  xdg.enable = true;

  # Set macOS login shell to fish (optional)
  # programs.fish.loginShell = true;
}
