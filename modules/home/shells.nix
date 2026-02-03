{
  lib,
  pkgs,
  ...
}: let
  fishConfigPath = ../../dotfiles/fish/config.fish;
  nushellConfigPath = ../../dotfiles/nushell/config.nu;
  nushellEnvPath = ../../dotfiles/nushell/env.nu;
  starshipConfigPath = ../../dotfiles/starship/starship.toml;
in {
  # ==========================================================================
  # ZSH - Fast, plugin-managed via Nix (no Oh-My-Zsh)
  # ==========================================================================
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # History security & performance settings
    history = {
      size = 50000;
      save = 50000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
      extended = true;
    };

    # Session variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      MANPAGER = "nvim +Man!";
      BAT_THEME = "tokyonight-nosyntax";
      TERM = "xterm-256color";
      DIRENV_LOG_FORMAT = "";
      NIX_SHELL_PRESERVE_PROMPT = "1";
      EMSDK_QUIET = "1";
    };

    # Plugins managed by Nix (replaces ~/zsh-den git clones)
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      {
        name = "zsh-autopair";
        src = pkgs.zsh-autopair;
        file = "share/zsh/zsh-autopair/autopair.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
        file = "share/zsh-completions/zsh-completions.plugin.zsh";
      }
      {
        name = "forgit";
        src = pkgs.zsh-forgit;
        file = "share/zsh/zsh-forgit/forgit.plugin.zsh";
      }
      {
        name = "zsh-abbr";
        src = pkgs.zsh-abbr;
        file = "share/zsh/zsh-abbr/zsh-abbr.plugin.zsh";
      }
      {
        name = "nix-zsh-completions";
        src = pkgs.nix-zsh-completions;
        file = "share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh";
      }
      {
        name = "history-substring-search";
        src = pkgs.zsh-history-substring-search;
        file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
    ];

    # Shell aliases
    shellAliases = {
      ".." = "z ..";
      nv = "nvim";
      c = "clear -x";
      reload = "exec zsh";

      # eza aliases
      l = "eza -lha --no-time --no-permissions --no-user -I .DS_Store";
      ld = "eza -lha --no-filesize --no-permissions --no-user -I .DS_Store";
      ls = "eza -liha";
      lt = "eza -lihaT --git-ignore";

      # Nix
      nrs = "darwin-rebuild switch --flake ~/.config/nix";

      # Git
      gs = "git status -sb";
      gl = "git pull --ff-only";
      gp = "git push";
    };

    # Combined init content (mkBefore runs early, mkAfter runs late)
    initContent = lib.mkMerge [
      # Early init (before plugins)
      (lib.mkBefore ''
        # Security: restrictive umask
        umask 077

        # Performance: cache compinit (only rebuild once per day)
        autoload -Uz compinit
        if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then
          compinit
        else
          compinit -C
        fi
      '')

      # Main init content
      ''
      # PATH additions
      export PATH="/run/current-system/sw/bin:$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
      export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
      export PATH="$HOME/.cargo/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"

      # Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      export NIX_PATH=$HOME/.nix-defexpr/channels''${NIX_PATH:+:$NIX_PATH}

      # EMSDK
      if [ -f "$HOME/emsdk/emsdk_env.sh" ]; then
        . "$HOME/emsdk/emsdk_env.sh" >/dev/null
      fi

      # Secrets (loaded from sops-managed file if available)
      if [ -f "$HOME/.config/secrets/anthropic_api_key" ]; then
        export ANTHROPIC_API_KEY="$(cat "$HOME/.config/secrets/anthropic_api_key" | tr -d '\n')"
      fi

      # Keybindings (emacs mode)
      bindkey -e
      bindkey '^O' edit-command-line
      bindkey '^K' kill-line
      bindkey '^U' backward-kill-line
      bindkey '^D' delete-char
      bindkey '^F' forward-char
      bindkey '^B' backward-char
      bindkey '^P' history-substring-search-up
      bindkey '^N' history-substring-search-down
      bindkey '^E' end-of-line
      bindkey '^A' beginning-of-line
      bindkey '^[OA' history-substring-search-up   # up arrow
      bindkey '^[OB' history-substring-search-down # down arrow

      # Edit command line in $EDITOR
      autoload -U edit-command-line
      zle -N edit-command-line

      # Shell options
      setopt glob_dots
      setopt no_auto_menu
      setopt no_list_beep
      setopt ignoreeof
      setopt auto_cd
      setopt auto_pushd pushd_silent pushd_ignore_dups

      # Completion styling
      zstyle ':completion:*' menu select
      zstyle ':completion:*' insert-tab false
      zstyle ':completion:*:default' list-colors ""
      zstyle ':completion:*:*:*:*:*' file-sort modification
      zstyle ':completion:*:complete:*:files' use-cache on
      zstyle ':completion:*:complete:*:paths' use-cache on

      # Autosuggestions config
      ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(end-of-line)
      ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(forward-char forward-word emacs-forward-char emacs-forward-word)

      # Yazi file manager wrapper
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d "" cwd < "$tmp"
        [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
        rm -f -- "$tmp"
      }

      # Directory picker with fzf
      function f() {
        local selected_dir
        selected_dir=$(fd --type d --hidden --exclude .git --exclude node_modules --exclude .cache | \
          fzf --prompt="choose directory > " --reverse --info="right" --padding=1,0,0,1)
        if [ -n "$selected_dir" ]; then
          cd "$selected_dir" || return
        fi
      }

      # Project picker
      function zd() {
        local current_dir dir
        current_dir=$(pwd)
        cd "$HOME/vault" 2>/dev/null || return 1
        dir=$(fd -t d --exact-depth 2 | fzf --prompt="projects > " --reverse --info="right" --padding=1,0,0,1)
        if [[ -n $dir ]]; then
          cd "$dir"
        else
          cd "$current_dir"
        fi
      }

      # File editor picker
      function ze() {
        local file
        file=$(fd --exclude .git --hidden | fzf --prompt="edit > " --reverse --info="right" --padding=1,0,0,1)
        [[ -n $file ]] && $EDITOR "$file"
      }

      # Auto-attach tmux (Ghostty/Apple Terminal only)
      if [[ -o interactive ]] \
         && [[ -z ''${TMUX+X} ]] \
         && [[ -z ''${SSH_TTY+X} ]] \
         && [[ "$TERM_PROGRAM" = "Ghostty" || "$TERM_PROGRAM" = "Apple_Terminal" ]]; then
        if command -v tmux >/dev/null; then
          tmux new -As main
        fi
      fi

      # Comma wrapper for nix-index
      if command -v comma >/dev/null; then
        alias ,="comma"
      fi
    ''
    ];
  };

  # .zprofile for login shell hooks
  home.file.".zprofile".text = ''
    # OrbStack CLI hooks
    if [ -r "$HOME/.orbstack/shell/init.zsh" ]; then
      source "$HOME/.orbstack/shell/init.zsh"
    fi
  '';

  # ==========================================================================
  # FISH - Already well-configured
  # ==========================================================================
  programs.fish = {
    enable = true;
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
      nhd = "nh os diff";
      # Vagrant
      vgu = "vagrant up";
      vgh = "vagrant halt";
      vgd = "vagrant destroy -f";
      vgr = "vagrant reload --provision";
      vgs = "vagrant ssh";
      vgp = "vagrant plugin list";
      # Packer
      pkb = "packer build";
      # K8s
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

  # ==========================================================================
  # BASH - Minimal but functional configuration
  # ==========================================================================
  programs.bash = {
    enable = true;
    enableCompletion = true;

    historyControl = ["ignoredups" "erasedups" "ignorespace"];
    historySize = 50000;
    historyFileSize = 50000;
    historyIgnore = ["ls" "cd" "exit" "clear"];

    shellOptions = [
      "histappend"
      "checkwinsize"
      "globstar"
      "cdspell"
      "autocd"
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
    };

    shellAliases = {
      ".." = "cd ..";
      nv = "nvim";
      ls = "eza -liha";
      l = "eza -lha --no-time --no-permissions --no-user";
      gs = "git status -sb";
      nrs = "darwin-rebuild switch --flake ~/.config/nix";
    };

    initExtra = ''
      # Security: restrictive umask
      umask 077

      # PATH
      export PATH="/run/current-system/sw/bin:$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
      export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

      # Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      # Secrets
      if [ -f "$HOME/.config/secrets/anthropic_api_key" ]; then
        export ANTHROPIC_API_KEY="$(cat "$HOME/.config/secrets/anthropic_api_key" | tr -d '\n')"
      fi

      # Starship prompt (cross-shell)
      if command -v starship >/dev/null; then
        eval "$(starship init bash)"
      fi

      # Zoxide (cross-shell cd replacement)
      if command -v zoxide >/dev/null; then
        eval "$(zoxide init bash)"
      fi

      # Direnv
      if command -v direnv >/dev/null; then
        eval "$(direnv hook bash)"
      fi
    '';
  };

  # ==========================================================================
  # NUSHELL - Already managed
  # ==========================================================================
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

  # Nushell stubs for lazy initialization
  home.file.".cache/starship/init.nu".text = "# starship nushell stub; overwritten at runtime if starship is installed\n";
  home.file.".cache/zoxide/init.nu".text = "# zoxide nushell stub; overwritten at runtime if zoxide is installed\n";

  # ==========================================================================
  # TMUX
  # ==========================================================================
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    escapeTime = 20;
    historyLimit = 2000000000;
    extraConfig = builtins.readFile ../../dotfiles/tmux/tmux.conf;
  };

  # Ensure tmux log dir exists for user launchd agent
  home.activation.tmuxLogDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/Library/Logs/tmux"
  '';

  # ==========================================================================
  # STARSHIP - Cross-shell prompt
  # ==========================================================================
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile starshipConfigPath);
  };
}
