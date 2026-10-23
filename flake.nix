{
  description = "daggonit - pure DAG layout for terminal renderers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        # A library crate has nothing to install; this builds it and runs
        # its tests so `nix flake check` catches a broken layout module.
        checks.default = pkgs.rustPlatform.buildRustPackage {
          pname = "daggonit";
          version = "0.1.0";
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
          installPhase = "mkdir -p $out";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.cargo
            pkgs.rustc
            pkgs.rust-analyzer
            pkgs.clippy
            pkgs.rustfmt
          ];
        };
      }
    );
}
