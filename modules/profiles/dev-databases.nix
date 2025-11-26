{pkgs, ...}: {
  # Database client workflows (CLI tools). Prefer project devShells for servers.
  home.packages = with pkgs; [
    postgresql # includes psql
    pgcli
    sqlite
    litecli
    redis
    mongosh
    sqlx-cli
    pkgs.stable.kcat # temporary workaround: unstable build fails with fmt 11.2.0
  ];
}
