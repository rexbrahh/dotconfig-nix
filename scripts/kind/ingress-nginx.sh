#!/usr/bin/env bash
set -euo pipefail

NAME="${KIND_CLUSTER_NAME:-dev}"
KNS="ingress-nginx"

kubectl get ns "$KNS" >/dev/null 2>&1 || kubectl create ns "$KNS"

kubectl apply -n "$KNS" -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Waiting for ingress-nginx controller..."
kubectl -n "$KNS" rollout status deployment/ingress-nginx-controller --timeout=120s
echo "Ingress NGINX installed."

