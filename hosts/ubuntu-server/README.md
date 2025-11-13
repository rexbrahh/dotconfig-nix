# ubuntu-server (Home Manager on Ubuntu)

Target for the rented Hetzner server. Install Nix + Home Manager, then apply:

```
home-manager switch --flake ~/.config/nix#rex@ubuntu
```

Override `home.username`/`home.homeDirectory` here if the server uses a different account name.
