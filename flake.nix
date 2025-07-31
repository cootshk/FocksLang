{
    description = "Dev flake for FocksLang";
    nixConfig = {
        extra-substituters = "https://neorocks.cachix.org https://cootshk.cachix.org";
        extra-trusted-public-keys = "neorocks.cachix.org-1:WqMESxmVTOJX7qoBC54TwrMMoVI1xAM+7yFin8NRfwk= cootshk.cachix.org-1:yt4kcEbYvyd1Xs/H2Uw7VNOl1EjAiTdef/ZjyQY09CU=";
    };
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
        lux.url = "github:nvim-neorocks/lux";
    };
    outputs = inputs@{self, nixpkgs, flake-utils, ...}:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = import nixpkgs { inherit system; };
                deps = with pkgs; [
                    pkg-config
                    luajit
                    lux.lux-luajit
                ];
                lux = inputs.lux.packages.${system};
            in
            {
                devShells.default = pkgs.mkShell {
                    buildInputs = with pkgs; [
                        lux-cli
                        git
                    ] ++ deps;
                };
                packages = {
                    default = let 
                        src = ./.;
                      in pkgs.stdenv.mkDerivation {
                        inherit src;
                        pname = "focks";
                        version = "0.2.0";
                        nativeBuildInputs = deps;
                        buildInputs = with pkgs; [ lux-cli ] ++ deps;
                        installPhase = ''
                            mkdir -p $out
                            cp -r . $out
                            # Bin script is already in /bin/focks
                        '';
                        meta = with pkgs.lib; {
                            description = "FocksLang programming language";
                            homepage = "https://github.com/cootshk/FocksLang";
                            license = licenses.gpl3;
                        };
                    };
                    lux-cli = lux.lux-cli;
                };
            });
}