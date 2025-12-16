{
  lib,
  pkgs,
  ...
}: {
  # Base display server + sessions
  services.xserver = {
    enable = lib.mkDefault true;
    windowManager.i3 = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.i3;
    };
  };

  services.displayManager = {
    gdm.enable = lib.mkDefault true;
    gdm.wayland = lib.mkDefault true;
    defaultSession = lib.mkDefault "hyprland";
  };

  services.desktopManager.gnome.enable = lib.mkDefault true;

  # Wayland compositor (Hyprland) with portals
  programs.hyprland.enable = lib.mkDefault true;

  xdg.portal = {
    enable = lib.mkDefault true;
    wlr.enable = lib.mkDefault true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XCURSOR_SIZE = "24";
  };

  environment.systemPackages = with pkgs; [
    alacritty
    waybar
    rofi
    grim
    slurp
    wl-clipboard
    networkmanagerapplet
  ];
}
