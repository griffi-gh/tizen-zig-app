{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # zig = {
    #   url = "github:mitchellh/zig-overlay";
    #   inputs = {
    #     nixpkgs.follows = "nixpkgs-stable";
    #     flake-compat.follows = "";
    #   };
    # };
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShell = pkgs.mkShell {
        packages = with pkgs; [
          zig
          zls
          mold
          llvmPackages_18.clang-unwrapped
        ];
      };
    });
}
