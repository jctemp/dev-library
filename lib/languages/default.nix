{
  pkgs,
  std,
}: {
  python = import ./python.nix {inherit pkgs std;};
  rust = import ./rust.nix {inherit pkgs std;};
  zig = import ./zig.nix {inherit pkgs std;};
  c = import ./c.nix {inherit pkgs std;};
  nix = import ./nix.nix {inherit pkgs std;};
  bash = import ./bash.nix {inherit pkgs std;};
}
