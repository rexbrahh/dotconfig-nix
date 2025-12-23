{
  lib,
  pkgs,
  ...
}: let
  zshrcPath = ../../dotfiles/zsh/.zshrc;
  fishConfigPath = ../../dotfiles/fish/config.fish;
  nushellConfigPath = ../../dotfiles/nushell/config.nu;
  nushellEnvPath = ../../dotfiles/nushell/env.nu;
  starshipConfigPath = ../../dotfiles/starship/starship.toml;
in {
  # Choose your login shell (per-user)
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
  home.file.".p10k.zsh".source = ../../dotfiles/zsh/.p10k.zsh;

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

  # Prompt
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile starshipConfigPath);
  };
}
