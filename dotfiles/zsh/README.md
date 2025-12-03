# Zsh setup (fish-like)

Required pieces (Home Manager manages symlinks):
- Starship prompt via `modules/home.nix`.
- Oh My Zsh with plugins: git, zsh-autosuggestions, zsh-syntax-highlighting, you-should-use, history-substring-search.

Vendored (guarded) in `$ZSH_DEN`:
- zsh-completions (extra completion definitions).
- zsh-autopair (pairing).
- zsh-abbrev-alias (fish-style abbreviations).
- zsh-autocomplete (completion UI).
- fzf-tab, forgit (fzf-powered completions/git helpers).

Abbreviations:
- `dotfiles/zsh/abbr.zsh` defines the current abbrev set; loaded only if abbrev-alias is available.

Prompt behavior:
- Left: directory + git (terse status).
- Right: status/jobs + host/time + runtimes (zig/rust/golang/node/python/ruby) + docker/package + nix shell/version. Right prompt truncates if too long; Starship/fish cannot wrap it to a second right-aligned line.
- Prompt chars: `❯` fish-blue (#85befd), red on error; `❮` in blue for vi-cmd.

Notes:
- zsh-autocomplete and fzf-tab both load; fzf-tab is limited to file/path completion to reduce overlap.
- vi-mode is not enabled by default (fish defaults to emacs-ish).
