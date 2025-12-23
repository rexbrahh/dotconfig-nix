{...}: {
  # Git setup
  programs.git = {
    enable = true;
    settings = {
      user.name = "Rex Liu";
      user.email = "hi@r3x.sh";
      init.defaultBranch = "main";
      pull.ff = "only";
      push.autoSetupRemote = true;
      # Global default: GPG/OpenPGP signing
      gpg.format = "openpgp";
      commit.gpgsign = true;
      user.signingKey = "F6E1D95B5DE90338";
      # Keep SSH verification support for per-repo overrides
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
