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

    # Collect settings from language configurations
    allSettings =
      std.list.foldl' (
        acc: langConfig:
          if std.set.getOr false "vscode" langConfig
          then acc // (langConfig.vscode.settings or {})
          else acc
      )
      baseSettings
      langConfigs;

    # Helper to extract extension ID from package
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

    # Collect extensions from language configurations
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

        # Generate settings.json
        cat > .vscode/settings.json << 'EOF'
    ${std.serde.toJSON allSettings}
    EOF

        # Generate extensions.json
        cat > .vscode/extensions.json << 'EOF'
    ${std.serde.toJSON extensionsConfig}
    EOF

        echo "Generated VSCode configuration in .vscode/"
        echo "Language servers will be auto-discovered from PATH"
        echo "Install recommended extensions via Command Palette: 'Extensions: Show Recommended Extensions'"
  '';
}
