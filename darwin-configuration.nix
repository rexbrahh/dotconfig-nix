{ lib, inputs, config, pkgs, ... }:

{
  nix.enable = false;
	
  home-manager.users.rexliu = import ./home.nix;
  system.stateVersion = 6;
  security.pam.services.sudo_local.touchIdAuth = true;
 
  users.users.rexliu = {
    name = "rexliu";
    home = "/Users/rexliu";
  };  
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
  ];
}
