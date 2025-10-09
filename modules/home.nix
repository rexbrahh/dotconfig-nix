{ config, pkgs, lib, ... }:

let
  anthropicKeyPath = "${config.home.homeDirectory}/.config/secrets/anthropic_api_key";
in
{
  # Home Manager release compatibility (don’t change lightly)
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  # Choose your login shell (per-user)
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # PATH & basics
      set -Ux fish_greeting
      if test -d /opt/homebrew/bin
        fish_add_path -g /opt/homebrew/bin /opt/homebrew/sbin
      end
      fish_add_path $HOME/.local/bin
      fish_add_path $HOME/.local/share/solana/install/active_release/bin
      direnv hook fish | source 
      set -gx EMSDK_QUIET 1
      source "/Users/rexliu/emsdk/emsdk_env.fish"
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
      
      zoxide init fish | source
      #set -gx ANTHROPIC_BASE_URL https://cc.yovy.app
      if test -f "${anthropicKeyPath}"
        set -gx ANTHROPIC_API_KEY (string trim (cat "${anthropicKeyPath}"))
      end
      #set -gx ANTHROPIC_MODEL anthropic/claude-sonnet-4.5
      #set -gx ANTHROPIC_SMALL_FAST_MODEL x-ai/grok-4-fast:free

      # Auto-attach tmux when launching an interactive shell in Ghostty
      # - skip if already inside tmux
      # - skip for SSH sessions
      if status is-interactive
        and test -z "$TMUX"
        and test "$TERM_PROGRAM" = "Ghostty"
        exec tmux -u new-session -A -s main
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
    # pinentry on macOS (option renamed)
    pinentry.package = pkgs.pinentry_mac or pkgs.pinentry;
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

  # Import GPG public key + ownertrust (safe: public material only)
  home.activation.importGpgKey = lib.hm.dag.entryAfter [ "tmuxLogDir" ] ''
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
