# Overlays

This directory lets you add small package overrides without forking nixpkgs.

- Entry file: `overlays/default.nix` (overlay function: `final: prev: { ... }`).
- Your flake exposes `pkgs.stable` (default) and `pkgs.unstable` (selective newer packages).
  You can reuse either inside the overlay (e.g., `prev.unstable.bat`).

Examples
- Prefer a stable package:
```
final: prev: {
  bat = prev.stable.bat;
}
```
- Prefer an unstable package:
```
final: prev: {
  bat = prev.unstable.bat;
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
