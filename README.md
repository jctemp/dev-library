# nixell

nixell makes it trivial to create consistent, reproducible development environments with language servers, formatters, and editor configurations. Just enable the languages you need, choose your editor, and get coding!

## Features

- **Languages**: Python, Rust, JavaScript/TypeScript, C/C++, Zig, Nix, and more
- **Editor Integration**: Auto-configures Helix and VSCode
- **Zero Config**: Sensible defaults with automatic tool discovery
- **Lightweight**: Only includes what you enable

## 🏃 Quick Start

### 1. Add nixell to your flake

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixell = {
      url = "github:your-username/nixell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixell, ... }: let
    system = "x86_64-linux";
    nixell-lib = nixell.lib.${system};
  in {
    devShells.${system}.default = nixell-lib.mkDevShell {
      name = "my-project";
      
      # Enable languages
      lang = {
        python.enable = true;
        rust.enable = true;
      };
      
      # Configure editors  
      editor = {
        helix.enable = true;
        vscode.enable = true;
      };
    };
  };
}
```

### 2. Enter your development environment

```bash
nix develop
```

That's it! You now have Python and Rust with language servers, formatters, and editor configurations ready to go.

## Language Support

nixell supports these languages out of the box:

| Language | LSP | Formatter | Tools |
|----------|-----|-----------|-------|
| **Python** | `pylsp`, `ruff` | `ruff` | `uv`, `pip` |
| **Rust** | `rust-analyzer` | `rustfmt` | `cargo`, `clippy` |
| **JavaScript** | `typescript-language-server` | `prettier` | `node`, `npm` |
| **TypeScript** | `typescript-language-server` | `prettier` | `tsc`, `deno` |
| **C/C++** | `clangd` | `clang-format` | `gcc`, `cmake` |
| **Zig** | `zls` | `zig fmt` | `zig` |
| **Nix** | `nixd`, `nil` | `alejandra` | Enhanced completion |
| **Bash** | `bash-language-server` | `shfmt` | `shellcheck` |

Plus: Typst, LaTeX, Markdown, JSON, YAML, TOML, HTML, CSS, and more!

## Usage Examples

### Simple Python Environment

```nix
nixell-lib.mkDevShell {
  lang.python.enable = true;
  editor.helix.enable = true;
}
```

### Full-Stack Web Development

```nix
nixell-lib.mkDevShell {
  name = "webapp";
  lang = {
    typescript.enable = true;
    html.enable = true;
    css.enable = true;
  };
  editor.vscode.enable = true;
  packages = with pkgs; [ docker-compose ];
}
```

### Systems Programming

```nix
nixell-lib.mkDevShell {
  name = "systems";
  lang = {
    c.enable = true;
    cpp.enable = true;
    rust.enable = true;
    zig.enable = true;
  };
  editor.helix.enable = true;
  packages = with pkgs; [ gdb valgrind ];
}
```

### Headless Environment (CI/Containers)

```nix
nixell-lib.mkDevShell {
  name = "ci-environment";
  lang.python.enable = true;
  headless = true;  # No editor configurations
  packages = with pkgs; [ git gnumake ];
}
```

### FHS Environment (Complex Dependencies)

```nix
nixell-lib.mkDevShell {
  name = "ml-research";
  shellType = "fhs";  # Use buildFHSEnv
  lang.python.enable = true;
  packages = with pkgs; [ cudaPackages.cudatoolkit ];
}
```

## Editor Configuration

nixell automatically generates configuration files for your editors:

### Helix
- Creates `.helix/config.toml` with sensible defaults
- Generates `.helix/languages.toml` with LSP configurations

### VSCode
- Creates `.vscode/settings.json` with formatter configurations
- Generates `.vscode/extensions.json` with recommended extensions

## Custom packages

```nix
nixell-lib.mkDevShell {
  lang.python.enable = true;
  packages = with pkgs; [
    # Add extra packages
    postgresql
    redis
  ];
  env = {
    # Custom environment variables
    DATABASE_URL = "postgres://localhost/myapp";
  };
  shellHook = ''
    echo "Custom setup complete!"
  '';
}
```
## Contributing

1. Create `lib/languages/your-language.nix`:

```nix
{pkgs, ...}: {
  packages = with pkgs; [
    # Core packages for the language
  ];
  
  language-servers = [ "your-lsp" ];
  formatters = [ "your-formatter" ];
  
  env = {
    # Environment variables
  };
  
  shellHook = ''
    echo "Your language environment ready"
  '';
  
  # Editor configurations (optional)
  vscode.extensions = with pkgs.vscode-extensions; [ /* ... */ ];
}
```

2. Add to `lib/languages/default.nix`
3. Test and submit a PR!

## Planned extensions

- Customize default editor settings like theme
- Make languages overridable
- Add basic test to check the functionality of modules
- Build documentation

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- Built on [Nix](https://nixos.org/) and [nixpkgs](https://github.com/NixOS/nixpkgs)
- Uses [nix-std](https://github.com/chessai/nix-std) for utilities
- Inspired by the amazing Nix development community

---
