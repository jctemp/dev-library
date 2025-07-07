{pkgs, ...}: {
  packages = with pkgs; [
    vscode-langservers-extracted # provides vscode-css-language-server
    nodePackages.prettier
  ];

  language-servers = ["vscode-css-language-server"];
  formatters = ["prettier"];

  env = {};

  shellHook = ''
    echo "CSS environment ready"
    echo "  LSP: vscode-css-language-server"
    echo "  Formatter: prettier"
  '';

  vscode = {
    extensions = with pkgs.vscode-extensions; [
      esbenp.prettier-vscode
      bradlc.vscode-tailwindcss
    ];
  };
}
