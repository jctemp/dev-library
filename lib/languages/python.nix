{pkgs, ...}: {
  packages = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.uv
    python3Packages.python-lsp-server
    python3Packages.python-lsp-ruff
    ruff
  ];

  # Use standard names - Helix will auto-discover
  language-servers = ["pylsp" "ruff"];
  formatters = ["ruff"];

  env = {
    PYTHONPATH = "$PYTHONPATH:$PWD";
    PYTHONDONTWRITEBYTECODE = "1";
  };

  shellHook = ''
    echo "Python $(python --version) environment ready"
    echo "  LSP: pylsp, ruff"
    echo "  Formatter: ruff"
    echo "  Package manager: uv"
  '';

  # Only override when we need custom config
  helix.language-servers.pylsp = {
    config.pylsp.plugins.ruff.enabled = true;
  };

  vscode = {
    settings."[python]"."editor.defaultFormatter" = "charliermarsh.ruff";
    extensions = with pkgs.vscode-extensions; [
      charliermarsh.ruff
      ms-pyright.pyright
      ms-python.python
    ];
  };
}
