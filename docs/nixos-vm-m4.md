# nixos-vm-m4 bootstrap

These are the steps I use to bring up the Apple Silicon VM with the base NixOS ISO.

1. **Boot the ISO** inside UTM/Virtualization framework and log in as `root` (no password).
2. **Partition + format** the virtual disk (example for a single ext4 root on `/dev/vda`):
   ```bash
   parted /dev/vda -- mklabel gpt
   parted /dev/vda -- mkpart primary 512MiB 100%
   mkfs.ext4 -L nixos /dev/vda1
   ```
3. **Mount the new root** and create `/mnt/boot` if you plan to add a separate EFI partition later:
   ```bash
   mount /dev/vda1 /mnt
   mkdir -p /mnt/boot
   ```
4. **Clone this repo** onto the VM (feel free to use `curl` + `tar` if you prefer):
   ```bash
   nix-shell -p git --run 'git clone https://github.com/rexbrahh/dotconfig-nix /mnt/etc/nixos'
   ```
5. **Generate the hardware config** so the VM-specific devices are recorded, then copy it into the flake:
   ```bash
   nixos-generate-config --root /mnt --show-hardware-config \
     > /mnt/etc/nixos/hosts/nixos-vm-m4/hardware/generated.nix
   ```
6. **Install from the flake** (this uses the new `nixos-vm-m4` host definition):
   ```bash
   nixos-install --root /mnt --flake /mnt/etc/nixos#nixos-vm-m4
   ```
7. Reboot, log in as user `rxl` (initial password `changeme`), and immediately change the password with `passwd`.

If you keep your repo elsewhere, just adjust the clone path and the `nixos-install --flake` argument accordingly. The important bit is that `hosts/nixos-vm-m4/hardware/generated.nix` contains the VM’s hardware profile before the install.
