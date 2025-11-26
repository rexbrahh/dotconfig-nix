{
  lib,
  config,
  ...
}: let
  secretFile = ./anthropic-api-key.age;
  owners = [
    {
      name = "rexliu";
      defaultGroup = "staff";
    }
  ];

  mkSecret = {
    name,
    defaultGroup,
  }: let
    homePath = lib.attrByPath ["users" "users" name "home"] null config;
    group = lib.attrByPath ["users" "users" name "group"] defaultGroup config;
  in
    lib.mkIf (homePath != null) {
      "anthropic-api-key-${name}" = {
        file = secretFile;
        path = "${homePath}/.config/secrets/anthropic_api_key";
        mode = "0400";
        owner = name;
        inherit group;
      };
    };
in
  lib.mkIf (builtins.pathExists secretFile) {
    age.secrets = lib.mkMerge (map mkSecret owners);
  }
