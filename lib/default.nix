{
  pkgs,
  std,
  ...
}: let
  languages = import ./languages {inherit pkgs std;};
  editors = import ./editors {inherit pkgs std;};

  mkDevShell = {
    # Name of the dev shell
    name ? "dev-shell",
    # Language configurations
    lang ? {},
    # Editor configurations
    editor ? {},
    # Shell type: "standard" or "fhs"
    shellType ? "standard",
    # Additional packages
    packages ? [],
    # Additional shell hook
    shellHook ? "",
    # Headless mode - packages only, no editor configs
    headless ? false,
    # Environment variables
    env ? {},
    ...
  }: let
    # Helper to safely get attribute values
    safeGet = attr: default: std.set.getOr default attr;

    # Get enabled languages
    enabledLangs = std.list.filter (
      name:
        (safeGet name {} lang).enable or false
    ) (std.set.keys languages);

    # Get enabled editors
    enabledEditors =
      if headless
      then []
      else
        std.list.filter (
          name:
            (safeGet name {} editor).enable or false
        ) (std.set.keys editors);

    # Collect language packages, LSPs, and formatters
    collectFromLanguages = selector:
      std.list.concatMap (
        langName: let
          langModule = languages.${langName};
          langConfig = lang.${langName} or {};
          shouldIncludeLsp = langConfig.lsp or true;
          shouldIncludeFormatter = langConfig.formatter or true;
        in
          (selector langModule)
          ++ (
            if shouldIncludeLsp
            then langModule.lsp or []
            else []
          )
          ++ (
            if shouldIncludeFormatter
            then langModule.formatters or []
            else []
          )
      )
      enabledLangs;

    # All language packages
    langPackages = collectFromLanguages (lang: lang.packages or []);

    # Editor packages (only if not headless)
    editorPackages =
      if headless
      then []
      else
        std.list.concatMap (
          editorName:
            editors.${editorName}.packages or []
        )
        enabledEditors;

    # All packages combined
    allPackages = langPackages ++ editorPackages ++ packages;

    # Collect language shell hooks
    langHooks = std.string.concatSep "\n" (std.list.map (
        langName:
          languages.${langName}.shellHook or ""
      )
      enabledLangs);

    # Generate editor configuration hooks (only if not headless)
    editorHooks =
      if headless
      then ""
      else
        std.string.concatSep "\n" (std.list.map (
            editorName: let
              editorModule = editors.${editorName};
              # Collect configurations from enabled languages for this editor
              langConfigs =
                std.list.map (
                  langName: (languages.${langName} // {name = langName;})
                )
                enabledLangs;
            in
              if std.set.getOr false "generateConfig" editorModule
              then editorModule.generateConfig langConfigs
              else ""
          )
          enabledEditors);

    # Combined shell hook
    combinedShellHook = std.string.concatSep "\n" [
      langHooks
      editorHooks
      shellHook
    ];

    # Environment variables from languages
    langEnv =
      std.list.foldl' (
        acc: langName:
          acc // (languages.${langName}.env or {})
      ) {}
      enabledLangs;

    # All environment variables
    allEnv = langEnv // env;

    # Base shell arguments
    baseArgs =
      {
        inherit name;
        packages = allPackages;
        shellHook = combinedShellHook;
      }
      // allEnv;
  in
    if shellType == "fhs"
    then
      pkgs.buildFHSEnv (baseArgs
        // {
          targetPkgs = _pkgs: allPackages;
          profile = combinedShellHook;
          runScript = "bash";
        })
    else pkgs.mkShell baseArgs;
in {
  inherit mkDevShell;
  inherit languages editors;

  # Re-export useful std functions for advanced users
  inherit std;
}
