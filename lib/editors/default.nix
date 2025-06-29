{
  pkgs,
  std,
}: {
  helix = import ./helix.nix {inherit pkgs std;};
  vscode = import ./vscode.nix {inherit pkgs std;};
}
