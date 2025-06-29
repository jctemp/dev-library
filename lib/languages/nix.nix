{pkgs, ...}: {
  packages = with pkgs; [
    nix
    nix-direnv
    # Nix development tools
    nix-tree
    nix-diff
    nix-update
    nix-index
  ];

  lsp = with pkgs; [
    nixd
  ];

  formatters = with pkgs; [
    alejandra
  ];

  env = {
    # Enable experimental features commonly used in development
    NIX_CONFIG = "experimental-features = nix-command flakes";
  };

  shellHook = ''
    echo "Nix development environment ready"
    echo "  Nix: $(nix --version)"
    echo "  LSP: nixd"
    echo "  Formatter: alejandra"
    echo "  Tools: nix-tree, nix-diff, nix-update, nix-index"
    echo ""
    echo "Useful commands:"
    echo "  nix develop       - Enter dev shell"
    echo "  nix build         - Build current flake"
    echo "  nix flake update  - Update flake inputs"
    echo "  nix-tree          - Explore dependency tree"
  '';

  helix = {
    language-servers.nixd = {
      command = "${pkgs.nixd}/bin/nixd";
    };

    languages = [
      {
        name = "nix";
        language-servers = ["nixd"];
        formatter = {
          command = "${pkgs.alejandra}/bin/alejandra";
        };
        auto-format = true;
      }
    ];
  };

  vscode = {
    settings = {
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };
      "nix.formatterPath" = "${pkgs.alejandra}/bin/alejandra";
      "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
      "nix.enableLanguageServer" = true;
    };

    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
    ];
  };
}
