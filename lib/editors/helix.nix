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
        rulers = [
          80
          120
        ];
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

    # Only collect explicit language server overrides
    # Most LSPs will be auto-discovered by Helix
    explicitLanguageServers =
      std.list.foldl' (
        acc: langConfig: let
          helixConfig = std.set.getOr null "helix" langConfig;
        in
          if helixConfig != null
          then acc // (helixConfig.language-servers or {})
          else acc
      ) {}
      langConfigs;

    # Only collect explicit language overrides
    explicitLanguages =
      std.list.concatMap (
        langConfig: let
          helixConfig = std.set.getOr null "helix" langConfig;
        in
          if helixConfig != null
          then helixConfig.languages or []
          else []
      )
      langConfigs;

    # Build languages config only if we have overrides
    languagesConfig =
      if explicitLanguageServers == {} && explicitLanguages == []
      then {}
      else {
        language-server = explicitLanguageServers;
        language = explicitLanguages;
      };
  in ''
        # Generate helix configuration
        mkdir -p .helix

        # Generate config.toml
        cat > .helix/config.toml << 'EOF'
    ${std.serde.toTOML baseConfig}
    EOF

        ${
      if languagesConfig == {}
      then ''
        # No language server overrides needed - Helix will auto-discover
        echo "# Auto-discovery enabled - no custom language config needed" > .helix/languages.toml
      ''
      else ''
              # Generate languages.toml with custom overrides
              cat > .helix/languages.toml << 'EOF'
        ${std.serde.toTOML languagesConfig}
        EOF
      ''
    }

        export HELIX_RUNTIME="${pkgs.helix}/lib/runtime"
        echo "Generated Helix configuration in .helix/"
        ${
      if languagesConfig == {}
      then ''
        echo "Using auto-discovery for language servers"
      ''
      else ''
        echo "Applied custom language server configurations"
      ''
    }
  '';
}
