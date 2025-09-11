{ lib, config, pkgs, ... }:
let
  cfg = config.ml.env;
  homeDir = config.home.homeDirectory or ("/Users/" + (config.home.username or ""));
  base = cfg.baseDir or ("${homeDir}/data");
in
{
  options.ml.env = {
    enable = lib.mkEnableOption "Standard ML data/cache env and directories";

    baseDir = lib.mkOption {
      type = lib.types.str;
      default = "${homeDir}/data";
      description = "Base directory for ML data/caches (e.g., ~/data).";
      example = "${homeDir}/work/ml";
    };

    setEnv = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Export common ML cache env vars (HF_HOME, HF_DATASETS_CACHE, TORCH_HOME, WANDB_DIR).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create a small directory convention under the chosen base dir.
    home.activation.mlDataDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${base}/raw" "${base}/curated" "${base}/artifacts"
      mkdir -p "${base}/cache/hf/datasets" "${base}/cache/torch" "${base}/cache/wandb"
      chmod -R go-rwx "${base}" || true
    '';

    # Keep XDG defaults; only add ML-specific caches if requested.
    home.sessionVariables = lib.mkIf cfg.setEnv {
      HF_HOME = "${base}/cache/hf";
      HF_DATASETS_CACHE = "${base}/cache/hf/datasets";
      TORCH_HOME = "${base}/cache/torch";
      WANDB_DIR = "${base}/cache/wandb";
    };

    # Having duckdb/jq globally is handy; no-op if already present.
    home.packages = with pkgs; [ duckdb jq ];
  };
}
