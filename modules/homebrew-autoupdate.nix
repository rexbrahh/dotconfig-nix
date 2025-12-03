{ config, lib, pkgs, ... }:
let
  user = config.system.primaryUser or "rexliu";
  userHome =
    if builtins.hasAttr user config.users.users
    then config.users.users.${user}.home
    else "/Users/${user}";

  script = pkgs.writeShellScript "brew-autoupdate" ''
    set -euo pipefail

    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin"
    export HOMEBREW_NO_ENV_HINTS=1
    export HOMEBREW_NO_ANALYTICS=1

    /opt/homebrew/bin/brew update --auto-update
    /opt/homebrew/bin/brew upgrade --greedy
    /opt/homebrew/bin/brew cleanup
  '';
in {
  options.brewAutoUpdate = {
    enable = lib.mkEnableOption "launchd-managed Homebrew auto-update";
    hour = lib.mkOption {
      type = lib.types.ints.between 0 23;
      default = 4;
      description = "Hour (0-23) to run the updater.";
    };
    minute = lib.mkOption {
      type = lib.types.ints.between 0 59;
      default = 15;
      description = "Minute (0-59) to run the updater.";
    };
  };

  config = lib.mkIf config.brewAutoUpdate.enable {
    launchd.user.agents."brew-autoupdate" = {
      serviceConfig = {
        ProgramArguments = [ "${script}" ];
        StartCalendarInterval = [{
          Hour = config.brewAutoUpdate.hour;
          Minute = config.brewAutoUpdate.minute;
        }];
        RunAtLoad = true;
        KeepAlive = false;
        StandardOutPath = "${userHome}/Library/Logs/brew-autoupdate.log";
        StandardErrorPath = "${userHome}/Library/Logs/brew-autoupdate.log";
      };
    };
  };
}
