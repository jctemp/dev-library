{pkgs, ...}: {
  packages = with pkgs; [
    bash
    bashInteractive
    nodePackages.bash-language-server
    shellcheck
    shfmt
  ];

  language-servers = ["bash-language-server"];
  formatters = ["shfmt"];

  env = {
    BASH_ENV = "";
    SHELLOPTS = "extglob:globstar";
  };

  shellHook = ''
    echo "Bash development environment ready"
    echo "  LSP: bash-language-server"
    echo "  Formatter: shfmt"
    echo "  Linter: shellcheck"
  '';

  vscode = {
    settings = {
      "[shellscript]"."editor.defaultFormatter" = "foxundermoon.shell-format";
      "[bash]"."editor.defaultFormatter" = "foxundermoon.shell-format";
    };
    extensions = with pkgs.vscode-extensions; [
      mads-hartmann.bash-ide-vscode
      foxundermoon.shell-format
      timonwong.shellcheck
    ];
  };
}
