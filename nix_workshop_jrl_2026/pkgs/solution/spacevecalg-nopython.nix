# spacevecalg packaging without python
{
  stdenv, lib,
  cmake, pkg-config, jrl-cmakemodules,
  eigen, boost,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "spacevecalg"; version = "1.2.10";

  src = fetchFromGitHub {
    owner = "jrl-umi3218"; repo = "SpaceVecAlg"; tag = "v1.2.10";
    hash = "sha256-fTKKj3m8cO4F46LlO7r8JeuWLhlyRcX7EblHroDYFkQ=";
  };

  buildInputs = [ jrl-cmakemodules pkg-config ];
  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ eigen boost ];

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
