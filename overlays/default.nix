# Overlay entrypoint. Keep overrides minimal and focused.
# This file is imported by nixpkgs.overlays in flake.nix.
# Example (uncomment to pin a tool from the stable channel exposed as `prev.stable`):
# final: prev: {
#   # Use stable bat instead of unstable
#   # bat = prev.stable.bat;
# }
final: prev: let
  stripDotnet = pkg:
    pkg.overridePythonAttrs (old: {
      doCheck = false;
      nativeBuildInputs = let
        dropDotnet = input: let
          name = prev.lib.getName input;
        in
          !(prev.lib.hasPrefix "dotnet" name);
      in
        builtins.filter dropDotnet (old.nativeBuildInputs or []);
      nativeCheckInputs = [];
      checkInputs = [];
      pythonImportsCheck = [];
      preCheck = "";
      postCheck = old.postCheck or "";
      checkPhase = "true";
      pytestFlags = [];
      pytestFlagsArray = [];
    });
in {
  pre-commit = stripDotnet prev.pre-commit;
  python3Packages =
    prev.python3Packages
    // {
      pre-commit = stripDotnet prev.python3Packages.pre-commit;
    };
}
