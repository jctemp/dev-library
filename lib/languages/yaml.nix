{pkgs, ...}: {
  packages = with pkgs; [
    yaml-language-server
    nodePackages.prettier
    yq
  ];

  language-servers = ["yaml-language-server"];
  formatters = ["prettier"];

  env = {};

  shellHook = ''
    echo "YAML environment ready"
    echo "  LSP: yaml-language-server"
    echo "  Formatter: prettier"
  '';

  vscode = {
    extensions = with pkgs.vscode-extensions; [
      redhat.vscode-yaml
    ];
  };
}
