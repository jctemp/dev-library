{pkgs, ...}: {
  packages = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.uv
  ];

  lsp = with pkgs; [
    python3Packages.python-lsp-server
    python3Packages.python-lsp-ruff
  ];

  formatters = with pkgs; [
    ruff
  ];

  env = {
    PYTHONPATH = "$PYTHONPATH:$PWD";
  };

  shellHook = ''
    echo "Python $(python --version) environment ready"
    echo "  LSP: pylsp with ruff integration"
    echo "  Formatter: ruff"
    echo "  Package manager: uv"
  '';

  # Editor-specific configurations
  helix = {
    language-servers.pylsp = {
      command = "${pkgs.python3Packages.python-lsp-server}/bin/pylsp";
      config.pylsp.plugins.ruff.enabled = true;
    };

    languages = [
      {
        name = "python";
        language-servers = ["pylsp"];
        formatter = {
          command = "${pkgs.ruff}/bin/ruff";
          args = ["format" "--silent" "-"];
        };
        auto-format = true;
      }
    ];
  };

  vscode = {
    settings = {
      "[python]" = {
        "editor.defaultFormatter" = "charliermarsh.ruff";
        "terminal.activateEnvironment" = true;
      };
      "python.terminal.activateEnvironment" = true;
    };

    extensions = with pkgs.vscode-extensions; [
      charliermarsh.ruff
      ms-pyright.pyright
      ms-python.python
    ];
  };
}
