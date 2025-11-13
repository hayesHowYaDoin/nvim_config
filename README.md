# Custom Neovim Configuration

A customizable Neovim configuration using [nvf](https://github.com/notashelf/nvf) with support for theme overrides and [nix-colors](https://github.com/Misterio77/nix-colors) integration.

## Features

- Declarative Neovim configuration using nvf
- Multiple ways to override the color scheme
- Full support for nix-colors integration
- Flexible API for advanced customization

## Usage Examples

### 1. Default Package

Use the default configuration with Catppuccin Mocha theme:

```nix
{
  inputs.nvim-flake.url = "github:yourusername/nvim_config";

  outputs = { nixpkgs, nvim-flake, ... }: {
    # Use the default package directly
    environment.systemPackages = [
      nvim-flake.packages.${system}.default
    ];
  };
}
```

### 2. Override with Named Theme

Override the theme using the `.override` pattern:

```nix
{
  environment.systemPackages = [
    # Use Gruvbox dark theme
    (nvim-flake.packages.${system}.default.override {
      theme = "gruvbox";
      style = "dark";
    })

    # Or use TokyoNight
    (nvim-flake.packages.${system}.default.override {
      theme = "tokyonight";
      style = "night";
    })
  ];
}
```

### 3. Override with nix-colors

Use a nix-colors colorscheme:

```nix
{
  inputs = {
    nvim-flake.url = "github:yourusername/nvim_config";
    nix-colors.url = "github:Misterio77/nix-colors";
  };

  outputs = { nixpkgs, nvim-flake, nix-colors, ... }: {
    environment.systemPackages = [
      # Use nix-colors dracula theme
      (nvim-flake.packages.${system}.default.override {
        nixColorsScheme = nix-colors.colorSchemes.dracula;
      })
    ];
  };
}
```

### 4. Advanced: Using Library Functions

For more control, use the exported library functions:

```nix
{
  inputs.nvim-flake.url = "github:yourusername/nvim_config";

  outputs = { nixpkgs, nvim-flake, ... }:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # Option A: Use mkNeovim for full control
    environment.systemPackages = [
      (nvim-flake.lib.mkNeovim {
        inherit pkgs;
        theme = "nord";
        style = "";
      }).neovim
    ];

    # Option B: Use mkNeovimWithColors for nix-colors
    home.packages = [
      (nvim-flake.lib.mkNeovimWithColors {
        inherit pkgs;
        colorscheme = inputs.nix-colors.colorSchemes.nord;
      }).neovim
    ];
  };
}
```

### 5. Home Manager Integration

Use with Home Manager:

```nix
{
  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nvim-flake.url = "github:yourusername/nvim_config";
    nix-colors.url = "github:Misterio77/nix-colors";
  };

  outputs = { home-manager, nvim-flake, nix-colors, ... }: {
    homeConfigurations."user" = home-manager.lib.homeManagerConfiguration {
      # ...
      modules = [
        ({ pkgs, ... }: {
          # Option 1: Use with nix-colors from your home-manager setup
          colorScheme = nix-colors.colorSchemes.catppuccin-mocha;

          home.packages = [
            (nvim-flake.packages.${system}.default.override {
              nixColorsScheme = config.colorScheme;
            })
          ];

          # Option 2: Or use a named theme
          home.packages = [
            (nvim-flake.packages.${system}.default.override {
              theme = "gruvbox";
              style = "dark";
            })
          ];
        })
      ];
    };
  };
}
```

## Supported Themes

Any theme supported by nvf can be used with the `theme` parameter. Popular options include:

- `catppuccin` (styles: latte, frappe, macchiato, mocha)
- `gruvbox` (styles: dark, light)
- `tokyonight` (styles: night, storm, day)
- `nord`
- `dracula`
- `onedark`
- And many more...

When using nix-colors, the colorscheme is automatically converted to base16 format and applied.

## API Reference

### `packages.${system}.default`

The default Neovim package with Catppuccin Mocha theme. Can be overridden with:

- `theme` (string): Theme name (default: "catppuccin")
- `style` (string): Theme variant/style (default: "mocha")
- `nixColorsScheme` (attrset): nix-colors colorscheme (default: null)

### `lib.mkNeovim`

Main function to create a Neovim package.

**Parameters:**
- `pkgs` (required): nixpkgs instance
- `theme` (optional): Theme name (default: "catppuccin")
- `style` (optional): Theme style (default: "mocha")
- `nixColorsScheme` (optional): nix-colors colorscheme (default: null)

**Returns:** nvf neovimConfiguration output (use `.neovim` to get the package)

### `lib.mkNeovimWithColors`

Convenience function for nix-colors integration.

**Parameters:**
- `pkgs` (required): nixpkgs instance
- `colorscheme` (required): nix-colors colorscheme

**Returns:** nvf neovimConfiguration output (use `.neovim` to get the package)

## Configuration

The main configuration is in `config.nix`, which uses nvf's declarative module system. The theme is automatically configured based on the parameters provided.

## Building Locally

```bash
# Build with default theme
nix build

# Check flake
nix flake check

# Run directly
nix run
```

## License

See [LICENSE](LICENSE) file for details.
