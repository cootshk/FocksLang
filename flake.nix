{
    description = "Dev flake for FocksLang";
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };
    outputs = inputs@{self, nixpkgs, flake-utils}:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = import nixpkgs {
                    inherit system;
                    overlays = [ (import ./overlay.nix) ];
                };
                deps = with pkgs; [
                    luajit
                    luajitPackages.lux-lua
                ];
            in
            {
                devShells.default = pkgs.mkShell {
                    buildInputs = with pkgs; [
                        lux-cli
                        git
                    ] ++ deps;
                };
            });
}