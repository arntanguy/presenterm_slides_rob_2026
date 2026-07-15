{
  stdenv, lib,  fetchFromGitHub,
  cmake, pkg-config, jrl-cmakemodules,
  eigen, boost,
  doxygen,
  python3Packages,
  eigen3-to-python,
  with-python ? true,
}:
let 
  use-python = with-python && !stdenv.hostPlatform.isDarwin;
in
stdenv.mkDerivation {
  pname = "spacevecalg"; version = "1.2.10";
  src = fetchFromGitHub {
    owner = "jrl-umi3218"; repo = "SpaceVecAlg"; tag = "v1.2.10";
    hash = "sha256-fTKKj3m8cO4F46LlO7r8JeuWLhlyRcX7EblHroDYFkQ=";
  };

  buildInputs = [ jrl-cmakemodules ];
  nativeBuildInputs = [ cmake pkg-config ]
  ++ [ doxygen ]
  ++ lib.optionals use-python
     (with python3Packages; [ cython python distutils pytest ]);
  propagatedBuildInputs = [ eigen boost ]
  ++ lib.optionals use-python
     [ python3Packages.numpy eigen3-to-python ];

  cmakeFlags = [
    (lib.cmakeBool "PYTHON_BINDING" use-python)
  ];
  doCheck = true;
  meta = with lib; {
    description = "Spatial Vector Algebra with the Eigen library";
    homepage = "https://github.com/jrl-umi3218/SpaceVecAlg";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
