# This is the solution to the previous exercice spacevecalg-nopython.nix
# Now let's add python packaging here
# Let's also add doxygen for documentation
{
  stdenv, lib,
  cmake, pkg-config, jrl-cmakemodules,
  eigen, boost,
  fetchFromGitHub,
  # add python dependencies
  eigen3-to-python,
}:
stdenv.mkDerivation {
  pname = "spacevecalg"; version = "1.2.10";

  src = fetchFromGitHub {
    owner = "jrl-umi3218"; repo = "SpaceVecAlg"; tag = "v1.2.10";
    hash = "sha256-fTKKj3m8cO4F46LlO7r8JeuWLhlyRcX7EblHroDYFkQ=";
  };

  # Add doxygen dependency
  # Add python dependencies

  # needed for building
  buildInputs = [ jrl-cmakemodules pkg-config ];
  # needed for building or tools that we need in shells
  nativeBuildInputs = [ cmake ];
  # libraries and tools that need to be propagated to dependent packages
  propagatedBuildInputs = [ eigen boost ];

  # Fix cmake flags
  cmakeFlags = [
    (lib.cmakeBool "PYTHON_BINDING" false)
    (lib.cmakeBool "INSTALL_DOCUMENTATION" false)
  ];

  meta = with lib; {
    description = "Spatial Vector Algebra with the Eigen library";
    homepage = "https://github.com/jrl-umi3218/SpaceVecAlg";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
