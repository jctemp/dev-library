{
  description = "Quick start project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixell = {
      url = "github:jctemp/nixell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixell,
    ...
  }: let
    systems = ["x86_64-linux"];
    eachSystem = systems: func: nixpkgs.lib.genAttrs systems func;
    eachDefaultSystem = eachSystem systems;
  in {
    devShells = eachDefaultSystem (system: let
      nixell-lib = nixell.lib.${system};
    in {
      default = nixell-lib.mkDevShell {
        name = "project";
        lang = {
          nix.enable = true;
          markdown.enable = true;
        };
        editor.helix.enable = true;
      };
    });
  };
}
