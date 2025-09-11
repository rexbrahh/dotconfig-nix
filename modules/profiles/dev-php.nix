{ pkgs, ... }:
{
  # PHP + Composer
  home.packages = with pkgs; [
    php
    composer
  ];
}

