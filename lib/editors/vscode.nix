{
  pkgs,
  std,
}: {
  packages = with pkgs; [
    vscodium
  ];

  generateConfig = langConfigs: let
    # Base settings for VSCode
    baseSettings = {
      "editor.inlayHints.enabled" = "on";
      "editor.rulers" = [80 120];
      "workbench.colorTheme" = "Catppuccin Macchiato";
      "workbench.iconTheme" = "catppuccin-macchiato";
      "editor.formatOnSave" = true;
      "telemetry.telemetryLevel" = "off";
    };

    # Collect all settings from language configurations
    allSettings =
      std.list.foldl' (
        acc: langConfig:
          if std.set.getOr false "vscode" langConfig
          then acc // (langConfig.vscode.settings or {})
          else acc
      )
      baseSettings
      langConfigs;

    # Helper function to extract extension ID from package
    extractExtensionId = ext:
      if std.set.getOr false "vscodeExtUniqueId" ext
      then ext.vscodeExtUniqueId
      else if std.set.getOr false "pname" ext
      then ext.pname
      else ext.name or "unknown-extension";

    # Base extensions
    baseExtensions = [
      "catppuccin.catppuccin-vsc"
      "catppuccin.catppuccin-vsc-icons"
    ];

    # Collect all extensions from language configurations
    langExtensions =
      std.list.concatMap (
        langConfig:
          if std.set.getOr false "vscode" langConfig
          then std.list.map extractExtensionId (langConfig.vscode.extensions or [])
          else []
      )
      langConfigs;

    # All extensions combined
    allExtensions = baseExtensions ++ langExtensions;

    # Extensions configuration
    extensionsConfig = {
      recommendations = allExtensions;
    };
  in ''
        # Generate VSCode configuration
        mkdir -p .vscode

        # Generate settings.json using nix-std's toJSON
        cat > .vscode/settings.json << 'EOF'
    ${std.serde.toJSON allSettings}
    EOF

        # Generate extensions.json using nix-std's toJSON
        cat > .vscode/extensions.json << 'EOF'
    ${std.serde.toJSON extensionsConfig}
    EOF

        echo "Generated VSCode configuration in .vscode/"
        echo "Install recommended extensions by opening VSCode and running:"
        echo "  Ctrl+Shift+P → 'Extensions: Show Recommended Extensions'"
  '';
}
