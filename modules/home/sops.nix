{
  config,
  lib,
  pkgs,
  ...
}: let
  # Use absolute path to avoid issues with different evaluation contexts
  secretsDir = ../..;
  secretsFile = secretsDir + "/secrets/secrets.yaml";
  hasSecretsFile = builtins.pathExists secretsFile;
  hasAgeKey = builtins.pathExists "${config.home.homeDirectory}/.config/sops/age/keys.txt";
in {
  # sops-nix home-manager configuration
  # Only enable if secrets file exists
  sops = lib.mkIf hasSecretsFile {
    # Age key location (generated with `age-keygen -o ~/.config/sops/age/keys.txt`)
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    # Default sops file for secrets
    defaultSopsFile = secretsFile;

    # Secrets configuration
    secrets = {
      # Anthropic API key - decrypted to ~/.config/secrets/anthropic_api_key
      anthropic_api_key = {
        path = "${config.home.homeDirectory}/.config/secrets/anthropic_api_key";
        mode = "0400";
      };

      # Add more secrets here as needed:
      # openai_api_key = {
      #   path = "${config.home.homeDirectory}/.config/secrets/openai_api_key";
      #   mode = "0400";
      # };
    };
  };

  # Ensure the secrets directory exists
  home.activation.ensureSecretsDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "${config.home.homeDirectory}/.config/secrets"
    chmod 700 "${config.home.homeDirectory}/.config/secrets"
  '';
}
