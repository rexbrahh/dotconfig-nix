{
  config,
  pkgs,
  ...
}: {
  # Extra UI defaults & small quality-of-life bits live here.
  system.defaults = {
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false; # better key repeat
      AppleInterfaceStyleSwitchesAutomatically = false;
      AppleInterfaceStyle = "Dark";
    };
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
    dock = {
      orientation = "bottom";
      tilesize = 69;
      magnification = true;
      largesize = 128;
      autohide = true;
      "autohide-delay" = 0.0;
      "autohide-time-modifier" = 0.21;
      persistent-apps = [
        #"/System/Applications/Launchpad.app"
        "Applications/Google\ Chrome.app"
        "/Applications/Ghostty.app"

        #"/Applications/Visual Studio Code.app"
      ];
    };
    finder = {
      FXPreferredViewStyle = "Nlsv"; # list view
      ShowPathbar = true;
      ShowStatusBar = true;
    };
  };

  # nix-darwin does not currently expose NSGlobalDomain
  # key "com.apple.swipescrolldirection" via system.defaults,
  # so set it explicitly during activation.
  # This writes the per-user preference and restarts the prefs cache.
  system.activationScripts.setScrollDirection.text = ''
    launchctl asuser "$(id -u -- ${config.system.primaryUser})" \
      sudo --user=${config.system.primaryUser} -- \
      defaults write -g com.apple.swipescrolldirection -bool true
    # Restart the preferences daemon for the user so the change applies
    killall -qu ${config.system.primaryUser} cfprefsd || true
  '';
}
