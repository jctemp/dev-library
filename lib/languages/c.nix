{pkgs, ...}: {
  packages = with pkgs; [
    gcc
    gdb
    gnumake
    cmake
    ninja
    glibc.dev
    pkg-config
  ];

  lsp = with pkgs; [
    clang-tools # provides clangd
  ];

  formatters = with pkgs; [
    clang-tools # provides clang-format
  ];

  env = {
    CC = "${pkgs.gcc}/bin/gcc";
    CXX = "${pkgs.gcc}/bin/g++";
    PKG_CONFIG_PATH = "${pkgs.pkg-config}/lib/pkgconfig";
  };

  shellHook = ''
    echo "C development environment ready"
    echo "  Compiler: $(gcc --version | head -n1)"
    echo "  Debugger: gdb"
    echo "  LSP: clangd"
    echo "  Formatter: clang-format"
    echo "  Build systems: make, cmake, ninja"
  '';

  helix = {
    language-servers.clangd = {
      command = "${pkgs.clang-tools}/bin/clangd";
      args = [
        "--background-index"
        "--clang-tidy"
        "--completion-style=detailed"
        "--function-arg-placeholders"
        "--header-insertion=iwyu"
      ];
    };

    languages = [
      {
        name = "c";
        language-servers = ["clangd"];
        formatter = {
          command = "${pkgs.clang-tools}/bin/clang-format";
          args = ["-style=file" "-assume-filename=%f"];
        };
        auto-format = true;
      }
    ];
  };

  vscode = {
    settings = {
      "[c]" = {
        "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
      };
      "clangd.arguments" = [
        "--background-index"
        "--clang-tidy"
        "--completion-style=detailed"
        "--function-arg-placeholders"
        "--header-insertion=iwyu"
      ];
    };

    extensions = with pkgs.vscode-extensions; [
      llvm-vs-code-extensions.vscode-clangd
      ms-vscode.cmake-tools
    ];
  };
}
