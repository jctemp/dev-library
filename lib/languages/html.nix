{pkgs, ...}: {
  packages = with pkgs; [
    vscode-langservers-extracted # provides vscode-html-language-server
    nodePackages.prettier
  ];

  language-servers = ["vscode-html-language-server"];
  formatters = ["prettier"];

  env = {};

  shellHook = ''
    echo "HTML environment ready"
    echo "  LSP: vscode-html-language-server"
    echo "  Formatter: prettier"
  '';

  vscode = {
    extensions = with pkgs.vscode-extensions; [
      esbenp.prettier-vscode
    ];
  };
}
