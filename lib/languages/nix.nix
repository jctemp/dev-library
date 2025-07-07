{pkgs, ...}: {
  packages = with pkgs; [
    nix
    nix-direnv
    nixd
    nil
    alejandra
    nixpkgs-fmt
    # Enhanced Nix development tools
    nix-tree
    nix-diff
    nix-update
    nix-index
    nix-output-monitor
    nurl
    nvd
    nixpkgs-review
    # Documentation and exploration
    manix # Search Nix documentation
    nix-doc # Generate documentation for Nix expressions
  ];

  language-servers = [
    "nixd"
    "nil"
  ];
  formatters = [
    "alejandra"
    "nixpkgs-fmt"
  ];

  env = {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    # Better error messages and debugging
    NIX_SHOW_STATS = "1";
    NIX_SHOW_SYMBOLS = "1";
  };

  shellHook = ''
    echo "Enhanced Nix development environment ready"
    echo "  Nix: $(nix --version)"
    echo "  LSPs: nixd (primary), nil (fallback)"
    echo "  Formatters: alejandra (primary), nixpkgs-fmt (alternative)"
    echo "  Documentation: manix, nix-doc"
    echo "  Tools: nix-tree, nvd, nurl, nixpkgs-review"
    echo ""
    echo "Enhanced completion available for:"
    echo "  - nixpkgs packages and options"
    echo "  - home-manager options"
    echo "  - nix-std library functions"
    echo "  - local flake outputs"
    echo ""
    echo "Useful commands:"
    echo "  manix <query>            - Search Nix documentation"
    echo "  nix-tree                 - Explore dependency tree"
    echo "  nurl <url>               - Generate Nix fetcher"
    echo "  nixpkgs-review pr <num>  - Review nixpkgs PR"
  '';

  # Enhanced Helix configuration with better nixd setup
  helix = {
    language-servers.nixd = {
      command = "${pkgs.nixd}/bin/nixd";
      config = {
        nixd = {
          # Nixpkgs completion and documentation
          nixpkgs = {
            expr = "import <nixpkgs> { }";
          };
          # Format with alejandra
          formatting = {
            command = ["${pkgs.alejandra}/bin/alejandra"];
          };
          # Enhanced options completion
          options = {
            # NixOS options (if available)
            nixos = {
              expr = ''
                let
                  flake = builtins.getFlake (toString ./.);
                in
                  if flake ? nixosConfigurations
                  then (builtins.head (builtins.attrValues flake.nixosConfigurations)).options
                  else {}
              '';
            };
            # Home Manager options (if available)
            home-manager = {
              expr = ''
                let
                  flake = builtins.getFlake (toString ./.);
                in
                  if flake ? homeConfigurations
                  then (builtins.head (builtins.attrValues flake.homeConfigurations)).options
                  else {}
              '';
            };
            # Dev-library options (for this project)
            dev-library = {
              expr = ''
                let
                  flake = builtins.getFlake (toString ./.);
                in
                  flake.lib.x86_64-linux or {}
              '';
            };
          };
          # Diagnostic configuration
          diagnostic = {
            suppress = [
              "sema-escaping-with" # Reduce noise from with statements
            ];
          };
        };
      };
    };

    # Alternative nil configuration for comparison
    language-servers.nil = {
      command = "${pkgs.nil}/bin/nil";
      config = {
        nil = {
          formatting = {
            command = ["${pkgs.alejandra}/bin/alejandra"];
          };
          # Nil-specific settings
          diagnostics = {
            ignored = [
              "unused_binding"
              "unused_with"
            ];
          };
        };
      };
    };
  };

  vscode = {
    settings = {
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
        "editor.formatOnSave" = true;
        "editor.semanticHighlighting.enabled" = true;
      };
      # Enhanced Nix IDE settings
      "nix.formatterPath" = "${pkgs.alejandra}/bin/alejandra";
      "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
      "nix.enableLanguageServer" = true;
      "nix.serverSettings" = {
        nixd = {
          nixpkgs = {
            expr = "import <nixpkgs> { }";
          };
          formatting = {
            command = ["${pkgs.alejandra}/bin/alejandra"];
          };
          options = {
            nixos = {
              expr = "(builtins.getFlake \"/etc/nixos\").nixosConfigurations.HOSTNAME.options";
            };
            home-manager = {
              expr = "(builtins.getFlake \"/etc/nixos\").homeConfigurations.USERNAME.options";
            };
          };
        };
      };
      # Additional helpful settings
      "nix.enableCrashReporting" = false;
      "files.associations" = {
        "*.nix" = "nix";
        "flake.lock" = "json";
      };
    };

    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      # Additional helpful extensions
      arrterian.nix-env-selector
    ];
  };
}
