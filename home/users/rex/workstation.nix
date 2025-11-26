{lib, ...}: {
  imports = [
    ../../../modules/home.nix
    ../../../modules/dotfiles/default.nix
    ../../../modules/profiles/dev-cpp.nix
    ../../../modules/profiles/dev-zig.nix
    ../../../modules/profiles/dev-rust.nix
    ../../../modules/profiles/dev-go.nix
    ../../../modules/profiles/dev-node.nix
    ../../../modules/profiles/dev-python.nix
    ../../../modules/profiles/dev-java.nix
    ../../../modules/profiles/dev-kotlin.nix
    ../../../modules/profiles/dev-php.nix
    ../../../modules/profiles/dev-ruby.nix
    ../../../modules/profiles/dev-elixir.nix
    ../../../modules/profiles/dev-containers.nix
    ../../../modules/profiles/dev-databases.nix
    ../../../modules/profiles/dev-vm.nix
    ../../../modules/onepassword.nix
    ../../../modules/profiles/dev-ml.nix
    ../../../modules/ml-env.nix
    ../../../modules/ml-remote.nix
  ];

  onepassword = {
    enable = true;
    sshAgent.enable = true;
  };

  ml.env.enable = true;
  ml.remote.enable = true;
}
