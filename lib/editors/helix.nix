{
  pkgs,
  std,
}: {
  packages = with pkgs; [
    helix
  ];

  generateConfig = langConfigs: let
    # Base configuration for Helix
    baseConfig = {
      theme = "catppuccin_macchiato";
      editor = {
        line-number = "absolute";
        true-color = true;
        rulers = [80 120];
        color-modes = true;
        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "error";
          other-lines = "disable";
        };
        indent-guides = {
          character = "╎";
          render = true;
        };
        lsp = {
          enable = true;
          display-messages = true;
          display-inlay-hints = true;
        };
      };
    };

    # Collect all language servers from enabled languages
    allLanguageServers =
      std.list.foldl' (
        acc: langConfig:
          if std.set.getOr false "helix" langConfig
          then let
            helixConfig = langConfig.helix;
          in
            acc // (helixConfig.language-servers or {})
          else acc
      ) {}
      langConfigs;

    # Collect all language configurations
    allLanguages =
      std.list.concatMap (
        langConfig:
          if std.set.getOr false "helix" langConfig
          then let
            helixConfig = langConfig.helix;
          in
            helixConfig.languages or []
          else []
      )
      langConfigs;

    # Build the complete languages configuration
    languagesConfig = {
      language-server = allLanguageServers;
      language = allLanguages;
    };
  in ''
        # Generate helix configuration
        mkdir -p .helix

        # Generate config.toml using nix-std's toTOML
        cat > .helix/config.toml << 'EOF'
    ${std.serde.toTOML baseConfig}
    EOF

        # Generate languages.toml using nix-std's toTOML
        cat > .helix/languages.toml << 'EOF'
    ${std.serde.toTOML languagesConfig}
    EOF

        export HELIX_RUNTIME="${pkgs.helix}/lib/runtime"
        echo "Generated Helix configuration in .helix/"
  '';
}
