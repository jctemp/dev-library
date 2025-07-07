{pkgs, ...}: {
  packages = with pkgs; [
    vscode-langservers-extracted # provides vscode-json-language-server
    jq
    jless
    nodePackages.prettier
  ];

  language-servers = ["vscode-json-language-server"];
  formatters = ["prettier" "jq"];

  env = {};

  shellHook = ''
    echo "JSON environment ready"
    echo "  LSP: vscode-json-language-server"
    echo "  Formatters: prettier, jq"
  '';

  # JSON support mostly built-in to editors
}
