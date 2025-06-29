{pkgs, ...}: {
  packages = with pkgs; [
    rustc
    cargo
    clippy
    rust-src
  ];

  lsp = with pkgs; [
    rust-analyzer
  ];

  formatters = with pkgs; [
    rustfmt
  ];

  env = {
    RUST_BACKTRACE = "1";
  };

  shellHook = ''
    echo "Rust $(rustc --version) environment ready"
    echo "  LSP: rust-analyzer"
    echo "  Formatter: rustfmt"
    echo "  Linter: clippy"
  '';

  helix = {
    language-servers.rust-analyzer = {
      command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
    };

    languages = [
      {
        name = "rust";
        language-servers = ["rust-analyzer"];
        formatter = {
          command = "${pkgs.rustfmt}/bin/rustfmt";
        };
        auto-format = true;
      }
    ];
  };

  vscode = {
    settings = {
      "[rust]" = {
        "editor.defaultFormatter" = "rust-lang.rust-analyzer";
      };
    };

    extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
    ];
  };
}
