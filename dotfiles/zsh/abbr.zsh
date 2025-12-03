# Fish-like abbreviations for Zsh (requires abbrev-alias)
if command -v abbrev-alias >/dev/null; then
  abbrev-alias gco='git checkout'
  abbrev-alias gst='git status -sb'
  abbrev-alias gl='git pull --ff-only'
  abbrev-alias gp='git push'
  abbrev-alias ..='cd ..'
  abbrev-alias ...='cd ../..'
fi
