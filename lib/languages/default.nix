{
  pkgs,
  std,
}: {
  bash = import ./bash.nix {inherit pkgs std;};
  c = import ./c.nix {inherit pkgs std;};
  cpp = import ./cpp.nix {inherit pkgs std;};
  css = import ./css.nix {inherit pkgs std;};
  html = import ./html.nix {inherit pkgs std;};
  javascript = import ./javascript.nix {inherit pkgs std;};
  json = import ./json.nix {inherit pkgs std;};
  markdown = import ./markdown.nix {inherit pkgs std;};
  nix = import ./nix.nix {inherit pkgs std;};
  python = import ./python.nix {inherit pkgs std;};
  rust = import ./rust.nix {inherit pkgs std;};
  toml = import ./toml.nix {inherit pkgs std;};
  typescript = import ./typescript.nix {inherit pkgs std;};
  typst = import ./typst.nix {inherit pkgs std;};
  yaml = import ./yaml.nix {inherit pkgs std;};
  zig = import ./zig.nix {inherit pkgs std;};
}
