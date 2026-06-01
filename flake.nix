{
  description = "Nix flake for the Pi coding agent";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        rec {
          pi = pkgs.callPackage ./package.nix { };
          default = pi;
        });

      apps = forAllSystems (system: {
        pi = {
          type = "app";
          program = "${self.packages.${system}.pi}/bin/pi";
          meta.description = "Run the Pi coding agent";
        };
        default = self.apps.${system}.pi;
      });

      overlays.default = final: prev: {
        pi = final.callPackage ./package.nix { };
      };
    };
}
