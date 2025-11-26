{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.ml.tunnels;

  mkTunnelAgent = name: localPort: remotePort: {
    path = [pkgs.autossh pkgs.openssh];
    serviceConfig = {
      ProgramArguments =
        ["${pkgs.autossh}/bin/autossh" "-M" "0" "-N"]
        ++ cfg.extraSSHFlags
        ++ [
          "-L"
          "127.0.0.1:${toString localPort}:localhost:${toString remotePort}"
          cfg.destination
        ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Background";
      StandardOutPath = "/tmp/${name}.out";
      StandardErrorPath = "/tmp/${name}.err";
    };
  };
in {
  options.ml.tunnels = {
    enable = lib.mkEnableOption "Launchd-managed SSH tunnels for ML services";

    destination = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''        SSH host alias to connect to (e.g., "gpu-box").
                Should be configured in your SSH config (username, keys, etc.).'';
      example = "gpu-box";
    };

    extraSSHFlags = lib.mkOption {
      type = with lib.types; listOf str;
      default = [
        "-o"
        "ServerAliveInterval=60"
        "-o"
        "ServerAliveCountMax=3"
        "-o"
        "ExitOnForwardFailure=yes"
        "-o"
        "StrictHostKeyChecking=yes"
        "-o"
        "UserKnownHostsFile=~/.ssh/known_hosts"
      ];
      description = "Additional ssh flags for the autossh command (flat list).";
    };

    jupyter = {
      enable = lib.mkEnableOption "Tunnel for Jupyter (localhost:8888)";
      localPort = lib.mkOption {
        type = lib.types.port;
        default = 8888;
      };
      remotePort = lib.mkOption {
        type = lib.types.port;
        default = 8888;
      };
    };

    mlflow = {
      enable = lib.mkEnableOption "Tunnel for MLflow (localhost:5000)";
      localPort = lib.mkOption {
        type = lib.types.port;
        default = 5000;
      };
      remotePort = lib.mkOption {
        type = lib.types.port;
        default = 5000;
      };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      requireDest = cfg.destination != "";
    in
      lib.mkMerge [
        {
          assertions = [
            {
              assertion = (!cfg.jupyter.enable && !cfg.mlflow.enable) || requireDest;
              message = "ml.tunnels.destination must be set when any tunnel is enabled.";
            }
          ];
        }

        (lib.mkIf cfg.jupyter.enable {
          launchd.user.agents."ssh-tunnel-jupyter" = mkTunnelAgent "ssh-tunnel-jupyter" cfg.jupyter.localPort cfg.jupyter.remotePort;
        })

        (lib.mkIf cfg.mlflow.enable {
          launchd.user.agents."ssh-tunnel-mlflow" = mkTunnelAgent "ssh-tunnel-mlflow" cfg.mlflow.localPort cfg.mlflow.remotePort;
        })
      ]
  );
}
