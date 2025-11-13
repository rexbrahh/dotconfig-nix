# htznrpsnl (Hetzner Ubuntu server)

Target for the rented Hetzner server (user `rxl`). Install Nix + Home Manager, then apply:

```
home-manager switch --flake ~/.config/nix#rxl@htznrpsnl
```

Override `home.username`/`home.homeDirectory` here if the server uses a different account name.
