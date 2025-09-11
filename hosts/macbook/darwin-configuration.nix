{ lib, inputs, config, pkgs, ... }:

{
  nix.enable = false;
   Core Nix setup
  nix = {
    # Flakes + new CLI
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "${config.users.primaryUser.name}" ];
      substituters = [
        "https://cache.nixos.org"
        # common community caches you might add later
      ];
      # Example extra cache public keys go here
    };
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 3; Minute = 0; }; # Sundays 03:00
      options = "--delete-older-than 14d";
    };
  };
	
  #home-manager.users.rexliu = import ./home.nix;
  system.stateVersion = 6;
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
  };  
  environment.shells = [ pkgs.zsh pkgs.fish ];
  programs.zsh.enable = true;
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

  environment.systemPackages = with pkgs; [
    git
    zsh
    wget
    curl
    jq
    direnv
    tree
    tmux
    zoxide
    fd
    bat
    neovim
    devenv
    gnupg
    vim
  ];
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyleSwitchesAutomatically = true;  # auto light/dark
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSDocumentSaveNewDocumentsToCloud = false;
      "com.apple.swipescrolldirection" = false;        # natural scrolling off
    };
    dock = {
      autohide = true;
      show-recents = false;
      tilesize = 48;
      mru-spaces = false;
    };
    finder = {
      AppleShowAllFiles = true;
      FXPreferredViewStyle = "clmv"; # column view
      ShowPathbar = true;
      ShowStatusBar = true;
    };
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
    screencapture.location = "${config.users.primaryUser.home}/Screenshots";
  };
   # Launch services & quality-of-life
  services.nix-daemon.enable = true; # needed for multi-user Nix on macOS
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    taps = [ "homebrew/cask" "homebrew/cask-fonts" ];
    brews = [
      # CLI tools best kept in Nix, but a few have better brew formulae
    ];
    casks = [
      "ghostty"
      "raycast"
      "visual-studio-code"
      "docker"
      "font-jetbrains-mono"
    ];
  };
  fonts = {
    enable = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    ];
  };

  # Networking / hostname
  networking = {
    computerName = "MacBook";
    hostName     = "macbook";
    localHostName = "macbook";
  };

  # Allow unfree globally (you can limit in HM instead)
  nixpkgs.config.allowUnfree = true;

  # Keep /etc files managed
  system.stateVersion = 5; # <- bump only after reading release notes
}

