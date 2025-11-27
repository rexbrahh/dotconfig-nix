# Nushell environment initialization (managed via Home Manager)

const home = $nu.home-path
const cache_dir = ($nu.cache-dir | path dirname)  # keep general cache root, not nushell-specific child
const config_dir = $nu.default-config-dir

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
  const starship_init = [$cache_dir "starship" "init.nu"] | path join
  mkdir ($starship_init | path dirname)
  try {
    starship init nu | save --force $starship_init
  } catch {|_| {}}
  if ($starship_init | path exists) {
    try { source $starship_init } catch {|_| {}}
  }
}

# zoxide (smart cd)
if (not (which zoxide | is-empty)) {
  const zoxide_init = [$cache_dir "zoxide" "init.nu"] | path join
  mkdir ($zoxide_init | path dirname)
  try {
    zoxide init nushell --cmd z | save --force $zoxide_init
  } catch {|_| {}}
  if ($zoxide_init | path exists) {
    try { source $zoxide_init } catch {|_| {}}
  }
}

# direnv (automatic env loading)
if (not (which direnv | is-empty)) {
  let direnv_export = (try { direnv export json | from json } catch {|_| {}})
  if (not ($direnv_export | is-empty)) {
    load-env $direnv_export
  }
}
