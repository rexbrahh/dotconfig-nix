{pkgs, ...}: {
  # Virtual machine & provisioning workflow tools.
  # Vagrant itself is installed via Homebrew cask `hashicorp-vagrant`.
  home.packages = with pkgs; [
    packer
    ansible
    ansible-lint
    qemu
  ];
}
