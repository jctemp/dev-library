{pkgs, ...}: {
  packages = with pkgs; [
    gcc
    gdb
    clang-tools # Provides clangd
    gnumake
    cmake
    ninja
  ];

  language-servers = ["clangd"];
  formatters = ["clang-format"];

  env = {
    CC = "${pkgs.gcc}/bin/gcc";
    CXX = "${pkgs.gcc}/bin/g++";
  };

  shellHook = ''
    echo "C development environment ready"
    echo "  Compiler: $(gcc --version | head -n1)"
    echo "  LSP: clangd"
    echo "  Formatter: clang-format"
  '';

  vscode = {
    extensions = with pkgs.vscode-extensions; [
      llvm-vs-code-extensions.vscode-clangd
    ];
  };
}
