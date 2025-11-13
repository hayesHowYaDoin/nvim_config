{
  description = "Custom Neovim configuration using nvf";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = {
    self,
    nixpkgs,
    nvf,
    ...
  }: let
    # Import our library functions
    libFunctions = import ./lib.nix { inherit nvf; };

    # Supported systems
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

    # Helper to run a function for each system
    forAllSystems = nixpkgs.lib.genAttrs systems;

    # Create overridable Neovim package for a given system
    mkDefaultPackage = system: let
      pkgs = nixpkgs.legacyPackages.${system};

      # Create base Neovim with default theme (catppuccin-mocha)
      baseNeovim = libFunctions.mkNeovim {
        inherit pkgs;
        # Defaults are set in lib.nix
      };
    in
      # Make it overridable so users can do .override { theme = "gruvbox"; }
      pkgs.lib.makeOverridable
        ({ theme ? "catppuccin"
         , style ? "mocha"
         , nixColorsScheme ? null
         }: (libFunctions.mkNeovim {
             inherit pkgs theme style nixColorsScheme;
           }).neovim)
        { }; # Default arguments (use defaults from mkNeovim)

  in {
    # Expose library functions for advanced usage
    lib = {
      inherit (libFunctions) mkNeovim mkNeovimWithColors;
    };

    # Provide default packages for each system
    packages = forAllSystems (system: {
      default = mkDefaultPackage system;
    });
  };
}
