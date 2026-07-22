{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = [
    (import ./default.nix).spacevecalg-python-solution
  ];
}
