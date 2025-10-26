{
  lib,
  inputs,
  config,
  pkgs,
  ...
}:
let
  user = builtins.getEnv "USER"; # or: "rexliu"
in
{
  imports =
    let
      secretsModule = ../../secrets/secrets.nix;
    in
    [
      # Darwin-level modules
      ../../modules/default.nix
      ../../modules/vagrant.nix
      # ML tunnels (SSH port forwards via launchd; disabled by default)
      ../../modules/ml-tunnels.nix
      # add more modules here
    ]
    # Declarative secrets (agenix; only import when the module exists)
    ++ lib.optional (builtins.pathExists secretsModule) secretsModule;
  nix.enable = true;
  # Core Nix setup
  nix = {
    # Flakes + new CLI
    package = pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      ssl-cert-file = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
      trusted-users = [
        "root"
        "rexliu"
      ];
      sandbox = lib.mkForce "relaxed";
      require-sigs = true;
      substituters = [
        "https://cache.nixos.org"
        # common community caches you might add later
      ];
      # Example extra cache public keys go here
    };
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      }; # Sundays 03:00
      options = "--delete-older-than 14d";
    };
  };
  nix.optimise.automatic = true;
  system.primaryUser = "rexliu";

  #home-manager.users.rexliu = import ./home.nix;
  #system.stateVersion = 6;
  security.pam.services.sudo_local = {
    # manage /etc/pam.d/sudo_local declaratively (defaults to true)
    enable = true;

    # enable Touch ID for sudo
    touchIdAuth = true;

    # critical bit for tmux/screen: inserts pam_reattach before pam_tid
    reattach = true;

    # optional: also allow Apple Watch for sudo prompts
    # watchIdAuth = true;
  };
  users.users.rexliu = {
    name = "rexliu";
    home = "/Users/rexliu";
    shell = pkgs.fish;
  };
  environment.shells = [
    pkgs.zsh
    pkgs.fish
  ];
  #programs.zsh.enable = true;
  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.rexliu = {
      # Now bring in your HM modules here:
      imports = [
        # Home Manager (user) modules only
        ../../modules/home.nix
        # Optional dotfiles (copied from this repo)
        ../../modules/dotfiles/default.nix
        # Language/tooling profiles
        ../../modules/profiles/dev-cpp.nix
        ../../modules/profiles/dev-zig.nix
        ../../modules/profiles/dev-rust.nix
        ../../modules/profiles/dev-go.nix
        ../../modules/profiles/dev-node.nix
        ../../modules/profiles/dev-python.nix
        ../../modules/profiles/dev-java.nix
        ../../modules/profiles/dev-kotlin.nix
        ../../modules/profiles/dev-php.nix
        ../../modules/profiles/dev-ruby.nix
        ../../modules/profiles/dev-elixir.nix
        ../../modules/profiles/dev-containers.nix
        ../../modules/profiles/dev-databases.nix
        ../../modules/profiles/dev-vm.nix
        ../../modules/onepassword.nix
        # ML-focused global tooling (opt-in modules)
        ../../modules/profiles/dev-ml.nix
        ../../modules/ml-env.nix
        ../../modules/ml-remote.nix
      ];

      # Enable 1Password CLI and SSH agent integration
      onepassword = {
        enable = true;
        sshAgent.enable = true;
      };

      # Standardize ML data/cache dirs and remote SSH ergonomics
      ml.env.enable = true;
      ml.remote.enable = true;
    };
  };
  home-manager.backupFileExtension = "rebuild";
  programs.fish.enable = true;
  # Fast package lookups with nix-index (prebuilt DB) + comma wrapper
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
  #system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false; # faster key repeat
  #system.defaults.NSGlobalDomain.KeyRepeat = 2;
  #system.defaults.NSGlobalDomain.InitialKeyRepeat = 25;
  #system.defaults.NSGlobalDomain.TALLogoutReason = "DeveloperFlow";

  #  system.defaults.alf.globalstate = 1;  # enable macOS firewall
  #  system.defaults.alf.allowdownloadsignedenabled = true;

  #  system.defaults.finder.AppleShowAllExtensions = true;

  #  programs.zsh.enableCompletion = true;
  #  programs.zsh.enableAutosuggestions = true;
  #  programs.zsh.initExtra = ''
  #    export EDITOR=nvim
  #    export HOMEBREW_NO_AUTO_UPDATE=1
  #  '';

  # System packages moved to modules/packages.nix

  # Launch services & quality-of-life
  # nix-daemon is managed automatically when `nix.enable = true`
   # Networking / hostname
  networking = {
    computerName = "MacBook";
    hostName = "macbook";
    localHostName = "macbook";
  };

  # Allow unfree globally (you can limit in HM instead)
  nixpkgs.config.allowUnfree = true;

  # macOS Application Firewall (ALF)
  networking.applicationFirewall = {
    enable = true;
    allowSignedApp = true;
    enableStealthMode = true;
    blockAllIncoming = false; # set true if you want maximum strictness
  };

  # Keep /etc files managed
  system.stateVersion = 5; # <- bump only after reading release notes

  # Window manager and hotkey daemon (managed via nix-darwin)
  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = false; # safer default; enable only if you’ve handled SIP steps
  };
  services.skhd = {
    enable = true;
    package = pkgs.skhd;
  };

  # Ensure tmux server is available after login
  launchd.user.agents."tmux" = {
    serviceConfig = {
      ProgramArguments = [ "${pkgs.tmux}/bin/tmux" "start-server" ];
      EnvironmentVariables = {
        PATH = lib.concatStringsSep ":" [
          "${config.users.users.rexliu.home}/.nix-profile/bin"
          "/etc/profiles/per-user/${config.users.users.rexliu.name}/bin"
          "/run/current-system/sw/bin"
          "/nix/var/nix/profiles/default/bin"
          "/opt/homebrew/bin"
          "/opt/homebrew/sbin"
          "/usr/local/bin"
          "/usr/bin"
          "/bin"
        ];
        SHELL = "/bin/sh";
      };
      RunAtLoad = true;
      KeepAlive = false; # start once at login is sufficient
      StandardOutPath = "${config.users.users.rexliu.home}/Library/Logs/tmux/agent.out";
      StandardErrorPath = "${config.users.users.rexliu.home}/Library/Logs/tmux/agent.err";
    };
  };

  # Launchd-managed SSH tunnels for remote ML workflows
  ml.tunnels = {
    enable = false; # opt-in per host/session; safer default
    destination = "gpu-box"; # SSH host alias; update to your remote
    jupyter.enable = true;
    mlflow.enable = true;
  };
}
