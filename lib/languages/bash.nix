{pkgs, ...}: {
  packages = with pkgs; [
    bash
    bashInteractive
    shellcheck
    shfmt
    coreutils
    findutils
    gnugrep
    gnused
    gawk
  ];

  lsp = with pkgs; [
    nodePackages.bash-language-server
  ];

  formatters = with pkgs; [
    shfmt
  ];

  env = {
    BASH_ENV = "";
    SHELLOPTS = "extglob:globstar";
  };

  shellHook = ''
    echo "Bash development environment ready"
    echo "  Shell: $BASH_VERSION"
    echo "  LSP: bash-language-server"
    echo "  Formatter: shfmt"
    echo "  Linter: shellcheck"
    echo ""
    echo "Useful commands:"
    echo "  shellcheck script.sh  - Lint shell script"
    echo "  shfmt -w script.sh    - Format shell script"
    echo "  bash -n script.sh     - Check syntax"
  '';

  helix = {
    language-servers.bash-language-server = {
      command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
      args = ["start"];
    };

    languages = [
      {
        name = "bash";
        language-servers = ["bash-language-server"];
        formatter = {
          command = "${pkgs.shfmt}/bin/shfmt";
          args = ["-i" "2" "-ci"];
        };
        auto-format = true;
      }
    ];
  };

  vscode = {
    settings = {
      "[shellscript]" = {
        "editor.defaultFormatter" = "foxundermoon.shell-format";
      };
      "[bash]" = {
        "editor.defaultFormatter" = "foxundermoon.shell-format";
      };
      "shellformat.flag" = "-i 2 -ci";
      "shellcheck.enable" = true;
    };

    extensions = with pkgs.vscode-extensions; [
      mads-hartmann.bash-ide-vscode
      foxundermoon.shell-format
      timonwong.shellcheck
    ];
  };
}
