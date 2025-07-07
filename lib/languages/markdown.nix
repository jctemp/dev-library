{pkgs, ...}: {
  packages = with pkgs; [
    marksman
    nodePackages.prettier
    pandoc
    glow
  ];

  language-servers = ["marksman"];
  formatters = ["prettier"];

  env = {};

  shellHook = ''
    echo "Markdown environment ready"
    echo "  LSP: marksman"
    echo "  Formatter: prettier"
    echo "  Viewer: glow"
  '';

  vscode = {
    extensions = with pkgs.vscode-extensions; [
      yzhang.markdown-all-in-one
      esbenp.prettier-vscode
    ];
  };
}
