{ lib, config, pkgs, ... }:
let
  cfg = config.ml.remote;
in
{
  options.ml.remote = {
    enable = lib.mkEnableOption "Remote ML workflow helpers (SSH/mosh/autossh)";

    packages = lib.mkOption {
      type = with lib.types; listOf package;
      default = with pkgs; [ mosh autossh rsync openssh ];
      description = "Extra packages useful for remote workflows.";
    };

    sshDefaults.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Augment programs.ssh with ControlMaster, KeepAlive, and agent forwarding.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = cfg.packages;

    programs.ssh.enable = lib.mkDefault true;
    programs.ssh.matchBlocks."*".extraOptions = lib.mkIf cfg.sshDefaults.enable {
      ControlMaster = lib.mkDefault "auto";
      ControlPersist = lib.mkDefault "30m";
      ControlPath = lib.mkDefault "~/.ssh/cm-%r@%h:%p";
      ExitOnForwardFailure = lib.mkDefault "yes";
      # Default to no agent forwarding; enable per-host as needed.
      ForwardAgent = lib.mkDefault "no";
      TCPKeepAlive = lib.mkDefault "yes";
      StrictHostKeyChecking = lib.mkDefault "yes";
      UpdateHostKeys = lib.mkDefault "yes";
    };
  };
}
