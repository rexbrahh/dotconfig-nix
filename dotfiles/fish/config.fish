# Fish shell init (managed via Home Manager)

# PATH & basics
set -Ux fish_greeting
if test -d /opt/homebrew/bin
  fish_add_path -g /opt/homebrew/bin /opt/homebrew/sbin
end
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.local/share/solana/install/active_release/bin
direnv hook fish | source
set -gx EMSDK_QUIET 1
set -l emsdk_env "$HOME/emsdk/emsdk_env.fish"
if test -f "$emsdk_env"
  source "$emsdk_env"
end
# EDITOR (SSH-aware) + VISUAL/PAGER
if set -q SSH_CONNECTION
  set -gx EDITOR vim
else
  set -gx EDITOR nvim
end

set -gx VISUAL nvim
fish_add_path -g /run/current-system/sw/bin
set -gx PAGER less
umask 077

zoxide init fish | source
#set -gx ANTHROPIC_BASE_URL https://cc.yovy.app
if test -f "$HOME/.config/secrets/anthropic_api_key"
  set -gx ANTHROPIC_API_KEY (string trim (cat "$HOME/.config/secrets/anthropic_api_key"))
end
#set -gx ANTHROPIC_MODEL anthropic/claude-sonnet-4.5
#set -gx ANTHROPIC_SMALL_FAST_MODEL x-ai/grok-4-fast:free

# Auto-attach tmux when launching an interactive shell in Ghostty
# - skip if already inside tmux
# - skip for SSH sessions
if status is-interactive
  and test -z "$TMUX"
  and test "$TERM_PROGRAM" = "Ghostty"
  and command -sq tmux
  and test -z "$FISH_NO_AUTO_TMUX"
  exec tmux -u new-session -A -s main
end
