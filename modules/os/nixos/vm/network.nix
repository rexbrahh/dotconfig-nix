{lib, ...}: {
  networking = {
    networkmanager.enable = lib.mkDefault true;
    firewall = {
      enable = lib.mkDefault true;
      allowedTCPPorts = lib.mkDefault [22];
      allowPing = lib.mkDefault true;
    };
  };

  services.openssh = {
    enable = lib.mkDefault true;
    openFirewall = lib.mkDefault true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
    };
  };
}
