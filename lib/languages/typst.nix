{pkgs, ...}: {
  packages = with pkgs; [
    typst
    tinymist
    typstyle
  ];

  language-servers = ["tinymist"];
  formatters = ["typstyle"];

  env = {};

  shellHook = ''
    echo "Typst $(typst --version) environment ready"
    echo "  LSP: tinymist"
    echo "  Formatter: typstyle"
  '';

  vscode = {
    extensions = with pkgs.vscode-extensions; [
      myriad-dreamin.tinymist
    ];
  };
}
