let
  pkgs = import <nixpkgs> { };
in
rec {
  # tutorial to edit
  spacevecalg-nopython = pkgs.callPackage ./exercices/spacevecalg-nopython.nix {};
  spacevecalg-python = pkgs.callPackage ./exercices/spacevecalg-python.nix { inherit eigen3-to-python; };
  
  # solutions
  spacevecalg-nopython-solution = pkgs.callPackage ./solution/spacevecalg-nopython.nix {};
  spacevecalg-python-solution = pkgs.callPackage ./solution/spacevecalg-python.nix { inherit eigen3-to-python; };

  # dependencies/examples
  hello = pkgs.callPackage ./hello.nix {};
  eigen3-to-python = pkgs.callPackage ./eigen3-to-python.nix {};
}

