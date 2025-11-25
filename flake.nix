{
  description = "Custom Neovim configuration using nvf";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = {
    nixpkgs,
    nvf,
    ...
  }: let
    # Helper function to convert nix-colors colorscheme to nvf theme config
    nixColorsToThemeConfig = colorscheme: {
      enable = true;
      name = "base16";
      style = colorscheme.slug;
      base16-colors = with colorscheme.palette; {
        base00 = "#${base00}";
        base01 = "#${base01}";
        base02 = "#${base02}";
        base03 = "#${base03}";
        base04 = "#${base04}";
        base05 = "#${base05}";
        base06 = "#${base06}";
        base07 = "#${base07}";
        base08 = "#${base08}";
        base09 = "#${base09}";
        base0A = "#${base0A}";
        base0B = "#${base0B}";
        base0C = "#${base0C}";
        base0D = "#${base0D}";
        base0E = "#${base0E}";
        base0F = "#${base0F}";
      };
    };

    # Build neovim with optional theme configuration and colorscheme
    mkNeovim = system: themeConfig: colorScheme: transparentBackground: obsidianConfig: let
      pkgs = nixpkgs.legacyPackages.${system};
      vimConfig = import ./config.nix {
        inherit pkgs themeConfig transparentBackground obsidianConfig;
      };
      # Generate base16 vim globals from nix-colors if colorscheme is provided
      base16Globals =
        if colorScheme != null
        then
          pkgs.lib.mapAttrs' (
            name: value:
              pkgs.lib.nameValuePair "base16_${name}" "#${value}"
          )
          colorScheme.palette
        else {};
    in
      nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [
          {
            config.vim =
              vimConfig
              // {
                globals = vimConfig.globals // base16Globals;
              };
          }
        ];
      };

    # Default theme config (Catppuccin Mocha)
    defaultThemeConfig = {
      enable = true;
      name = "catppuccin";
      style = "mocha";
    };

    # Default obsidian config (disabled)
    defaultObsidianConfig = null;
  in {
    packages = {
      x86_64-linux.default = (mkNeovim "x86_64-linux" defaultThemeConfig null false defaultObsidianConfig).neovim;
      aarch64-linux.default = (mkNeovim "aarch64-linux" defaultThemeConfig null false defaultObsidianConfig).neovim;
      aarch64-darwin.default = (mkNeovim "aarch64-darwin" defaultThemeConfig null false defaultObsidianConfig).neovim;
    };

    homeManagerModules.default = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.programs.nvim_config;
      system = pkgs.system;
    in {
      options.programs.nvim_config = {
        enable = lib.mkEnableOption "custom Neovim configuration";

        theme = lib.mkOption {
          type = lib.types.nullOr (lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                description = ''
                  Theme name. Supported nvf built-in themes:
                  catppuccin, gruvbox, dracula, tokyonight, onedark, rose-pine,
                  nord, oxocarbon, github, solarized, everforest, etc.

                  Custom themes (via extraPlugins): gruvbox-material
                '';
              };
              style = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = ''
                  Theme style/variant. Examples:
                  - catppuccin: mocha, latte, frappe, macchiato
                  - gruvbox: dark, light
                  - gruvbox-material: hard, medium, soft
                  - tokyonight: night, storm, day, moon
                '';
              };
            };
          });
          default = null;
          description = ''
            Built-in nvim theme configuration.
            Takes precedence over colorScheme if both are set.

            For nvf built-in themes, these are applied via nvf's theme system.
            For custom themes (like gruvbox-material), they're handled via extraPlugins.
          '';
          example = lib.literalExpression ''{ name = "gruvbox-material"; style = "medium"; }'';
        };

        colorScheme = lib.mkOption {
          type = lib.types.nullOr lib.types.attrs;
          default = null;
          description = ''
            nix-colors colorscheme to use for Neovim.
            If null and theme is null, defaults to Catppuccin Mocha theme.
            Pass config.colorScheme when using nix-colors.
          '';
          example = lib.literalExpression "config.colorScheme";
        };

        transparentBackground = lib.mkEnableOption "transparent background for Neovim";

        obsidian = lib.mkOption {
          type = lib.types.nullOr (lib.types.submodule {
            options = {
              vaultPath = lib.mkOption {
                type = lib.types.str;
                default = "~/notes";
                description = "Path to your Obsidian vault";
                example = "~/Documents/obsidian-vault";
              };

              dailyNotesFolder = lib.mkOption {
                type = lib.types.str;
                default = "daily";
                description = "Folder for daily notes within your vault";
                example = "journal/daily";
              };

              templatesFolder = lib.mkOption {
                type = lib.types.str;
                default = "templates";
                description = "Folder for note templates within your vault";
                example = "templates";
              };
            };
          });
          default = null;
          description = "Obsidian.nvim configuration. Set to null to disable, or provide configuration to enable.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = let
          themeConfig =
            if cfg.theme != null
            then {
              enable = true;
              inherit (cfg.theme) name style;
            }
            else if cfg.colorScheme != null
            then nixColorsToThemeConfig cfg.colorScheme
            else defaultThemeConfig;
          colorScheme = cfg.colorScheme;
          obsidianConfig =
            if cfg.obsidian != null
            then cfg.obsidian
            else null;
        in [
          (mkNeovim system themeConfig colorScheme cfg.transparentBackground obsidianConfig).neovim
        ];
      };
    };
  };
}
