{pkgs, ...}: let
  cConfig = import ./c.nix {inherit pkgs;};
in {
  packages = cConfig.packages ++ (with pkgs; [boost catch2]);
  inherit (cConfig) language-servers formatters;

  env =
    cConfig.env
    // {
      CXXFLAGS = "-std=c++20";
    };

  shellHook = ''
    echo "C++ development environment ready"
    echo "  Compiler: $(g++ --version | head -n1)"
    echo "  Standard: C++20"
    echo "  LSP: clangd"
  '';

  inherit (cConfig) vscode;
}
