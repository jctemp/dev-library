{pkgs, ...}: {
  packages = with pkgs; [
    nodejs
    nodePackages.npm
    nodePackages.typescript-language-server
    nodePackages.typescript
    nodePackages.prettier
    deno # Alternative runtime
  ];

  language-servers = ["typescript-language-server"];
  formatters = ["prettier"];

  env = {
    NODE_ENV = "development";
  };

  shellHook = ''
    echo "TypeScript environment ready"
    echo "  Runtime: Node.js $(node --version)"
    echo "  LSP: typescript-language-server"
    echo "  Formatter: prettier"
  '';

  vscode = {
    extensions = with pkgs.vscode-extensions; [
      esbenp.prettier-vscode
    ];
  };
}
