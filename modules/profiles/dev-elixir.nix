{pkgs, ...}: {
  # Elixir/Erlang toolchain
  home.packages = with pkgs; [
    erlang
    elixir
    rebar3
  ];
}
