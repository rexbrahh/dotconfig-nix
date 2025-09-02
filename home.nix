{ config, pkgs, ... }:

{
  home.username = "rexliu";
  home.homeDirectory = "/Users/rexliu";
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    htop
    neovim
    fd
    bat
    zoxide
    fzf
  ];
  programs.fzf = {
    enable = true;
    enableZshIntegration = true; # This is the modern equivalent
  };

#  home.file.".config/tmux/tmux.conf".source = "/Users/rexliu/.config/tmux/tmux.conf";
#  home.file.".config/tmux/tmux.conf.local".source = "/Users/rexliu/.config/tmux/tmux.conf.local";

  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
   # historyLimit = 20000;
    terminal = "screen-256color";
    keyMode = "vi";
    shortcut = "a"; # Changes tmux prefix to ctrl+a
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      # Add more plugins as desired
    ];
    extraConfig = ''
      # Tmux custom config below

      # Set a nice theme
      set -g status-bg colour235
      set -g status-fg colour136

      # Enable vim style copy
      setw -g mode-keys vi

      # Reload config file
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      # Set better pane navigation
      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      # Optional: Source oh-my-tmux if you use it and have linked it
      source-file ~/oh-my-tmux/.tmux.conf
    '';
  };

  programs.zsh = {
  	enable = true;
  	enableCompletion = true;
  	#enableFzfCompletion = true;   # for FZF integration
  	syntaxHighlighting.enable = true;
  # For autosuggestions, install the package yourself:
  	plugins = [
    		{ name = "zsh-autosuggestions"; src = pkgs.zsh-autosuggestions; }
  	];
  	initExtra = ''
    		export EDITOR=nvim
    		export HOMEBREW_NO_AUTO_UPDATE=1
  		'';
  };
 
  programs.git = {
    enable = true;
    userName = "Rex Liu";
    userEmail = "hi@r3x.sh";
  };

  # other dotfile and system preferences here
}

