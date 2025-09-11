#!/usr/bin/env bash
set -euo pipefail

NAME="${1:-${KIND_CLUSTER_NAME:-dev}}"
OUT="$HOME/.kube/kind-$NAME.conf"

if ! command -v kind >/dev/null; then
  echo "kind not found; enter 'nix develop .#k8s' or install kind"
  exit 1
fi

mkdir -p "$(dirname "$OUT")"
kind export kubeconfig --name "$NAME" --kubeconfig "$OUT"
echo "Exported kubeconfig to $OUT"
echo "export KUBECONFIG=$OUT"

