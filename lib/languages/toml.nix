{pkgs, ...}: {
  packages = with pkgs; [
    taplo
  ];

  language-servers = ["taplo"];
  formatters = ["taplo"];

  env = {};

  shellHook = ''
    echo "TOML environment ready"
    echo "  LSP: taplo"
    echo "  Formatter: taplo"
  '';

  vscode = {
    extensions = with pkgs.vscode-extensions; [
      tamasfe.even-better-toml
    ];
  };
}
