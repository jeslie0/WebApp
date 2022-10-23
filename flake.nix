{
  description = "My First Web App";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem ( system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        haskellPackages = pkgs.haskellPackages;
        packageName = "WebApp";
        frontendFiles = pkgs.stdenv.mkDerivation {
          pname = "frontend";
          version = "0.0.1";
          src = (import ./src/site/default.nix {pkgs = pkgs;}).package;
          buildInputs = [ pkgs.nodePackages.npm ];
          buildPhase = ''
                       cd lib/node_modules/frontend;
                       npm run build;
                       '';
          installPhase = ''
                         mkdir -p $out
                         mv build $out
                         '';
        };
      in
        {
          packages = {
            backend = haskellPackages.callCabal2nixWithOptions "Backend" src/app "" {};
            frontend = frontendFiles;
          };

          defaultPackage = self.packages.${system}.backend;

          devShells = rec {
            backend = haskellPackages.shellFor {
              packages = p: [ self.packages.${system}.backend ];
              withHoogle = true;
              buildInputs = with haskellPackages;
                [ ghc
                  haskell-language-server
                  cabal-install
                  apply-refact
                  hlint
                  stylish-haskell
                  hasktags
                  hindent
                ];
            };

            frontend = pkgs.mkShell {
              inputsFrom = [];
              buildInputs = with pkgs; [
                node2nix
                nodePackages.npm
                nodejs-18_x
                nodePackages.typescript-language-server
                nodePackages.typescript
                nodePackages.create-react-app
              ];
            };

            default = pkgs.mkShell {
              inputsFrom = [ backend frontend ];
            };
          };
        }
    );
}
