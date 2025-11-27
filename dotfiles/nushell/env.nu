# Nushell environment initialization (managed via Home Manager)

let home = $env.HOME
let cache_dir = ($env.XDG_CACHE_HOME? | default ($home | path join ".cache"))
let config_dir = ($env.XDG_CONFIG_HOME? | default ($home | path join ".config")) | path join "nushell"

# Ensure common directories exist
mkdir $cache_dir
mkdir $config_dir

# PATH hygiene: prepend common Nix/Homebrew locations
let existing_path = (
  if ($env.PATH? | describe | str contains "list") {
    $env.PATH
  } else {
    ($env.PATH? | default "" | split row (char ":"))
  }
)
$env.PATH = [
  "/run/current-system/sw/bin"
  "/nix/var/nix/profiles/default/bin"
  "$home/.nix-profile/bin"
  "$home/.local/bin"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
] ++ $existing_path

$env.EDITOR = ($env.EDITOR? | default "nvim")
$env.VISUAL = ($env.VISUAL? | default "nvim")
$env.PAGER = ($env.PAGER? | default "less")

# Starship prompt (guarded; skip silently if binary missing)
if (not (which starship | is-empty)) {
  mkdir ~/.cache/starship
  try {
    starship init nu | save --force ~/.cache/starship/init.nu
    source ~/.cache/starship/init.nu
  } catch {|_| {}}
}

# zoxide (smart cd)
if (not (which zoxide | is-empty)) {
  mkdir ~/.cache/zoxide
  try {
    zoxide init nushell --cmd z | save --force ~/.cache/zoxide/init.nu
    source ~/.cache/zoxide/init.nu
  } catch {|_| {}}
}

# direnv (automatic env loading)
if (not (which direnv | is-empty)) {
  let direnv_export = (try { direnv export json | from json } catch {|_| {}})
  if (not ($direnv_export | is-empty)) {
    load-env $direnv_export
  }
}
