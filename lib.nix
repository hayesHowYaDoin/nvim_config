{ nvf }:
rec {
  # Helper to create theme config from a named theme (e.g., "catppuccin", "gruvbox")
  mkNamedTheme = name: style: {
    useNixColors = false;
    nixColorsScheme = null;
    inherit name style;
  };

  # Helper to create theme config from nix-colors colorscheme
  mkNixColorsTheme = colorscheme: {
    useNixColors = true;
    nixColorsScheme = colorscheme;
    # Use base16 theme with the colorscheme slug/name
    name = "base16";
    style = colorscheme.slug or "custom";
  };

  # Main function to create Neovim with custom theme
  # Parameters:
  #   - pkgs: nixpkgs instance
  #   - theme: theme name (default: "catppuccin")
  #   - style: theme style/variant (default: "mocha")
  #   - nixColorsScheme: nix-colors colorscheme (default: null)
  # If nixColorsScheme is provided, it takes precedence over theme/style
  mkNeovim =
    { pkgs
    , theme ? "catppuccin"
    , style ? "mocha"
    , nixColorsScheme ? null
    }:
    let
      themeConfig = if nixColorsScheme != null
        then mkNixColorsTheme nixColorsScheme
        else mkNamedTheme theme style;

      vimConfig = import ./config.nix { inherit pkgs themeConfig; };
    in
    nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [
        {
          config.vim = vimConfig;
        }
      ];
    };

  # Convenience function specifically for nix-colors users
  # Parameters:
  #   - pkgs: nixpkgs instance
  #   - colorscheme: nix-colors colorscheme
  mkNeovimWithColors =
    { pkgs
    , colorscheme
    }:
    mkNeovim {
      inherit pkgs;
      nixColorsScheme = colorscheme;
    };
}
