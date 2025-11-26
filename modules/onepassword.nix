{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.onepassword;
in {
  options.onepassword = {
    enable = lib.mkEnableOption "Install 1Password CLI and optional integrations";

    sshAgent.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''        Use 1Password SSH agent by setting
                IdentityAgent ~/.1password/agent.sock in SSH config. Requires the
                1Password desktop app with SSH agent enabled.'';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs._1password-cli];

    programs.ssh.enable = lib.mkDefault true;
    programs.ssh.matchBlocks."*".extraOptions = lib.mkIf cfg.sshAgent.enable {
      IdentityAgent = "~/.1password/agent.sock";
    };
  };
}
