{pkgs, ...}: {
  packages = with pkgs; [
    zig
    zls
  ];

  language-servers = ["zls"];
  formatters = ["zig"]; # zig fmt

  env = {};

  shellHook = ''
    echo "Zig $(zig version) environment ready"
    echo "  LSP: zls"
    echo "  Formatter: zig fmt"
  '';

  vscode = {
    extensions = with pkgs.vscode-extensions; [
      ziglang.vscode-zig
    ];
  };
}
