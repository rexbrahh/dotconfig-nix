#!/usr/bin/env bash
set -euo pipefail

NAME="${KIND_CLUSTER_NAME:-dev}"
kind delete cluster --name "$NAME" || true

