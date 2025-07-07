{pkgs, ...}: {
  packages = with pkgs; [
    rustc
    cargo
    clippy
    rust-src
    rust-analyzer # Helix expects "rust-analyzer" command
    rustfmt
  ];

  # Helix defaults work perfectly - no overrides needed!
  language-servers = ["rust-analyzer"];
  formatters = ["rustfmt"];

  env = {
    RUST_BACKTRACE = "1";
  };

  shellHook = ''
    echo "Rust $(rustc --version) environment ready"
    echo "  LSP: rust-analyzer"
    echo "  Formatter: rustfmt"
  '';

  # No helix config needed - defaults work!

  vscode = {
    extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
    ];
  };
}
