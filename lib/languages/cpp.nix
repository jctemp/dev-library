{
  pkgs,
  std,
  ...
}: let
  # Import the C configuration to extend it
  cConfig = import ./c.nix {inherit pkgs std;};
in {
  # Extend C packages with C++ specific tools
  packages =
    cConfig.packages
    ++ (with pkgs; [
      # Additional C++ specific tools
      boost
      catch2
    ]);

  # Same LSP as C (clangd handles both)
  inherit (cConfig) lsp;

  # Same formatters as C
  inherit (cConfig) formatters;

  # Extend C environment with C++ specifics
  env =
    cConfig.env
    // {
      CXXFLAGS = "-std=c++20";
    };

  shellHook = ''
    echo "C++ development environment ready"
    echo "  Compiler: $(g++ --version | head -n1)"
    echo "  Standard: C++20"
    echo "  Debugger: gdb"
    echo "  LSP: clangd"
    echo "  Formatter: clang-format"
    echo "  Build systems: make, cmake, ninja"
    echo "  Libraries: boost, catch2"
  '';

  helix = {
    language-servers.clangd = cConfig.helix.language-servers.clangd;

    languages = [
      {
        name = "cpp";
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
    settings =
      cConfig.vscode.settings
      // {
        "[cpp]" = {
          "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
        };
      };

    # Same extensions as C since clangd handles both
    inherit (cConfig.vscode) extensions;
  };
}
