{
  description = "Development environment library with language and editor support";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-std.url = "github:chessai/nix-std";
  };

  outputs = inputs: let
    systems = ["x86_64-linux"];
    eachSystem = systems: func: inputs.nixpkgs.lib.genAttrs systems func;
    eachDefaultSystem = eachSystem systems;
  in {
    # Export the library for use in other flakes
    lib = eachDefaultSystem (
      system: let
        pkgs = import inputs.nixpkgs {inherit system;};
        std = inputs.nix-std.lib;
      in
        import ./lib {inherit pkgs system std;}
    );

    # Formatter for this project
    formatter = eachDefaultSystem (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);

    # Basic templates for quick project setup
    templates = {
      default = {
        path = ./templates/native;
        description = "A basic project setup for developing transparently";
      };
      fhs = {
        path = ./templates/fhs;
        description = "A basic project setup for developing in a fhs environment";
      };
    };

    # Development shell for working on the library itself
    devShells = eachDefaultSystem (
      system: let
        pkgs = import inputs.nixpkgs {inherit system;};
        devLib = import ./lib {
          inherit pkgs system;
          std = inputs.nix-std.lib;
        };
      in {
        default = devLib.mkDevShell {
          name = "nixell-dev";
          lang = {
            nix.enable = true;
            markdown.enable = true;
          };
          editor.helix.enable = true;
          packages = with pkgs; [
            # Additional development tools
            statix
            deadnix
            # Documentation and exploration
            manix
            # Flake management
            flake-checker
          ];
          env = {
            NIXD_FLAGS = "--semantic-tokens";
          };
          shellHook = ''
            mkdir -p .logs
            export NIX_LOG_DIR="$PDW/.logs"
            echo "Dev Library development environment"
            echo "Use 'alejandra .' to format nix files"
            echo "Use 'statix check .' to lint nix files"
            echo "Use 'deadnix .' to find dead code"
          '';
        };
      }
    );
  };
}
