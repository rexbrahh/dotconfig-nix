# Nushell configuration (managed via Home Manager)

let cache_dir = ($env.XDG_CACHE_HOME? | default ($env.HOME | path join ".cache"))

# Re-run direnv on directory changes so `.envrc` files are applied automatically.
let direnv_hook = {||
  if (which direnv | is-empty) {
    return
  }

  let direnv_export = (try { direnv export json | from json } catch {|_| {}})
  if (not ($direnv_export | is-empty)) {
    load-env $direnv_export
  }
}

# External completer via carapace (falls back to built-in completion if absent).
let carapace_completer = {|spans|
  let bin = (which carapace | get 0.path? | default "")
  if ($bin | is-empty) {
    []
  } else {
    ^$bin $spans | from json
  }
}

$env.config = {
  show_banner: false
  edit_mode: vi
  completions: {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "fuzzy"
    external: {
      enable: true
      completer: $carapace_completer
    }
  }
  history: {
    max_size: 50000
    sync_on_enter: true
    file_format: "plaintext"
  }
  hooks: {
    env_change: {
      PWD: [ $direnv_hook ]
    }
  }
  menus: {
    completion_menu: { max_display_size: 10 placement: "cursor" }
  }
  table: {
    mode: "rounded"
    index_mode: "always"
  }
  color_config: {
    shape_block: "light_blue"
    shape_external: "yellow"
    shape_string: "green"
  }
}

# Aliases to mirror other shells
alias ls = eza --color=auto --group-directories-first
alias ll = eza -lah --color=auto --group-directories-first
alias la = eza -la --color=auto --group-directories-first
alias cat = bat --style=plain --paging=never
alias gs = git status -sb
alias gl = git pull --ff-only
alias gp = git push
alias nrs = darwin-rebuild switch --flake ~/.config/nix
alias hm = home-manager
alias k = kubectl
alias kctx = kubectx
alias kns = kubens
alias llm = llm

def --env mkcd [dir: string] {
  mkdir $dir
  cd $dir
}

def --env take [dir: string] {
  mkcd $dir
}
