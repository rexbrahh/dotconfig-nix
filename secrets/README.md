Secrets scaffold (agenix)

This repository is set up to use agenix for declarative secrets.

Quick start
- Generate an age keypair (keep the private key outside the repo):
  - macOS Keychain friendly: `age-keygen -o ~/.age/keys.txt` (will print public line)
- Put recipient public keys in `secrets/age-recipients.txt`.
- Encrypt a secret: `agenix -e secrets/example.age -i ~/.age/keys.txt -r secrets/age-recipients.txt`.
- Reference it from a module (darwin or HM) via `age.secrets`.

Example module snippet
```
{
  age.secrets.example = {
    file = ./secrets/example.age;
    path = "/Users/rexliu/.config/secrets/example";
    mode = "0600";  # owner read/write
    owner = "rexliu";
    group = "staff";
  };
}
```

Notes
- Do not commit private keys. Only commit `*.age` ciphertext and recipients.
- For Home Manager, add the snippet under `home-manager.users.<name>.imports` or merge into an HM module.

Alternative: sops-nix
- If you prefer SOPS (YAML/TOML/JSON), add the input:
  - `sops-nix.url = "github:Mic92/sops-nix";`
- Import `sops-nix.darwinModules.sops` and configure `sops.secrets.<name>` like:
```
{
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.age.keyFile = "~/.age/keys.txt";
  sops.secrets.my_token = { path = "/Users/rexliu/.config/secrets/my_token"; };
}
```
