{ lib, ... }:

let
  owner = "rexliu";
  secretFile = ./anthropic-api-key.age;
  targetPath = "/Users/${owner}/.config/secrets/anthropic_api_key";
in
lib.mkIf (builtins.pathExists secretFile) {
  age.secrets."anthropic-api-key" = {
    file = secretFile;
    path = targetPath;
    mode = "0400";
    inherit owner;
    group = "staff";
  };
}
