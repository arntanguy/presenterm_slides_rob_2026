---
title: "Workshop - Reproductible development and deploiement using Nix"
sub_title: "Wednesday, July 15 2026"
# sub_title: 
author: Arnaud TANGUY - CDD BIATSS - Appui à la recherche - LIRMM
---

<!-- alignment: center -->
<!-- jump_to_middle -->
<!-- font_size: 4 -->
It works on my machine!
<!-- end_slide -->

Does it though?
===
<!-- incremental_lists: true -->
* Maybe today.
  *  Will it tomorrow?
* Do you know how it was installed?
  * `apt`, `snap`, `rpm`, from `source`...
  * which `apt` repository though?
    * `ubuntu`, `cutom ppa`, ...
* Do you know what it depends on?
  * system version installed through `apt`?
  * another version on your system
    * maybe built from source?
* What if you want to upgrade your system?
<!-- incremental_lists: false -->
<!-- end_slide -->

Can you share it?
===
<!-- incremental_lists: true -->
## Here is a link to a repository with my code 
* and here is a `README.md` file
* that might be up to date
* well you don't really know why it works for you...
* ... can you even write the `README.md`?
## What if you have more than one package?
* share links to all of them
* maybe you have a `README.md` to say in which order to build
<!-- incremental_lists: false -->
<!-- end_slide -->

<!-- alignment: center -->
<!-- jump_to_middle -->
<!-- font_size: 4 -->
Maybe it works.
<!-- end_slide -->

<!-- alignment: center -->
<!-- jump_to_middle -->
<!-- font_size: 4 -->
But it's painful.
<!-- end_slide -->

Maybe you tried to do things right
==
<!-- incremental_lists: true -->
## You made `debian packages`
* did you? congrats ! 
* no really, they're painful to make.
* People can do `sudo apt install your-awesome-code`
<!-- new_lines: 2 -->
## It's a library, other projects depend on it.
* great, maybe that's enough
* **BUT**:
  * it only works on ubuntu
  * `your-awesome-code` depends on other system packages
    * do you know what `apt update` will do?
      * hopefully it still works, everything is API/ABI compatible
        * it should, but that's convention 
        * if not - your robot it's on the floor, broken
<!-- incremental_lists: false -->
<!-- end_slide -->

Now... 
===
<!-- incremental_lists: true -->
## Your colleague wants a different version 
* Make a new package?
  * Sure
  * But he also has projects that depend on the official version
  * How do you install both?
* Build from source, under another install tree?
  * It would work
  * But you now have to make sure your build system picks up the right dependency
  * manually
<!-- incremental_lists: false -->
<!-- end_slide -->



Nix to the rescue 
===
Nix is a purely functional declarative package manager. 
<!-- incremental_lists: true -->
- **Declarative**: specify your dependencies explicitely
<!-- incremental_lists: false -->
<!-- end_slide -->

Install Nix
===
# Unfortunately, we cannot do it with Nix itself
## so... README.md it is.
<!-- font_size: 1 -->
```
 1. install the right apt package
sudo apt install -y nix-setup-systemd

# 2. activate the new CLI and flake features
echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf

# 3. (optional) if you trust us, add our binary caches to avoid recompiling everything
echo 'extra-substituters = https://gepetto.cachix.org https://attic.iid.ciirc.cvut.cz/ros https://mc-rtc-nix.cachix.org' | sudo tee -a /etc/nix/nix.conf
echo 'extra-trusted-public-keys = gepetto.cachix.org-1:toswMl31VewC0jGkN6+gOelO2Yom0SOHzPwJMY2XiDY= ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q= mc-rtc-nix.cachix.org-1:5M3sLvHXJCep4wc1tQl7QuFWL2eH2I0jkuvWtqJDYQs=' | sudo tee -a /etc/nix/nix.conf

# 4. activate your new nix.conf
sudo systemctl restart nix-daemon

# 5. allow yourself to use nix
sudo usermod -aG nix-users $(whoami)
newgrp nix-users

# 6. test everything is fine
nix run nixpkgs#ponysay it works
```

If you don’t want this nix-setup-systemd apt package, other options include:
* Nix installer: https://nixos.org/download/
* Nix installer beta: https://github.com/NixOS/nix-installer
* Lix installer: https://lix.systems/install/
<!-- end_slide -->

Install Nix
===
## Trust me? Let's do it.

```
git clone https://github.com/arntanguy/presenterm_slides
cd presenterm_slides/nix_workshop_lirmm_2026
./install_nix_linux.sh
```

## You should see this

```bash +exec
kitty sh -c '
  nix run nixpkgs#ponysay Nix works
  read -n 1 -s -r -p "Press any key to continue..."
'
```
<!-- end_slide -->

Now let's start this presentation
===

# That way you can run the examples yourself

```bash
nix develop
presenterm -x nix_workshop_lirmm_2026/slides.md
```

How to use?

- Type `12G` to go to this slide (or "n" 12 times)
- `n`: next slide
- `p`: previous slide
- `Ctrl + e` : execute code snippets (I promise, nothing dangerous, it'll be shown on the slides)
  - Some output might display wrong the first time, use `Ctrl + r` to reload the slide, then `Ctrl + e`

<!-- end_slide -->

Well you just used `Nix`
===

# What happened?

- `nix develop` created a shell with all dependencies needed to run this presentation
- This is defined in a derivation in `flake.nix`
```nix {3,4, 8, 12-15}
          {
            lib, stdenv,
            presenterm,
            kitty,
            ...
          }:
          let slideName = "nix_workshop_lirmm_2026"; in
          stdenv.mkDerivation {
            name = slideName;
            version = "1.0.0";
            outputs = [ "out" "html" ]; 
            nativeBuildInputs = [
              presenterm
              kitty
            ];
            src = lib.cleanSource ./.;
            installPhase = ''
              mkdir -p $out/bin $out/share/slides
              cp -r ./${slideName}/* $out/share/slides/
              cat <<EOF > $out/bin/run-slides
              #!/bin/sh
              exec ${kitty}/bin/kitty ${presenterm}/bin/presenterm -x "$out/share/slides/slides.md" "\$@"
              EOF
              chmod +x $out/bin/run-slides

              # html
              mkdir -p $html
              ${presenterm}/bin/presenterm --export-html -c config.yaml ./${slideName}/slides.md
              cp ./${slideName}/slides.html $html/ || true
            '';
            meta.mainProgram = "run-slides";
          };
```

- `presenterm` and `kitty` are derivations too. Nix will evaluate them as needed, and their dependencies
<!-- end_slide -->

Wait... where is it installed?
===

# Let's check

```bash +exec
nix build nixpkgs#{presenterm,kitty} .#nix_workshop_lirmm_2026 --print-out-paths
```
<!-- end_slide -->

`/nix/store`
===

* Store path `/nix/store/yp6d6psnf6jj378kac6k7a13nzij2jyc-nix_workshop_lirmm_2026`
* Unique hash of all inputs

```nix
          {
            stdenv, # standard build environment (compilers, etc)
            lib, # helper functions 
            presenterm, kitty, ... # dependencies
          }:
          let slideName = "nix_workshop_lirmm_2026"; in
          stdenv.mkDerivation {
            name = slideName; version = "1.0.0"; # metadata
            outputs = [ "out" "html" ]; 
            nativeBuildInputs = [ # all used dependencies
              presenterm
              kitty
            ];
            src = lib.cleanSource ./.; # all source files
            # how to install
            installPhase = ''
              mkdir -p $out/bin $out/share/slides
              cp -r ./${slideName}/* $out/share/slides/
              cat <<EOF > $out/bin/run-slides
              #!/bin/sh
              exec ${kitty}/bin/kitty ${presenterm}/bin/presenterm -x "$out/share/slides/slides.md" "\$@"
              EOF
              chmod +x $out/bin/run-slides

              # html
              mkdir -p $html
              ${presenterm}/bin/presenterm --export-html -c config.yaml ./${slideName}/slides.md
              cp ./${slideName}/slides.html $html/ || true
            '';
            meta.mainProgram = "run-slides";
          };
```
<!-- end_slide -->

Let's try something
===

Edit `flake.nix`: 
* Change:
  * `version = "1.0.0";`
  * to `version = "2.0.0";`
* Add: 
  * `touch $out/i-added-this` to the end of `installPhase`
* Run:
  * `nix build .#nix_workshop_lirmm_2026 --print-out-paths`
* Now do `ls /nix/store | grep nix_workshop_lirmm_2026`
  * You've got multiple paths
* Now do `ls -l ./result`
  * That's the one you just built
* Now do `ls ./result`
  * Your new file is here
  * Look into the other paths, your file is not here
<!-- end_slide -->



Back to the slides?
===

* You already know how to present them. Btw you can also do `nix run .#nix_workshop_lirmm_2026`
* Want them as html?
```bash +exec
echo "Building slides..."
nix build .#nix_workshop_lirmm_2026.html --print-out-paths
echo "This might take a while, installing chromium..."
# want to see them, don't have a web browser?
nix run nixpkgs#chromium ./result-html/slides.html
```
<!-- end_slide -->

Back to the basics
===

# Nix is a functional programming language

Try

```bash +exec
kitty sh -c '
  nix repl
'
```
Examples:
- `1+2` -> `3`
- `let x = 1; in x + 2` -> `3`
- curried functions:
  - `let add = a: b: a + b; in add 1 2` -> `3`
- attribute sets:
  - `let attr = { a.b.c = 2; }; in attr.a.b` -> `{ c = 2; }`
- let ... in ...

You can fool around with nix language. See https://nix.dev/tutorials/nix-language for a quick walk-through.
<!-- end_slide -->

Packaging basics
===

Let's create our first derivation!

<!-- column_layout: [3, 2] -->
<!-- column: 0 -->
```bash +exec
nix-build - <<'EOF'
{ lib, stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "hello";
  version = "2.12";
  src = fetchurl {
    url = "mirror://gnu/${pname}/${pname}-${version}.tar.gz";
    sha256 = "1ayhp9v4m4rdhjmnl2bq3cibrbqqkgjbl3s7yk2nhlh8vj3ay16g";
  };
  meta = with lib; {
    license = licenses.gpl3Plus;
  };
}
EOF
```
<!-- column: 1 -->
* Problem: the expression in is a function, which only produces its intended output if it is passed the correct arguments.
```nix
{ lib, stdenv, fetchurl }:
```

* Where do they come from?
  * Right now nowhere
  * But they are packages from `nixpkgs`

* Let's see how to use it.

<!-- end_slide -->

Building your first derivation
===

<!-- column_layout: [3, 2] -->
<!-- column: 0 -->
```bash +exec
nix-build - <<'EOF'
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-26.05";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in
{
  hello = pkgs.callPackage ./pkgs/hello.nix { };
}
EOF
```
<!-- column: 1 -->
* `callPackage` automatically passes attributes from `pkgs` to the given function, if they match attributes required by that function’s argument attribute set. 
  * In this case, `callPackage` will supply `stdenv` and `fetchzip` to the function defined in `hello.nix`.
```nix {1, 5-8}
{ lib, stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "hello";
  version = "2.12";
  src = fetchurl {
    url = "mirror://gnu/${pname}/${pname}-${version}.tar.gz";
    sha256 = "1ayhp9v4m4rdhjmnl2bq3cibrbqqkgjbl3s7yk2nhlh8vj3ay16g";
  };
  meta = with lib; {
    license = licenses.gpl3Plus;
  };
}
```
<!-- end_slide -->

Let's build a shell script, with parameters
===

<!-- column_layout: [3, 2] -->
<!-- column: 0 -->
```bash +exec
nix-build - <<'EOF'
let
  pkgs = import <nixpkgs> { };  # shorthand for fetching nixpkgs
  hello-drv = 
    {
      writeShellScriptBin,
      audience ? "world",
    }:
    writeShellScriptBin "hello" ''
      echo "Hello, ${audience}!"
    ''
  ;
in
{
  hello = pkgs.callPackage hello-drv { audience = "LIRMM"; };
}
EOF
```

<!-- pause -->
<!-- column: 1 -->

* This generated ./result
```bash +exec_replace
ls -lR ./result/bin/hello
```

* It's a shell script
```bash +exec_replace
cat ./result/bin/hello
```

* And even bash is reproducible ;)

* You can call it with `./result/bin/hello`

```bash +exec
./result/bin/hello
```
<!-- end_slide -->

Add a depencency
===

<!-- column_layout: [3, 2] -->
<!-- column: 0 -->
```bash +exec {7, 11}
nix-build - <<'EOF'
let
  pkgs = import <nixpkgs> { };  # shorthand for fetching nixpkgs
  hello-drv = 
    {
      writeShellScriptBin,
      cowsay,
      audience ? "world",
    }:
    writeShellScriptBin "hello" ''
      ${cowsay}/bin/cowsay "Hello, ${audience}!"
    ''
  ;
in
{
  hello = pkgs.callPackage hello-drv { audience = "LIRMM"; };
}
EOF
./result/bin/hello
```

<!-- pause -->
<!-- column: 1 -->
* `${...}` is the syntax to evaluate nix expression in strings
  * Here `${cowsay}` evaluates the cowsay derivation from nixpkgs
  * Note that it will build it if necessary.
* After nix has replaced all variables, the remainder are left as-is, so bash can use them
* `$var` would be a bash variable in this context

```bash +exec {6-8}
nix-build - <<'EOF'
let
  pkgs = import <nixpkgs> { };
  hello-drv = { writeShellScriptBin, cowsay, audience ? "world", }:
    writeShellScriptBin "hello" ''
      var="$(pwd)"
      cowsay="Meuuuh!"
      ${cowsay}/bin/cowsay "Hello, ${audience}! We are in $var directory. $cowsay"
    '';
in { hello = pkgs.callPackage hello-drv { audience = "LIRMM"; }; }
EOF
./result/bin/hello
```


<!-- end_slide -->

Anatomy of a derivation
===
<!-- column_layout: [3, 2] -->
<!-- column: 0 -->
```nix
{
  stdenv, # standard build environment (compilers, etc)
  lib, # helper functions 
  ... # dependencies
}:
stdenv.mkDerivation {
  name = "hello"; 
  version = "1.0.0";
  outputs = [ "out" "doc" ]; 
  buildInputs = [ ]; # dependencies needed for building
  nativeBuildInputs = [ ]; # dependencies needed for building in shells
  propagatedBuildInputs = [ ]; # dependencies needed at runtime
  src = lib.cleanSource ./.; # all source files

  # Build hooks
  # buildPhase, preBuildPhase, postBuildPhase,
  # installPhase, preInstallPhase, postInstallPhase, 
  # checkPhase, preCheckPhase, postCheckPhase, 
  # fixupPhase, preFixupPhase, postFixupPhase, 
  # patchPhase, prePatchPhase, postPatchPhase, 
  # unpackPhase, preUnpackPhase, postUnpackPhase,
  # configurePhase, preConfigurePhase, postConfigurePhase

  # metadata
  meta = with lib; {
    license = licenses.gpl3Plus;
    mainProgram = "run-slides";
  };
}
```

<!-- pause -->
<!-- column: 1 -->

# That's a lot of build hooks
## Not to worry, nix has sensible defaults
### Want to build a `cmake` project?
* Add

```
nativeBuildInputs = [ cmake ];
```

* Nix will run cmake hooks for you

<!-- end_slide -->


Let's package SpaceVecAlg together
===


<!-- column_layout: [3, 2] -->
<!-- column: 0 -->

# SpaceVecAlg is a library for spatial vector algebra, used in robotics.
* It has a C++ API 
* and Python bindings.
* Project: https://github.com/jrl-umi3218/SpaceVecAlg

## Let's start with C++ dependencies:

* cmake, pkg-config, jrl-cmakemodules
* Eigen3
* Boost

We need to disable:
- Doxygen documentation `-DINSTALL_DOCUMENTATION=OFF`
- Cython bindings `-DPYTHON_BINDING=OFF`

Tips:
* You can get the input hash with
```bash +exec
echo "This will take a few seconds, it needs to download it first..."
nix run nixpkgs#nurl https://github.com/jrl-umi3218/SpaceVecAlg v1.2.10
```

<!-- column: 1 -->
# Solution
<!-- pause -->

```nix
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

  buildInputs = [ jrl-cmakemodules ];
  nativeBuildInputs = [ cmake pkg-config ];
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
```
<!-- end_slide -->

Let's add python and documentation
===


<!-- column_layout: [3, 2] -->
<!-- column: 0 -->
You need:
* doxygen
* python3Packages
  * numpy
  * eigen3-to-python

# Solution
<!-- pause -->

```nix {5-7,9-11}
{
  stdenv, lib,  fetchFromGitHub,
  cmake, pkg-config, jrl-cmakemodules,
  eigen, boost,
  doxygen,
  python3Packages,
  with-python ? true,
}:
let 
  use-python = with-python && !stdenv.hostPlatform.isDarwin;
in
```

<!-- pause -->

<!-- column: 1 -->
```nix {1,10,11-12,14-15,18}
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
     [ python3Packages.numpy python3Packages.eigen3-to-python ];

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
```
<!-- end_slide -->


<!-- alignment: center -->
<!-- jump_to_middle -->
<!-- font_size: 4 -->
Need a break?
===
<!-- font_size: 1 -->
## Upcoming: flakes, or how to use it in practice
<!-- end_slide -->


Nix flakes
===

<!-- column_layout: [3, 2] -->
<!-- column: 0 -->
# A modular way of interacting with nix code

We have already been using them:
- nix run `<flake_url>#<flake_output>`
- nix build
- nix develop
- nix shell


```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        # nix build .#hello
        packages.hello = pkgs.hello;

        # nix build
        defaultPackage = self.packages.${system}.hello;

        # nix develop .#hello or nix shell .#hello
        devShells.hello = pkgs.mkShell { buildInputs = [ pkgs.hello pkgs.cowsay ]; };
        
        # nix develop or nix shell
        devShell = self.devShells.${system}.hello;
      });
}
```

<!-- column: 1 -->

# Structure is standardized

## Inputs are locked

* The first time you use the flake it records all inputs in a `flake.lock` file

```bash +exec
cd samples/hello-flake
nix run .#hello
```

* Subsequent run will use the exact same inputs.
* You can commit your `flake.lock`
  * Everyone uses this version

## Ouputs are whatever you wish

* Try `nix flake show`:
  * Outputs are listed by platform/name
* Try `nix develop`:
  * Run `hello`
  * Note that all the dependencies to build hello are there
* Try `nix shell`
  * Run `hello`
* Let's explore:
  * Run `nix repl`
    * `:lf .`
<!-- end_slide -->

# Why is it nice?

# Try

```bash
nix flake show github:rolkneematics/panda_prosthesis
```

## Ok, it has a bunch of devShells

```
├───devShells
│   └───x86_64-linux
│       ├───default: development environment 'flakoboros-default-devShell'
│       ├───panda-prosthesis-full: development environment 'panda-prosthesis-full'
│       ├───panda-prosthesis-full-devel: development environment 'panda-prosthesis-full-devel'
│       ├───panda-prosthesis-minimal: development environment 'panda-prosthesis-minimal'
│       └───panda-prosthesis-minimal-devel: development environment 'panda-prosthesis-minimal-devel'
```

## Let's try

<!-- column_layout: [3, 2] -->
<!-- column: 0 -->

### Enter a development shell

```bash +exec
kitty sh -c '
  nix develop github:rolkneematics/panda_prosthesis#panda-prosthesis-minimal
'
```

### Use

```
(mc-rtc-magnum &) # run a visualizer in the background
mc_rtc_ticker # run open-loop control
```


<!-- column: 1 -->
This will download:
* the ANR Rolkneematics panda_prosthesis controller
  * mc-rtc framework
  * and its dependencies: Panda robot
  * additional tools (visualizer, etc)

<!-- end_slide -->

Exploring the dependency tree
===

# Nix knows it, let's exploit it

## Get the relevant store path to the controller

```bash +exec
nix build github:rolkneematics/panda_prosthesis#panda-prosthesis --print-out-paths
```

## Let's explore
<!-- pause -->

Use:
- Left/Right arrows to navigate
- `w` to see why we depend on a package

```bash +exec
out_path=$(nix build github:rolkneematics/panda_prosthesis#panda-prosthesis --print-out-paths)
kitty sh -c "nix run nixpkgs#nix-tree -- $out_path"
```
<!-- end_slide -->

Let's try another controller: polytopeController 
===

## Inspect: nix flake show github:Hugo-L3174/polytopeController/pull/2/head

## Run:
### well actually you cannot, private repositories...

```bash +exec
kitty sh -c '
echo $(pwd)
nix develop github:Hugo-L3174/polytopeController/pull/2/head
'
```

<!-- pause -->

<!-- column_layout: [3, 2] -->
<!-- column: 0 -->
### What's required? 

This flake changes multiple inputs:

* /nix/store/lrvxjf4a10i7xz5yi25prbjc5b59zrpx-mc-rtc-hugo-2.15.0 (105.64 MiB)
* /nix/store/843b8lxw5n5kn6yk6qdvi5v9hwbmv9w3-politopix-1.0.0 (1.76 MiB)
* /nix/store/hfymxc7zbm7xl9g37m6jp4fsdiaac7rx-mc-force-shoe-plugin-2.0.0 (2.52 MiB)
* /nix/store/152k3k231y1n075b9a5cx8j0p3rknkzn-tvm-0.9.2 (3.51 MiB)
* /nix/store/i3c8f3psxmbqpi6mhlw5pwg2nisgx06h-tasks-lssol-v1.8.4 (3.49 MiB)
* /nix/store/kcbvnd7f95sg7a942r8daycfmcwka82y-polytopeController-1.0.0 (1.99 MiB)
* /nix/store/3j9fnix8m0czrs6nfmb96xlg9yvnhmg9-dcm-vrptask-0.1.0 (3.18 MiB)
* /nix/store/1qv15vwh65b4a9jac7yzbg4sgi3xkgm1-gram-savitzky-golay-1.0.1 (70.90 KiB)
* /nix/store/rm5jk4h97mh6jkpr4nhhgp9lgbwnfcqa-eigen-lssol-0.0.0 (519.91 KiB)
* /nix/store/sid3ibs5fcrkd081n45x5zs7wq0s3jkf-mc-dynamic-polytopes-1.0.1 (1.35 MiB)



<!-- column: 1 -->
### Let's explore
<!-- pause -->

```bash +exec
out_path=$(nix build github:Hugo-L3174/polytopeController/pull/2/head#polytopeController --print-out-paths)
kitty sh -c "nix run nixpkgs#nix-tree -- $out_path"
```
<!-- end_slide -->

Quick peak inside the flake
===

<!-- column_layout: [1, 1] -->
<!-- column: 0 -->
```nix
{
# Override all dependencies
inputs = {
  mc-rtc-nix.url = "github:mc-rtc/nixpkgs";
  flake-parts.follows = "mc-rtc-nix/flake-parts";
  systems.follows = "mc-rtc-nix/systems";

  # or use pull/N/merge to get the version merged with master, assuming there are no conflicts

  mc-state-observation.url = "github:jrl-umi3218/mc_state_observation/pull/57/head";
  mc-state-observation.flake = false;

  dcm-vrptask.url = "github:Hugo-L3174/DCM_VRPTask/pull/1/head";
  dcm-vrptask.flake = false;

  mc-dynamic-polytopes.url = "github:Hugo-L3174/mc_dynamic_polytopes/pull/6/head";
  mc-dynamic-polytopes.flake = false;

  mc-force-shoe-plugin.url = "github:Hugo-L3174/mc_force_shoe_plugin/pull/16/head";

  mc-rtc.url = "github:jrl-umi3218/mc_rtc/pull/507/head";
};
}
```

<!-- column: 1 -->
```nix
{
flakoboros.overrideAttrs = 
  {
    polytopeController = { src = lib.cleanSource ./.; };
    mc-force-shoe-plugin = { src = inputs.mc-force-shoe-plugin; };
    mc-state-observation = { src = inputs.mc-state-observation; };
    dcm-vrptask = { src = inputs.dcm-vrptask; };
    mc-dynamic-polytopes = { src = inputs.mc-dynamic-polytopes; };
    mc-rtc = {
        pname = "mc-rtc-hugo";
        src = inputs.mc-rtc;
    };

    politopix = { ... }:
    {
      src =
        builtins.trace "politopix is currently a private repository, ask I2S Bordeaux to make it public"
        (
          builtins.fetchGit {
            url = "git@github.com:Hugo-L3174/politopix";
            rev = "f625b42de4404eea16aabcf720f2cee19dfdc406";
          }
        );
    };
    # ...
};
}
```

<!-- end_slide -->



Cleanup
===

* We've put a lot of things in `/nix/store`.
  * If you no longer want them, nix has a garbage collector
    * This will remove all files from `/nix/store` not currently in use.

```
nix-collect-garbage
```


* `mc-rtc` generated a few cached convex hull files, you can remove `~/.local/share/mc_rtc`

<!-- end_slide -->



<!-- alignment: left -->
nix run 
===

# What just happened?
<!-- font_size: 1 -->

```bash +exec
kitty sh -c '
  nix run nixpkgs#fortune | nix run nixpkgs#ponysay
  read -n 1 -s -r -p "Press any key to continue..."
'
```
<!-- end_slide -->

<!-- alignment: left -->
# nix build 
* What got installed? Where?
* Let's check
<!-- font_size: 1 -->

```bash +exec
nix build nixpkgs#fortune --print-out-paths
ls -lR ./result/*
kitty bash -c 'ls; exec bash'
```
<!-- end_slide -->

# nix run 
## Et si on exécutait cette présentation ?

```bash +exec +acquire_terminal
nix run .#rob_2026
```

<!-- end_slide -->

# nix shell
## Il vous manque un outil? ...
### ... disons pour afficher un fichier JSON ?

```bash +exec +pty
nix shell nixpkgs#jq nixpkgs#curl -c curl -sSL https://jrl.cnrs.fr/mc_rtc/schemas/mc_rtc/mc_rtc.json | jq | less
```

<!-- end_slide -->

# nix run
## Et si on testait des travaux en cours ?

### Bindings python nanobind en développement pour SpaceVecAlg dans une pull request:

```bash +exec +acquire_terminal
nix run github:jrl-umi3218/SpaceVecAlg/pull/74/head
```

### Ou juste exécuter

```bash +exec +pty
echo -e "import sva\nprint(sva.RotZ(1.57))" | \
    nix run github:jrl-umi3218/SpaceVecAlg/pull/74/head
```

<!-- end_slide -->

# nix build
## Et si on compilais quelque chose?

```bash +exec
ls -lR `nix build github:jrl-umi3218/SpaceVecAlg/pull/74/head#spacevecalg --print-out-paths`
```

<!-- end_slide -->


<!-- jump_to_middle -->
<!-- alignment: center -->
<!-- font_size: 2 -->
> /nix/store/c5irr3v07il3dsqr6zikkszg29n3if6f-spacevecalg-nanobind-1.2.9
<!-- font_size: 4 -->
???
 
<!-- end_slide -->

<!-- new_lines: 3 -->
```bash +exec
ls /nix/store | rg 'mc-rtc-2.14.1$'
```

<!-- end_slide -->

# nix develop
## Et si on codais?

```bash
# Clone code
nix shell nixpkgs#gh # oops, il nous manque l'outil cli de github!
gh login
gh repo clone jrl-umi3218/SpaceVecAlg
gh pr checkout 74

# Environnement avec toutes les dépendences
nix develop .#spacevecalg

# On compile
cmake -B build $cmakeFlags
cmake --build build

# On modifie, on exécute
export PYTHONPATH="$PWD/build/lib/site-packages:$PYTHONPATH" # set python path for dev
python
import sva
```

<!-- end_slide -->

# nix develop
## Et si on complexifiait en installant le framework mc_rtc et tout les robots?

```bash +exec +acquire_terminal
kitty sh -c '
  nix develop github:mc-rtc/nixpkgs#mc-rtc-superbuild-full
'
```

Dans ce terminal:
- mc_rtc est disponible
- avec toutes ses dépendences
- et tous les plugins définis dans la configuration pour `mc-rtc-superbuild-full`:
    - robots: tous les robots publics : `Panda`, `UR10`, `JVRC1`, etc
    - plugins: ROS

Exécuter avec:
- `mc-rtc-magnum` : standalone visualization
- `mc_rtc_ticker` : controller 

<!-- end_slide -->

# nix develop
## Et si on lançait une démo complexe?
### Demo HCERES: Polytope Controller

- Fixé à un commit spécifique 
- Continuera de fonctionner tant que les inputs restent disponibles

```bash +exec +acquire_terminal
kitty sh -c '
  nix develop github:arntanguy/polytopeController-1/224c37a1090dd93ed8546e8bfed7b7494e513db4#polytopeController-minimal -c sh -c "
    mc-rtc-magnum & 
    mc_rtc_ticker
  "
'
```

<!-- end_slide -->

# nix develop
## Changement de projet ? 
### ANR Rolkneematics

```bash +exec +acquire_terminal
kitty sh -c '
  nix develop github:arntanguy/panda_prosthesis/98ceb5790e6e353a5605142b0f7c57029600f86d#panda-prosthesis-full -c sh -c "
    mc-rtc-magnum & 
    mc_rtc_ticker
  "
'
```

<!-- end_slide -->

<!-- new_lines: 3 -->
<!-- font_size: 4 -->
C'est trop compliqué à retenir !

<!-- font_size: 1 -->

# Direnv

## Outil pour exécuter une commande en entrant dans un dossier
### Intégration avec Nix flakes via nix-direnv 
### Example

Fichier `.envrc`
```text
use flake "github:arntanguy/panda_prosthesis/98ceb5790e6e353a5605142b0f7c57029600f86d#panda-prosthesis-full"
```

### Demo

```bash +exec +acquire_terminal
kitty --directory ~/nix-envs
```

<!-- end_slide -->

<!-- jump_to_middle -->
<!-- alignment: center -->
<!-- font_size: 4 -->
Fonctionnement

<!-- font_size: 2 -->
> Workshop semaine du 13 juillet !
> 1/2 journée

<!-- end_slide -->

# Concepts

## Nix
 
- Langage fonctionnel pour le packaging reproductible.

## Dérivation - aka "Package"

- Transforme des inputs en outputs.

## Nixpkgs

- Dépot officiel des dérivations Nix.
- Le plus complet: ~100.000 paquets

## NixOs

- Système d'exploitation construit au dessus de Nixpkgs

## Overlay

- Set de dérivations et leur options
- Extensible

## Flake

- Une manière standardisée d'interagir avec Nix
- Permet de figer les inputs avec un `flake.lock`
- Définit un set d'outputs : `nix run <url>#<output>`

<!-- end_slide -->

# Les dérivation c'est simple

```nix
# Dépendences
{ stdenv, lib, cmake, pkg-config, jrl-cmakemodules, doxygen,
  eigen, boost, fetchFromGitHub, python3Packages }:

stdenv.mkDerivation {
  pname = "spacevecalg";
  version = "1.2.10";

  src = fetchFromGitHub {
    owner = "jrl-umi3218";
    repo = "SpaceVecAlg";
    tag = "v1.2.10";
    hash = "sha256-fTKKj3m8cO4F46LlO7r8JeuWLhlyRcX7EblHroDYFkQ=";
  };

  # outils pour compiler
  nativeBuildInputs = [ cmake jrl-cmakemodules pkg-config doxygen ] 
    # pour les bindings python
    ++ (with python3Packages; [ cython python distutils pytest ]);

  # librairies/outils dont on a besoin et d'autres programmes auront besoin
  propagatedBuildInputs = [ eigen boost ]
    ++ (with python3Packages; [ numpy eigen3-to-python ]);

  # flags de compilation
  cmakeFlags = [ "-DINSTALL_DOCUMENTATION=OFF" ];

  meta = with lib; {
    description = "Spatial Vector Algebra with the Eigen library";
    homepage = "https://github.com/jrl-umi3218/SpaceVecAlg";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
```

<!-- end_slide -->

# Flakoboros : packaging circulaire

## Concept

- un repo central - version "released" : [mc-rtc/nixpkgs](https://github.com/mc-rtc/nixpkgs), [gepetto/nix](https://github.com/gepetto/nix)
  - contient toutes les dérivations
  - un overlay pour les exposer
  - en CI: build et push un cache binaire de toutes les dérivations

> Sait compiler et installer une version par défaut de tous les projets

- puis chaque repo (ex. `SpaceVecAlg`) modifie les dérivations pour:
  - compiler depuis les dernières sources
  - tester des changements (ex: bindings python)
  - en CI: build et push dans le cache binaire de la dernière version

> Adapte le packaging par défaut aux besoins spécifiques du projet 

<!-- end_slide -->

# Flakoboros : exemples avec Polytope Controller

```nix
{
  inputs = {
    mc-rtc-nix.url = "github:mc-rtc/nixpkgs";
    flake-parts.follows = "mc-rtc-nix/flake-parts";
    systems.follows = "mc-rtc-nix/systems";

    # On utilise des travaux en cours
    mc-state-observation.url = "github:jrl-umi3218/mc_state_observation/pull/57/head";
    dcm-vrptask.url = "github:Hugo-L3174/DCM_VRPTask/pull/1/head";
    mc-dynamic-polytopes.url = "github:Hugo-L3174/mc_dynamic_polytopes/pull/6/head";
    mc-force-shoe-plugin.url = "github:Hugo-L3174/mc_force_shoe_plugin/pull/16/head";
    mc-rtc.url = "github:jrl-umi3218/mc_rtc/pull/507/head";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ( { lib, ... }:
  {
      imports = [ inputs.mc-rtc-nix.flakeModule {
          flakoboros = { # On build avec les inputs modifiés
            overrideAttrs = {
              polytopeController = { src = lib.cleanSource ./.; };
              mc-force-shoe-plugin = { src = inputs.mc-force-shoe-plugin; };
              mc-state-observation = { src = inputs.mc-state-observation; };
              dcm-vrptask = { src = inputs.dcm-vrptask; };
              mc-dynamic-polytopes = { src = inputs.mc-dynamic-polytopes; };
              mc-rtc = { pname = "mc-rtc-hugo"; src = inputs.mc-rtc; };
            };
          };
          mc-rtc-nix.overlays.private = true; # on a besoin de robots privés (RHPS1, HRP4)
          mc-rtc-superbuild = { pkgs, ... }: { # configuration pour mc_rtc
              enable = true;
              configurations.polytopeController-minimal = {
                extends = [ "minimal" ];
                runtime = with pkgs; {
                  robots = [ mc-rhps1 mc-hrp4 ]; plugins = [ mc-force-shoe-plugin ];
                  observers = [ mc-state-observation ]; controllers = [ polytopeController ];
                  apps = [ mc-rtc-magnum mc-udp ];
                  config = "lib/mc_controller/etc/mc_rtc.yaml";
                };
              };
            };
      }];
  });
}
```

<!-- end_slide -->

<!-- alignment: center -->
<!-- jump_to_middle -->
<!-- font_size: 2 -->

Les utilisateurs peuvent toujours utiliser/modifier/tester la dernière version

> Cache binaire = aussi rapide que le temps de téléchargement
