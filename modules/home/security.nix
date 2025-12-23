{
  lib,
  pkgs,
  ...
}: let
  hmSshConfigPath = ".ssh/config.d/home-manager.conf";
  hmSshIncludePattern = "config.d/home-manager.conf";
in {
  # GPG & SSH
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 7200;
    enableSshSupport = false;
    pinentry.package =
      if pkgs.stdenv.isDarwin
      then pkgs.pinentry_mac
      else pkgs.pinentry-curses;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
      extraOptions =
        {
          AddKeysToAgent = "ask";
          IdentitiesOnly = "yes";
          ForwardAgent = "no";
          StrictHostKeyChecking = "yes";
          UpdateHostKeys = "yes";
          HashKnownHosts = "yes";
        }
        // lib.optionalAttrs pkgs.stdenv.isDarwin {
          UseKeychain = "yes";
        };
    };
    matchBlocks."gpu-box".extraOptions.ForwardAgent = "yes";
  };

  # Write Home Manager's SSH config to a separate include file.
  home.file.".ssh/config".target = hmSshConfigPath;

  # Ensure the user's config includes the Home Manager defaults.
  home.activation.sshConfigInclude = lib.hm.dag.entryAfter ["writeBoundary"] ''
    config_path="$HOME/.ssh/config"
    include_path="$HOME/${hmSshConfigPath}"
    include_line="Include $include_path"

    mkdir -p "$HOME/.ssh/config.d"

    if [ -L "$config_path" ]; then
      target="$(readlink "$config_path")"
      case "$target" in
        /nix/store/*)
          rm -f "$config_path"
          ;;
      esac
    fi

    if [ ! -f "$config_path" ]; then
      printf "%s\n" "$include_line" > "$config_path"
      chmod 600 "$config_path"
    else
      if ! grep -Fq "${hmSshIncludePattern}" "$config_path"; then
        printf "\n%s\n" "$include_line" >> "$config_path"
      fi
    fi
  '';

  # Import GPG public key + ownertrust (safe: public material only)
  home.activation.importGpgKey = lib.hm.dag.entryAfter ["tmuxLogDir"] ''
    if command -v gpg >/dev/null; then
      gpg --quiet --import ${../../dotfiles/gpg/public.asc} || true
      gpg --quiet --import-ownertrust ${../../dotfiles/gpg/ownertrust.txt} || true
    fi
  '';
}
