{ pkgs, ... }:
{
  # Database client workflows (CLI tools). Prefer project devShells for servers.
  home.packages = with pkgs; [
    postgresql    # includes psql
    pgcli
    sqlite
    litecli
    redis
    mongosh
    sqlx-cli
    kcat          # Kafka client (formerly kafkacat)
  ];
}

