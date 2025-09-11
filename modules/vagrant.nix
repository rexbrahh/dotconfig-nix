{ lib, pkgs, config, ... }:
let
  cfg = config.vagrant;
in
{
  options.vagrant.plugins = lib.mkOption {
    type = with lib.types; listOf str;
    default = [ ];
    description = "List of Vagrant plugins to ensure installed (e.g., 'vagrant-parallels').";
    example = [ "vagrant-parallels" "vagrant-disksize" ];
  };

  config = lib.mkIf (cfg.plugins != [ ]) {
    system.activationScripts.vagrantPlugins.text = ''
      if command -v vagrant >/dev/null 2>&1; then
        echo "Ensuring Vagrant plugins: ${lib.concatStringsSep " " cfg.plugins}"
        for p in ${lib.concatStringsSep " " cfg.plugins}; do
          if ! vagrant plugin list | grep -q "^$p\b"; then
            vagrant plugin install "$p" || true
          fi
        done
      else
        echo "vagrant not found; skipping plugin installation"
      fi
    '';
  };
}
