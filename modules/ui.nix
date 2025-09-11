{ pkgs, ... }:
{
  # Extra UI defaults & small quality-of-life bits live here.
  system.defaults = {
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false; # better key repeat
      AppleInterfaceStyleSwitchesAutomatically = true;
    };
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
    dock = {
      orientation = "bottom";
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

}

