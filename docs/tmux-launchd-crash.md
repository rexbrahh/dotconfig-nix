# Tmux Launchd Crash Investigation

## Symptoms

- Ghostty windows that auto-attach to tmux would immediately close.
- Manual `tmux` launches from the shell succeeded, but the launchd-managed server exited during startup.
- `~/tmux-server-*.log` showed the server starting and then terminating right after running TPM (`~/.tmux/plugins/tpm/tpm`).

## Root Cause

The launch agent defined in `hosts/macbook/darwin-configuration.nix` starts tmux with launchd's default environment (`PATH=/usr/bin:/bin:/usr/sbin:/sbin`).  
Your tmux config (`~/.tmux.conf`) runs every pane with:

```
set-option -g default-shell /usr/bin/env fish -l
```

Because `fish` only lives in the user profile (`/etc/profiles/per-user/rexliu/bin`), `env` failed to locate it when the server was started by launchd. The child process exited immediately, so the session never opened.

Tmux Plugin Manager compounded the issue: TPM also shells out to `tmux`, and the restricted `PATH` meant helpers like `tmux` and `fish` were missing, causing plugin startup to fail.

## Fix

1. **Pin the shell path in tmux config**  
   Updated `~/.tmux.conf`:
   ```tmux
   set-option -g default-shell /etc/profiles/per-user/rexliu/bin/fish
   set-option -g default-command "exec /etc/profiles/per-user/rexliu/bin/fish -l"
   ```
   This avoids relying on `PATH` to discover fish.

2. **Inject a full PATH for the launch agent**  
   Added `EnvironmentVariables` to `launchd.user.agents."tmux"` in `hosts/macbook/darwin-configuration.nix` so launchd supplies a PATH that includes:
   ```
   ~/.nix-profile/bin
   /etc/profiles/per-user/rexliu/bin
   /run/current-system/sw/bin
   /nix/var/nix/profiles/default/bin
   /opt/homebrew/{bin,sbin}
   /usr/local/bin
   /usr/bin
   /bin
   ```
   and sets `SHELL=/bin/sh`.

After rebuilding (`darwin-rebuild switch --flake .#macbook`) and killing the old tmux server, new Ghostty windows attach cleanly. Launchd sessions now find both fish and tmux binaries, so TPM and other plugins load without crashing the server.

## Follow-Up

- If you ever relocate fish, update both the tmux config and the launch agent PATH.
- `Tmux.Start.plist` created by tmux-continuum still spawns iTerm sessions; consider pruning it if you rely solely on Ghostty.
