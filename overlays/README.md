# Overlays

This directory lets you add small package overrides without forking nixpkgs.

- Entry file: `overlays/default.nix` (overlay function: `final: prev: { ... }`).
- Your flake exposes a stable channel as `pkgs.stable` already. You can reuse
  stable packages inside the overlay (e.g., `prev.stable.bat`).

Examples
- Prefer a stable package:
```
final: prev: {
  bat = prev.stable.bat;
}
```
- Patch a package (apply a simple sed):
```
final: prev: {
  mytool = prev.mytool.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      sed -i 's/foo/bar/g' src/main.rs
    '';
  });
}
```

Note: Keep overlays small and intentional. For project-specific hacks, use a
project flake overlay instead of the system overlay.

