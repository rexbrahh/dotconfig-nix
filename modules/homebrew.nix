{pkgs, ...}: let
  brews = import ./homebrew/brews.nix;
  casks = import ./homebrew/casks.nix;
in {
  homebrew = {
    enable = true;
    # Do not force-tap default repos; Homebrew manages core/cask itself.
    taps = [
      "koekeishiya/formulae"
    ];
    global = {
      brewfile = true; # creates/uses Brewfile for visibility
      autoUpdate = false; # nix controls versions; keep brew quiet
    };
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    brews = brews;
    casks = casks;
  };
}
