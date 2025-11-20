# server-ubuntu (public alias)

Generic Home Manager profile for the rented Ubuntu server. To keep the real hostname/user private, create `hosts/server-ubuntu/local.nix` with overrides:

```
{
  username = "rexliu";
  homeDirectory = "/home/rexliu";
}
```

This file is gitignored. Once set, run `home-manager switch --flake ~/.config/nix#server@ubuntu` (or `./scripts/home-switch.sh`).
