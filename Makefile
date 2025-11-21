# Remote-friendly bootstrap inspired by mitchellh/nixos-config, adapted to this repo.

# Connectivity to the live ISO / target host
NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= rexliu

# Target name in flake.nix (Darwin vs NixOS defaults)
UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
DEFAULT_NIXNAME := macbook
else
DEFAULT_NIXNAME := nixos-vm-m4
endif
NIXNAME ?= $(DEFAULT_NIXNAME)

# Disk device to partition/format during bootstrap0 (override for nvme/vda, etc.)
DISK ?= /dev/sda

# SSH opts for a fresh ISO (no host key, password auth only)
SSH_OPTIONS = -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# Path to this repo
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

.PHONY: switch test cache vm/bootstrap0 vm/bootstrap vm/copy vm/switch vm/secrets

switch:
ifeq ($(UNAME),Darwin)
	NIXPKGS_ALLOW_UNFREE=1 nix build --impure --extra-experimental-features nix-command --extra-experimental-features flakes ".#darwinConfigurations.${NIXNAME}.system"
	sudo NIXPKGS_ALLOW_UNFREE=1 ./result/sw/bin/darwin-rebuild switch --impure --flake "$$(pwd)#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --impure --flake ".#${NIXNAME}"
endif

test:
ifeq ($(UNAME),Darwin)
	NIXPKGS_ALLOW_UNFREE=1 nix build --impure ".#darwinConfigurations.${NIXNAME}.system"
	sudo NIXPKGS_ALLOW_UNFREE=1 ./result/sw/bin/darwin-rebuild test --impure --flake "$$(pwd)#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild test --impure --flake ".#$(NIXNAME)"
endif

# Build and push to a cachix cache (configure cachix separately)
cache:
	nix build '.#nixosConfigurations.$(NIXNAME).config.system.build.toplevel' --json \
		| jq -r '.[].outputs | to_entries[].value' \
		| cachix push rexliu-nixos-config

# Bootstrap a brand-new NixOS install over SSH. Assumes you set a root password on the ISO.
vm/bootstrap0:
	@if [ "$${CONFIRM:-}" != "1" ]; then echo "Set CONFIRM=1 to run destructive bootstrap0"; exit 1; fi
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		if [ ! -b $(DISK) ]; then echo \"Error: $(DISK) not found\"; exit 1; fi; \
		parted $(DISK) -- mklabel gpt; \
		parted $(DISK) -- mkpart primary 512MiB -8GB; \
		parted $(DISK) -- mkpart primary linux-swap -8GB 100\%; \
		parted $(DISK) -- mkpart ESP fat32 1MiB 512MiB; \
		parted $(DISK) -- set 3 esp on; \
		sleep 1; \
		mkfs.ext4 -L nixos $(DISK)1; \
		mkswap -L swap $(DISK)2; \
		mkfs.fat -F 32 -n boot $(DISK)3; \
		sleep 1; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/i \
			nix.package = pkgs.nixVersions.latest; \
			nix.extraOptions = \"experimental-features = nix-command flakes\"; \
			services.openssh.enable = true; \
			services.openssh.settings.PasswordAuthentication = true; \
			services.openssh.settings.PermitRootLogin = \"yes\"; \
			users.users.root.initialPassword = \"root\"; \
		' /mnt/etc/nixos/configuration.nix; \
		NIXPKGS_ALLOW_UNFREE=1 nixos-install --no-root-passwd && reboot; \
	"

# After bootstrap0, copy this repo and activate the flake, then reboot into the new system.
vm/bootstrap:
	NIXUSER=root $(MAKE) vm/copy
	NIXUSER=root $(MAKE) vm/switch
	$(MAKE) vm/secrets
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) "sudo reboot"

# Copy the Nix config into place on the target (defaults to /nix-config).
vm/copy:
	rsync -av -e "ssh $(SSH_OPTIONS) -p$(NIXPORT)" \
		--exclude='.git/' \
		--exclude='.git-crypt/' \
		--exclude='.jj/' \
		--exclude='iso/' \
		--exclude='result/' \
		--rsync-path="sudo rsync" \
		$(MAKEFILE_DIR)/ $(NIXUSER)@$(NIXADDR):/nix-config

# Run nixos-rebuild switch against the flake already copied to the target.
vm/switch:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --impure --flake \"/nix-config#${NIXNAME}\" \
	"

# Optionally copy SSH and GPG keys; skip or override NIXUSER if you don't want this.
vm/secrets:
	# GPG keyring
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='.#*' \
		--exclude='S.*' \
		--exclude='*.conf' \
		$(HOME)/.gnupg/ $(NIXUSER)@$(NIXADDR):~/.gnupg
	# SSH keys
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='environment' \
		$(HOME)/.ssh/ $(NIXUSER)@$(NIXADDR):~/.ssh
