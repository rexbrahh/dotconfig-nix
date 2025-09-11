# Microservice Dev Template (Kind + Postgres)

This folder contains drop-in examples for a typical local microservice workflow.

- `compose.yml`: Local Postgres 16 on port 5432 (user/pass/db: postgres)
- `kind/cluster.yaml`: 1 control-plane + 2 workers Kind cluster named `dev`
- `devshell.nix`: Example project `devShell` with k8s/DB tools and handy aliases

## Usage
1. Copy this folder into your project (e.g., `.dev/`)
2. Create `flake.nix` devShell by inlining `devshell.nix` or importing it
3. Start DB: `docker compose -f .dev/compose.yml up -d`
4. Start cluster: `kind create cluster --config .dev/kind/cluster.yaml --name dev`
5. Export kubeconfig: `kind export kubeconfig --name dev --kubeconfig ~/.kube/kind-dev.conf`

