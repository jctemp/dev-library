{pkgs, ...}: {
  packages = with pkgs; [
    zig
    cmake
    ninja
  ];

  lsp = with pkgs; [
    zls
  ];

  formatters = with pkgs; [
    zig # zig fmt is built into the zig binary
  ];

  env = {
    ZIG_GLOBAL_CACHE_DIR = ".zig-cache";
  };

  shellHook = ''
    echo "Zig $(zig version) environment ready"
    echo "  LSP: zls"
    echo "  Formatter: zig fmt"
    echo "  Build system: zig build"
  '';

  helix = {
    language-servers.zls = {
      command = "${pkgs.zls}/bin/zls";
    };

    languages = [
      {
        name = "zig";
        language-servers = ["zls"];
        formatter = {
          command = "${pkgs.zig}/bin/zig";
          args = ["fmt" "--stdin"];
        };
        auto-format = true;
      }
    ];
  };

  vscode = {
    settings = {
      "[zig]" = {
        "editor.defaultFormatter" = "ziglang.vscode-zig";
      };
    };

    extensions = with pkgs.vscode-extensions; [
      ziglang.vscode-zig
    ];
  };
}
