# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
source <(fzf --zsh)
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
POWERLEVEL9K_DISABLE_GITSTATUS=true
POWERLEVEL10K_DISABLE_GITSTATUS=true
export PATH="/run/current-system/sw/bin:$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
export PATH=$PATH:~/opt/homebrew/bin/Zig
export PATH="/opt/homebrew/Cellar/node/24.6.0/bin:$PATH"
fpath=(/Users/rexliu/.docker/completions $fpath)

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
#ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.


plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/sbin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"


export PATH="$HOME/.local/bin:$PATH"


export TERM=xterm-256color

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

export PATH="$PATH:/opt/homebrew/bin/lua-language-server"

export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:$NIX_PATH}


#export MY_FLAKE_CONFIG="$HOME/.config/nix"
#alias flake-show="nix flake show $MY_FLAKE_CONFIG"

# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi


## from andres' dotfiles

# Only auto attach tmux for interactive, local terminal sessions
if [[ -o interactive ]] \
   && [[ -z ${TMUX+X} ]] \
   && [[ -z ${SSH_TTY+X} ]] \
   && [[ "$TERM_PROGRAM" = "Ghostty" || "$TERM_PROGRAM" = "Apple_Terminal" ]]; then
  if command -v tmux >/dev/null; then
    tmux new -As init
  fi
fi

ZSH_DEN=$HOME/zsh-den

# Clone missing plugins that aren't provided by oh-my-zsh.
if [[ ! -e $ZSH_DEN/fzf-tab ]]; then
    git clone --depth=1 https://github.com/Aloxaf/fzf-tab "$ZSH_DEN/fzf-tab"
fi

# sourcing forgit utils in case patching is needed
source "$ZSH_DEN/forgit.zsh"
if [[ ! -e $ZSH_DEN/forgit ]]; then
    git clone --depth=1 https://github.com/wfxr/forgit.git "$ZSH_DEN/forgit"
    zden-patch-forgit
fi

# Enable Powerlevel10k instant prompt. This is after the plugin verfs.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# zden setup
source "$ZSH_DEN/aliases.zsh"
source "$ZSH_DEN/opts.zsh"
source "$ZSH_DEN/git.zsh"
source "$ZSH_DEN/fzf.zsh"
source "$ZSH_DEN/uv.zsh"

# Load plugins
source "$ZSH_DEN/fzf-tab/fzf-tab.plugin.zsh"
source "$ZSH_DEN/forgit/forgit.plugin.zsh" && PATH="$PATH:$FORGIT_INSTALL_DIR/bin"

eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export EDITOR='nvim' 


export VCPKG_ROOT=/Users/rexliu/vcpkg
export PATH=$VCPKG_ROOT:$PATH
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
