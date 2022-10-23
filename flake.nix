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
      in
        {
          packages = {
            backend = haskellPackages.callCabal2nixWithOptions "Backend" src/app "" {};
            frontend = (import ./src/site/default.nix {pkgs = pkgs;}).package;
          };

          # defaultPackage = self.packages.${system}.frontend;

          devShells = rec {
            backend = haskellPackages.shellFor {
              packages = p: [ self.packages.${system}.backend ];
              buildInputs = with haskellPackages; [ ghc
                                                    haskell-language-server
                                                    cabal-install
                                                    apply-refact
                                                    hlint
                                                    stylish-haskell
                                                    hasktags
                                                    hindent
                                                  ];

              withHoogle = true;
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

              # ((import src/site/default.nix) {inherit pkgs system; nodejs = pkgs.nodejs-18_x; }).shell;

            default = pkgs.mkShell {
              inputsFrom = [ backend frontend ];
            };
          };
        }
    );
}
