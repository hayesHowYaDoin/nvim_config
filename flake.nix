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
    mkNeovim = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      vimConfig = import ./config.nix { inherit pkgs; };
    in nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [
        {
          config.vim = vimConfig;
        }
      ];
    };
  in {
    packages = {
      x86_64-linux.default = (mkNeovim "x86_64-linux").neovim;
      aarch64-linux.default = (mkNeovim "aarch64-linux").neovim;
      aarch64-darwin.default = (mkNeovim "aarch64-darwin").neovim;
    };
  };
}
