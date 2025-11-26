{pkgs}:
pkgs.mkShell {
  packages = with pkgs; [
    kind
    kubectl
    kubernetes-helm
    kustomize
    skaffold
    tilt
    k9s
    dive
    postgresql
    pgcli
    sqlite
    litecli
    redis
    mongosh
  ];
  shellHook = ''
    export KIND_CLUSTER_NAME=dev
    alias kind-up='kind create cluster --name "$KIND_CLUSTER_NAME" --config .dev/kind/cluster.yaml --wait 120s'
    alias kind-down='kind delete cluster --name "$KIND_CLUSTER_NAME"'
    alias kctx='kubectx'
    alias kns='kubens'
    alias k='kubectl'
    alias klogs='kubectl logs -f'
    echo "DB: docker compose -f .dev/compose.yml up -d"
  '';
}
