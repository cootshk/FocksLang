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
                    lux-cli = lux.lux-cli;
                };
            });
}