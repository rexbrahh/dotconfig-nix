# Remote bootstrap (minimal ISO over SSH)

This mirrors the mitchellh/nixos-config flow but hardens after the final switch.

## Parameters
- `NIXADDR`: IP of the live ISO (root password set manually).
- `NIXPORT`: SSH port (default 22).
- `NIXUSER`: user to SSH as during copy/switch (defaults to `rexliu`; use `root` until the user exists).
- `NIXNAME`: flake host (defaults: `macbook` on Darwin, `nixos-vm-m4` elsewhere).
- `DISK`: target disk (default `/dev/sda`; override to `/dev/vda` or `/dev/nvme0n1`).

## Steps
1) Boot minimal NixOS ISO, set a root password, `ip a` to get `NIXADDR`.
2) From your workstation (macOS):
   ```bash
   export NIXADDR=192.168.x.x NIXPORT=22 NIXNAME=nixos-vm-m4 DISK=/dev/vda
   CONFIRM=1 make vm/bootstrap0    # partitions/formats, enables temp password SSH, installs, reboots
   ```
3) After it reboots, copy config and switch:
   ```bash
   NIXUSER=root make vm/bootstrap   # copies repo, switch to flake, optional secrets copy, reboot
   ```
4) Log in as `rexliu` (initial password `changeme`); the final config disables root login and password SSH (keys only), requires sudo passwords, keeps users immutable, and enables the firewall with SSH open via `modules/os/nixos/default.nix`.

## Notes
- `vm/secrets` rsyncs `~/.ssh` and `~/.gnupg`; run only on trusted networks or skip by editing the Makefile invocation.
- If you rely on password SSH long-term, override `services.openssh.settings.PasswordAuthentication = true;` in the host, but default is hardened and the firewall allows only SSH by default.
- Default desktop stack is Hyprland with i3 and GNOME sessions available via GDM. Docker runs by default; the firewall stays on.
- Always regenerate `hosts/<name>/hardware-configuration.nix` on each machine before switching.
