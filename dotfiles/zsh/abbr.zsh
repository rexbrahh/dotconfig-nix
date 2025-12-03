# Fish-like abbreviations for Zsh (requires abbrev-alias)
if command -v abbrev-alias >/dev/null; then
  abbrev-alias gco='git checkout'
  abbrev-alias gcb='git checkout -b'
  abbrev-alias gst='git status -sb'
  abbrev-alias gl='git pull --ff-only'
  abbrev-alias gp='git push'
  abbrev-alias gcm='git commit -m'
  abbrev-alias gca='git commit --amend --no-edit'
  abbrev-alias ..='cd ..'
  abbrev-alias ...='cd ../..'
fi
