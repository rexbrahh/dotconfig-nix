{ pkgs, ... }:
{
  # Container + Kubernetes dev workflow tools (CLI only; use Orbstack/Colima/Podman via Homebrew for engines)
  home.packages = with pkgs; [
    # Kubernetes
    kubectl
    k9s
    kubernetes-helm
    kustomize
    kubectx         # also provides `kubens`
    stern
    kind
    skaffold
    tilt

    # Container tooling
    dive
  ];
}
