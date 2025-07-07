{
  pkgs,
  std,
  ...
}: let
  languages = import ./languages {inherit pkgs std;};
  editors = import ./editors {inherit pkgs std;};

  mkDevShell = {
    name ? "dev-shell",
    lang ? {},
    editor ? {},
    shellType ? "standard",
    packages ? [],
    shellHook ? "",
    headless ? false,
    env ? {},
    ...
  }: let
    # Get enabled languages
    enabledLangs = std.list.filter (name: (lang.${name} or {}).enable or false) (
      std.set.keys languages
    );

    # Get enabled editors
    enabledEditors =
      if headless
      then []
      else std.list.filter (name: (editor.${name} or {}).enable or false) (std.set.keys editors);

    # Helper to collect packages from languages based on what's enabled
    collectFromLanguages =
      std.list.concatMap (
        langName: let
          langModule = languages.${langName};
          langConfig = lang.${langName} or {};

          # Helper to resolve package names to actual packages
          resolvePackages = pkgList:
            std.list.map (
              pkg:
                if builtins.isString pkg
                then pkgs.${pkg} or (throw "Package '${pkg}' not found in language ${langName}")
                else pkg
            )
            pkgList;
        in
          # Always include base packages
          langModule.packages
          ++
          # Include language servers unless explicitly disabled
          (
            if langConfig.lsp or langConfig.language-servers or true
            then resolvePackages (langModule.language-servers or [])
            else []
          )
          ++
          # Include formatters unless explicitly disabled
          (
            if langConfig.formatters or true
            then resolvePackages (langModule.formatters or [])
            else []
          )
      )
      enabledLangs;

    # All language packages
    langPackages = collectFromLanguages;

    # Editor packages
    editorPackages =
      if headless
      then []
      else std.list.concatMap (editorName: editors.${editorName}.packages or []) enabledEditors;

    # All packages combined
    allPackages = langPackages ++ editorPackages ++ packages;

    # Collect shell hooks from languages
    langHooks = std.string.concatSep "\n" (
      std.list.map (langName: languages.${langName}.shellHook or "") enabledLangs
    );

    # Generate editor configs (only if not headless)
    editorHooks =
      if headless
      then ""
      else
        std.string.concatSep "\n" (
          std.list.map (
            editorName: let
              editorModule = editors.${editorName};
              langConfigs = std.list.map (langName: (languages.${langName} // {name = langName;})) enabledLangs;
            in
              if builtins.hasAttr "generateConfig" editorModule
              then editorModule.generateConfig langConfigs
              else ""
          )
          enabledEditors
        );

    # Combined shell hook
    combinedShellHook = std.string.concatSep "\n\n" (
      std.list.filter (hook: hook != "") [
        langHooks
        editorHooks
        shellHook
        ''
          echo ""
          echo "Development environment ready!"
          echo "  Languages: ${std.string.concatSep ", " enabledLangs}"
          ${
            if enabledEditors != []
            then ''echo "  Editors: ${std.string.concatSep ", " enabledEditors}"''
            else ""
          }
          echo "  Package count: ${toString (builtins.length allPackages)}"
        ''
      ]
    );

    # Collect environment variables from languages
    langEnv =
      std.list.foldl' (
        acc: langName: acc // (languages.${langName}.env or {})
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
      pkgs.buildFHSEnv (
        baseArgs
        // {
          targetPkgs = _: allPackages;
          profile = combinedShellHook;
          runScript = "bash";
        }
      )
    else pkgs.mkShell baseArgs;
in {
  inherit
    mkDevShell
    languages
    editors
    std
    ;

  # Enhanced convenience functions
  mkPythonShell = args: mkDevShell (args // {lang.python.enable = true;});
  mkRustShell = args: mkDevShell (args // {lang.rust.enable = true;});
  mkWebShell = args:
    mkDevShell (
      args
      // {
        lang.typescript.enable = true;
        lang.html.enable = true;
        lang.css.enable = true;
      }
    );
  mkSystemsShell = args:
    mkDevShell (
      args
      // {
        lang.c.enable = true;
        lang.cpp.enable = true;
        lang.rust.enable = true;
        lang.zig.enable = true;
      }
    );
  mkConfigShell = args:
    mkDevShell (
      args
      // {
        lang.nix.enable = true;
        lang.toml.enable = true;
        lang.json.enable = true;
        lang.yaml.enable = true;
      }
    );
}
