# Nushell environment initialization (managed via Home Manager)

let home = $env.HOME
let cache_dir = ($env.XDG_CACHE_HOME? | default ($home | path join ".cache"))
let config_dir = ($env.XDG_CONFIG_HOME? | default ($home | path join ".config")) | path join "nushell"

# Ensure common directories exist
mkdir $cache_dir
mkdir $config_dir

# PATH hygiene: prepend common Nix/Homebrew locations
let-env PATH = (
  [
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "$home/.nix-profile/bin"
    "$home/.local/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ]
  ++ ($env.PATH | split row (char ":"))
)

let-env EDITOR = ($env.EDITOR? | default "nvim")
let-env VISUAL = ($env.VISUAL? | default "nvim")
let-env PAGER = ($env.PAGER? | default "less")

# Starship prompt (guarded; skip silently if binary missing)
if (not (which starship | is-empty)) {
  let starship_dir = [$cache_dir "starship"] | path join
  let starship_init = [$starship_dir "init.nu"] | path join
  mkdir $starship_dir
  let starship_export = (try { starship init nu } catch {|_| "" })
  if (not ($starship_export | is-empty)) {
    $starship_export | save --force $starship_init
    source $starship_init
  }
}

# zoxide (smart cd)
if (not (which zoxide | is-empty)) {
  let zoxide_dir = [$cache_dir "zoxide"] | path join
  let zoxide_init = [$zoxide_dir "init.nu"] | path join
  mkdir $zoxide_dir
  let zoxide_export = (try { zoxide init nushell --cmd z } catch {|_| "" })
  if (not ($zoxide_export | is-empty)) {
    $zoxide_export | save --force $zoxide_init
    source $zoxide_init
  }
}

# direnv (automatic env loading)
if (not (which direnv | is-empty)) {
  let direnv_dir = [$cache_dir "direnv"] | path join
  let direnv_init = [$direnv_dir "env.nu"] | path join
  mkdir $direnv_dir
  let direnv_export = (try { direnv export nushell } catch {|_| "" })
  if (not ($direnv_export | is-empty)) {
    $direnv_export | save --force $direnv_init
    source-env $direnv_init
  }
}

# Carapace for external completions
if (not (which carapace | is-empty)) {
  let carapace_dir = [$cache_dir "carapace"] | path join
  let carapace_init = [$carapace_dir "init.nu"] | path join
  mkdir $carapace_dir
  let carapace_export = (try { carapace _carapace nushell } catch {|_| "" })
  if (not ($carapace_export | is-empty)) {
    $carapace_export | save --force $carapace_init
    source $carapace_init
  }
}
