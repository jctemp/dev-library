{pkgs, ...}: {
  packages = with pkgs; [
    nodejs
    nodePackages.npm
    nodePackages.typescript-language-server
    nodePackages.typescript
    nodePackages.prettier
  ];

  # Use the exact name from Helix defaults
  language-servers = ["typescript-language-server"];
  formatters = ["prettier"];

  env = {
    NODE_ENV = "development";
  };

  shellHook = ''
    echo "JavaScript environment ready"
    echo "  Runtime: Node.js $(node --version)"
    echo "  LSP: typescript-language-server"
    echo "  Formatter: prettier"
  '';

  # No helix config needed

  vscode = {
    extensions = with pkgs.vscode-extensions; [
      esbenp.prettier-vscode
    ];
  };
}
