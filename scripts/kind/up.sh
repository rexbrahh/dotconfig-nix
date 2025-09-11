#!/usr/bin/env bash
set -euo pipefail

NAME="${KIND_CLUSTER_NAME:-dev}"
CONF_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v kind >/dev/null; then
  echo "kind not found; enter 'nix develop .#k8s' or install kind"
  exit 1
fi

kind create cluster --name "$NAME" --config "$CONF_DIR/cluster.yaml" --wait 120s
echo "Cluster '$NAME' is up. Use '$(dirname "$CONF_DIR")/kubeconfig.sh' to export KUBECONFIG."

