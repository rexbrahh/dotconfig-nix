{
  config,
  pkgs,
  lib,
  ...
}: let
  brews = import ./homebrew/brews.nix;
  casks = import ./homebrew/casks.nix;
  brewManagedByNix = config ? nix-homebrew && (config.nix-homebrew.enable or false);
in {
  homebrew = {
    enable = true;
    # Do not force-tap default repos; Homebrew manages core/cask itself.
    taps = [
      "koekeishiya/formulae"
      "nextdns/tap"
    ];
    global = {
      brewfile = true; # creates/uses Brewfile for visibility
      # nix-homebrew installs Homebrew code from the Nix store (no git repo),
      # so self-updating the brew CLI is intentionally disabled. When Homebrew
      # is installed via the official installer, allow upstream auto-updates.
      autoUpdate = lib.mkDefault (!brewManagedByNix);
    };
    onActivation = {
      # Keep `darwin-rebuild switch` fast and idempotent; upgrades are handled
      # by the scheduled launchd updater (modules/homebrew-autoupdate.nix).
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
    };
    brews = brews;
    casks = casks;
  };
}
