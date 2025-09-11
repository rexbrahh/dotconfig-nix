#!/usr/bin/env bash
set -euo pipefail

NAME="${KIND_CLUSTER_NAME:-dev}"
REG_NAME=${REG_NAME:-kind-registry}
REG_PORT=${REG_PORT:-5001}

# create registry container unless it already exists
if [ "$(docker inspect -f '{{.State.Running}}' $REG_NAME 2>/dev/null || true)" != 'true' ]; then
  docker run -d --restart=always -p "127.0.0.1:${REG_PORT}:5000" --name "$REG_NAME" registry:2
fi

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${REG_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

echo "Local registry on localhost:${REG_PORT} ready. Tag/push images to localhost:${REG_PORT}/<name>."

