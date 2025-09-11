{ pkgs, ... }:
{
  # Kotlin CLI tools
  home.packages = with pkgs; [
    kotlin
    ktlint
  ];
}

