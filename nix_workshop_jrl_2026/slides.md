---
title: "Workshop - Reproducible development and deploiement using Nix"
sub_title: "Wednesday, July 22 2026"
# sub_title: 
author: Arnaud TANGUY - LIRMM - Research Engineer
---

<!-- alignment: center -->
<!-- jump_to_middle -->
<!-- font_size: 4 -->
It works on my machine!
<!-- end_slide -->

Does it though?
===

* Do you know how?
* Can I try your changes?
  * Sure...
  * ...install this, this and that, oh and you need x,y,z too!
  * ...and it'll take at least 30mn to build
* It didn't work?
  * Oh but you're on Ubuntu 26.04? I'm still on 20.04 since the start of my thesis
  * Ah you had something custom in `LD_LIBRARY_PATH`
  * Oh and your python virtual env is activated?

<!-- end_slide -->

Some existing solutions in the lab
===

# Historical scripts

* `build_and_install.sh` for mc_rtc
* `drcutils.sh` for hrpsys / hmc2

> * Better, we're not installing manually.
> * Still depends on the system state.
> * Only supports pre-defined packages.

# mc-rtc-superbuild

It's a meta cmake project with:

* Wrappers around fetchcontent
  * Clones / update from git repository
  * Install system dependencies from APT / PIP
* Dependency graph between projects is managed by cmake
  * Build projects in the correct order
* Extensions
  * Add cmake scripts in the `extensions` folder to add custom projects

> * More flexible
> * Still relies on system installs
> * Workspace concept: installs the whole set of projects under a single install tree (/usr/local, custom path)

# ROS tooling

* rosdep + colcon workspaces

> * Same limitiations


<!-- end_slide -->

Build from source?
===

Both solutions build from source, that's slow.

# What about APT packages?

* Hard to build
  * So nobody does
* One global system install
* We have some for the core dependencies up to mc_rtc and a few downstream packages
  * Ok for demo
  * Ok-ish for developping a controller against mc_rtc official release/master

> Is this really our use-case?

<!-- end_slide -->

What do we want?
===

This is research, we want to modify things.

* mc_rtc, Tasks, TVM, mc_udp, mc_openrtm

But do we want to modify them for all projects?

> NO

Examples:
* Hugo's PolytopeController : modifies TVM, mc_rtc, state-observation
  * And we cannot merge yet
* PandaProsthesis : needed to use custom mc_panda, mc_panda_lirmm with untested calibrated robot models
  * Cannot merge for everyone while untested
  * But what if another project uses mc_panda?
  * Cannot use Hugo's branches of mc_rtc
    * well maybe it can, but this should be unrelated

<!-- end_slide -->

Devcontainers ?
===

# Solves a few issues

* System repeatability
  * we control the initial state of the system
  * we can guarantee that it'll build`*`
    * `*` for a given docker image
* Build-time?
  * Sneak pre-built ccache in the container

# Multiple projects?

* Sure, use one devcontainer per-project
* With all dependencies duplicated
  * In practice projects share most dependencies
  * Need the same change in multiple projects?

# Automated mc-rtc-superbuild devcontainers

From an existing mc-rtc-superbuild configuration, CI can generate devecontainers:

* devcontainer: pre-installed all superbuild dependencies, pre-built ccache, mounts a local workspace
* release: only dependencies + install tree
* devel: contains everything

> Repeatable
> Best if you work on a single project
> Can be built in CI for any superbuild project

<!-- end_slide -->

Wouldn't it be great if...
===

* We could specify dependencies per-project?
* We didn't have to build if someone already did?
* We could try each other changes? Without breaking our setup?
* Have development shells that have the exact dependencies needed to build your project?

> Nix does that, and more!


<!-- end_slide -->

Nix - a functional package manager
===

Functional? Everything is a function, including packages

Nix is:
- Declarative
  - Specify what is needed and how to build your project
- Reproducible
  - If it built once, it always will`*`
- Fast: binary cache
  - If a package was built, it does not need to be again.
- Development shell
  - Same dependencies used to build the package can be used to provide a development shell
- Works everywhere:
  - Linux (any distribution)
  - MacOS
  - Windows* (WSL2)

<!-- end_slide -->



I'm bored
===
<!-- jump_to_middle -->
<!-- alignment: center -->
```text
 _     _              ____                      
| |   (_)_   _____   |  _ \  ___ _ __ ___   ___ 
| |   | \ \ / / _ \  | | | |/ _ \ '_ ` _ \ / _ \
| |___| |\ V /  __/  | |_| |  __/ | | | | | (_) |
|_____|_| \_/ \___|  |____/ \___|_| |_| |_|\___/
```

<!-- end_slide -->

4 commands to rule them all
===

- nix build : build a package
- nix run : run (and build) a package
- nix develop : development shell to build locally
- nix shell : make packages available in your shell

<!-- font_size: 1 -->
<!-- alignment: left -->
# nix run 

<!-- font_size: 1 -->
```bash +exec
echo "4 commandes: run, shell, build devel" | nix run nixpkgs#cowsay
```

<!-- end_slide -->

nix run 
===

# What if we executed this presentation? 

```bash +exec +acquire_terminal
nix run .#nix_workshop_jrl_2026
```

nix run:
- Installed the dependencies: `kitty` terminal, `presenterm` tool
- Executed them to display the presentation in a new terminal

<!-- end_slide -->

nix shell
===
# Missing a tool? 
### ... let's say to display a JSON file?

```bash +exec +pty
nix shell nixpkgs#{jq,curl} -c curl -sSL https://jrl-umi3218.github.io/mc_rtc/schemas/mc_rtc/mc_rtc.json | jq | less
```

> Tools are available for this terminal only

<!-- end_slide -->

nix run
===

# Want to try ongoing work ?

## Let's see where SpaceVecAlg's pull request on nanobind python bindings integration is:

<!-- column_layout: [2, 2] -->
<!-- column: 0 -->
```bash +exec +acquire_terminal
nix run github:jrl-umi3218/SpaceVecAlg/pull/74/head
```
<!-- column: 1 -->
## What happened?

nix run:
* Downloaded the branch for PR 74
* Built it, or downloaded it from binary cache
* Ran it's default program

<!-- reset_layout -->
<!-- pause -->
### Or just execute

```bash +exec +pty
echo -e "import sva\nprint(sva.RotZ(1.57))" | \
    nix run github:jrl-umi3218/SpaceVecAlg/pull/74/head
```

<!-- end_slide -->

nix build
===
## Let's build something 

```bash +exec
nix build github:jrl-umi3218/SpaceVecAlg/pull/74/head#spacevecalg --print-out-paths
```

/nix/store/... ???

> Nix installs each package in a unique path
> Path depends on all inputs used to generate the package's output (dependencies, compilation flags, compiler, etc)

<!-- pause -->

## What's in it?

```bash +exec +acquire_terminal
ls -lR `nix build github:jrl-umi3218/SpaceVecAlg/pull/74/head#spacevecalg --print-out-paths` | less
```

<!-- end_slide -->

Where is mc_rtc on my system?
===

<!-- column_layout: [2, 2] -->
<!-- column: 0 -->
```bash +exec
ls /nix/store | rg 'mc-rtc-2.14.1$'
```
<!-- column: 1 -->
Multiple paths = built with different inputs
* From different branches
* With different cmake flags
* With different dependencies
  * E.g a branch of TVM

<!-- pause -->
```bash +exec
out_path=$(nix build github:mc-rtc/nixpkgs#mc-rtc --print-out-paths)
kitty sh -c "nix run nixpkgs#nix-tree -- $out_path"
```

<!-- end_slide -->

# nix develop
## Want to code?

```bash
# Clone code
nix shell nixpkgs#gh # oops, we don't have the Github CLI tool, let's get it!
gh login
gh repo clone jrl-umi3218/SpaceVecAlg
gh pr checkout 74

# Environnement with all required dependencies
nix develop .#spacevecalg

# Build as usual
cmake -B build $cmakeFlags
cmake --build build

# Export python path from the build tree and use it
export PYTHONPATH="$PWD/build/lib/site-packages:$PYTHONPATH" # set python path for dev
python
import sva
```

<!-- end_slide -->

nix develop
===
# Let's try a complicated example
## Getting a shell with mc_rtc and all public robots

```bash +exec +acquire_terminal
kitty sh -c '
  nix develop github:mc-rtc/nixpkgs#mc-rtc-superbuild-full
'
```

In this terminal:
- mc_rtc is available
- with all its dependencies
- and all plugins defined in the configuration for `mc-rtc-superbuild-full`
    - robots: all public robots : `Panda`, `UR10`, `JVRC1`, etc
    - plugins: ROS

Run with:
- `mc-rtc-magnum` : standalone visualization
- `mc_rtc_ticker` : controller 

<!-- end_slide -->

# nix develop
## Let's try a complex demo?
### Demo HCERES: Polytope Controller

- Fixed to a specific commit
- Will keep working for as long as all inputs remain available

```bash +exec +acquire_terminal
kitty sh -c '
  nix develop github:arntanguy/polytopeController-1/224c37a1090dd93ed8546e8bfed7b7494e513db4#polytopeController-minimal -c sh -c "
    mc-rtc-magnum & 
    mc_rtc_ticker
  "
'
```

<!-- end_slide -->

nix develop
===
# Try another project?
## ANR Rolkneematics

### Fixed to an old commit

```bash +exec +acquire_terminal
kitty sh -c '
  nix develop github:arntanguy/panda_prosthesis/98ceb5790e6e353a5605142b0f7c57029600f86d#panda-prosthesis-full -c sh -c "
    mc-rtc-magnum & 
    mc_rtc_ticker
  "
'
```

<!-- pause -->
### From master

```bash +exec +acquire_terminal
kitty sh -c '
  nix develop github:rolkneematics/panda_prosthesis#panda-prosthesis-full -c sh -c "
    run-panda-prosthesis # auto-generated script to run the controller
  "
'
```
<!-- end_slide -->

That's too hard to remember!
===

# Direnv

## Tool to run a command upon entering a directory

* Well integrated with nix: nix-direnv
* If you have a `.envrc` file in the repository, run `direnv allow` to enable it.
* Next time you enter the folder, your nix develop environment is ready

Example:

```text
use flake "github:arntanguy/panda_prosthesis/98ceb5790e6e353a5605142b0f7c57029600f86d#panda-prosthesis-full"
```

### Demo

```bash +exec +acquire_terminal
kitty --directory ~/nix-envs
```

<!-- end_slide -->

<!-- alignment: center -->
<!-- jump_to_middle -->
<!-- font_size: 4 -->
Need a break?
===
<!-- font_size: 1 -->
# Upcoming: Nix language, packaging derivations 
<!-- end_slide -->


Concepts
===

# Nix

- Functional programming language specifically designed for package management.

# Derivation - aka "Package"

- Nix mechanism to transforms inputs to outputs.

# NixOs/nixpkgs

- Official reporitory of Nix derivations
- More than 160.000 packages
  - Most up-to-date software repository on earth
  - 1000+ PRs/day
  - Incredible community

# NixOs

- Operating system based on Nix and Nixpkgs 

# Overlay

- Set of derivations and their options
- Easily extensible

## Flake

- Standardized way of interacting with Nix packages
- Allows to fix inputs with a `flake.lock` file
  - Already demonstrated in the previous section
- Defines outputs : `nix run <flake url>#<flake output>`

<!-- end_slide -->

Install Nix (optional)
===

# If you wish to follow along, you can install Nix.
## Prerequisites

- Ubuntu >= 24.04
- ~10Gb free disk space

[Install Instructions](https://mc-rtc.github.io/nixpkgs/#setup-nix)

## Or docker (but gui apps most likely won't work)

<!-- end_slide -->

Try it
===

# Run 

```bash
nix run nixpkgs#fortune | nix run nixpkgs#ponysay
```


```bash +exec
kitty sh -c '
  nix run nixpkgs#fortune | nix run nixpkgs#ponysay
  read -n 1 -s -r -p "Press any key to continue..."
'
```
<!-- end_slide -->


Nix is a functional programming language
===

# Let's try it

<!-- column_layout: [3, 2] -->
<!-- column: 0 -->
Use
```bash
nix repl
```

Examples:

```
# everything used is evaluated
1+2 # -> 3

# let bindings - define values to use in an expression
let x = 1; in x + 2 # -> 3

# curried functions
let add = a: b: a + b; in add 1 2 # -> 3

# attribute sets:
let attr = { a.b.c = 2; }; in attr.a.b # -> { c = 2; }

# list concatenation
[1 2] ++ [3 4] # -> [1 2 3 4]

# attribute set concatenation
{ a = 1; } // { b = 2; } # -> { a = 1; b = 2; }
```

You can fool around with nix language. See https://nix.dev/tutorials/nix-language for a quick walk-through.

<!-- column: 1 -->

```bash +exec
kitty sh -c '
  nix repl
'
```
<!-- end_slide -->

Important data structures
===

Almost everything in nix packaging is an attribute set, derivations, flakes, etc...

# Attribute Sets

<!-- column_layout: [2, 2] -->
<!-- column: 0 -->
## JSON
<!-- new_lines: 2 -->
```json
{
  "string": "hello",
  "integer": 1,
  "float": 3.141,
  "bool": true,
  "null": null,
  "list": [1, "two", false],
  "object": {
    "a": "hello",
    "b": 1,
    "c": 2.718,
    "d": false
  }
}
```

<!-- column: 1 -->
## Nix
It looks like JSON but you can do

```nix
let
  myAttrs = {
    string = "hello";
    integer = 1;
    float = 3.141;
    bool = true;
    null = null;
    list = [ 1 "two" false ];
    attribute-set = {
      a = "hello";
      b = 2;
      c = 2.718;
      d = false;
    };
  };
in
{
  # Access a value
  greeting = myAttrs.string;

  # Access a nested attribute
  nestedValue = myAttrs.attribute-set.a;

  # Add a new attribute
  extended = myAttrs // { newAttr = "added!"; };

  # Update an existing attribute
  updated = myAttrs // { integer = 42; };

  # Get a value with a default if missing
  maybeValue = myAttrs ? missingAttr
    then myAttrs.missingAttr
    else "default";
}
```

<!-- end_slide -->

Anatomy of a derivation
===
<!-- column_layout: [3, 2] -->
<!-- column: 0 -->
```nix
# INPUTS
{
  stdenv, # standard build environment (compilers, etc)
  lib, # helper functions 
  ... # dependencies
}:
# OUTPUT
stdenv.mkDerivation # mkDerivation is a function taking the following attribute set
# Output attribute set
{
  pname = "hello"; 
  version = "1.0.0";
  outputs = [ "out" "doc" ]; # can install files in these outputs (in the nix store)
  buildInputs = [ ]; # dependencies needed for building
  nativeBuildInputs = [ ]; # dependencies needed for building and in shells
  propagatedBuildInputs = [ ]; # dependencies needed at build or runtime or by other packages

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

# A derivation is a function with

## An input attribute set

* can contain any valid nix expression
  * usually it's other derivations (dependencies)
  * and options

## An output attribute set

* standardized format of what a derivation can do
  * package name, version, metadata
  * build inputs
  * hooks that define how to generate the output ("build your package")

## In-between mkDerivation

* is a function that:
  * takes the input and the desired output attribute sets
  * sets up the build environment
  * run the build hooks


<!-- end_slide -->


That's a lot of build hooks
===

# Not to worry, nix has sensible defaults
## Want to build a `cmake` project?
* Add

```
nativeBuildInputs = [ cmake ];
```

* Nix will run cmake hooks for you for configuring, building and installing a cmake project

<!-- end_slide -->

Packaging basics
===

Let's start simple with pure Nix, no flakes.

Use `nix-build` to build a nix expression.

# Let's create our first derivation!
## Hello, World!

<!-- column_layout: [2, 2] -->
<!-- column: 0 -->
```bash +exec {2-13}
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
# Problem

The expression in is a function, which only produces its intended output if it is passed the correct arguments.
```nix
{ lib, stdenv, fetchurl }:
```

# Where do they come from?
* Right now nowhere
* But they are packages from `nixpkgs`

* Let's see how to use it.

<!-- end_slide -->

Building your first derivation
===

<!-- column_layout: [2, 2] -->
<!-- column: 0 -->
```bash +exec {3,4,7}
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
# Explanation
* `callPackage` automatically passes attributes from `pkgs` to the given function, if they match attributes required by that function’s argument attribute set. 
  * In this case, `callPackage` will supply `stdenv` and `fetchzip` to the function defined in `hello.nix`.
```nix {3, 7-10}
# hello.nix

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

# Important concepts

* We depend on a **specific version** of `nixpkgs`
  * that defines how to build and install a **specific version** of over 160.000 derivations
* Everything is nix code
* Every derivation is installed into the Nix store

<!-- end_slide -->

Let's build a shell script, with parameters
===

<!-- column_layout: [3, 2] -->
<!-- column: 0 -->
```bash +exec {2-16}
nix-build - <<'EOF'
let  
  # shorthand for fetching a default version of nixpkgs
  # this is defined in Nix configuration
  pkgs = import <nixpkgs> { };
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

* This generated a symbolic link `$(pwd)/result`

```bash +exec
ls -l $(pwd)/result
```

<!-- pause -->
* Containing the script ./result
```bash +exec_replace
ls -lR ./result/*
```

<!-- pause -->

* It's a reproducible shell script:
  * `writeShellScriptBin` inserts/replaces the shebang with the version of bash used by the derivation 
```bash +exec_replace
cat ./result/bin/hello
```

<!-- pause -->

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
    * Note that it gets downloaded from a (nixpkgs') binary cache if available. 
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
# TODO

* First look into `default.nix`
* Edit the file `exercices/spacevecalg-nopython.nix`
* Build with `nix-build -A spacevecalg-nopython`
* Test the solution with `nix-build -A spacevecalg-nopython-solution`

```bash +exec
cd pkgs
nix-build -A spacevecalg-nopython-solution
ls -R ./result/* | less
cd ..
```
<!-- end_slide -->


Solution
===
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
# Upcoming: flakes, circular packaging or how to use it in practice
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
  description = "A flake️️";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
  };
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;
  };
}
```

<!-- column: 1 -->

# Structure is standardized

## Inputs are locked

* The first time you use the flake it records all inputs in a `flake.lock` file

```bash +exec
cd samples/hello-flake-simple
nix run .#packages.x86_64-linux.hello
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

Flakes framework - flake-parts
===

<!-- column_layout: [2, 2] -->
<!-- column: 0 -->
# Simplifies flake structure

```nix
{
  description = "A flake️️";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { pkgs, ... }: {
        packages.hello = pkgs.hello;
        packages.default = pkgs.hello;

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.hello
          ];

          shellHook = ''
            echo "Welcome to the dev shell!"
          '';
        };
      };
    };
}
```

<!-- column: 1 -->

# Let's explore

```bash +exec +acquire_terminal
kitty sh -c '
cd samples/hello-flake-parts
nix develop .#hello
'
```
<!-- end_slide -->

# Why is it nice?

# Try

```bash
nix flake show github:isri-aist/ismpc_walking/main
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
  nix develop github:isri-aist/ismpc_walking/main#mc-rtc-superbuild-ismpc-walking-controller
'
```

### Use

```
run-ismpc-walking-controller # auto-generated script to run the controller in mujoco
```


<!-- column: 1 -->
This will download:
* the latest ismpc-walking-controller from the main branch
  * mc-rtc framework
  * and its dependencies: footstep-planner-plugin, mc-joystick-plugin
  * mujoco
  * additional robots

<!-- end_slide -->

Exploring the dependency tree
===

# Nix knows it, let's exploit it

## Get the relevant store path to the controller

```bash +exec
nix build github:isri-aist/ismpc_walking/main#ismpc-walking-controller --print-out-paths
```

## Let's explore
<!-- pause -->

Use:
- Left/Right arrows to navigate
- `w` to see why we depend on a package

```bash +exec
out_path=$(nix build github:isri-aist/ismpc_walking/main#ismpc-walking-controller --print-out-paths)
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

Circular packaging and flakoboros
===

# One main repository mc-rtc/nixpkgs

* Contains default derivations for all packages we care about
* A flake to use these packages directly
* An overlay exposing all packages with options (with-ros, etc)
* A flake module to simplify use in your own flakes
* CI: builds and pushes an official version to the binary cache

# Each package repository

* Contains a flake that builds the package with some properties overridden
  * source: build from the local source tree
  * dependencies: we can override dependencies as needed
* CI: builds and pushes an up-to-date version to the binary cache


<!-- end_slide -->

Flakoboros
===

[Flakoboros documentation](https://gepetto.github.io/flakoboros)

# Framework developped by Guilhem Saurel @ LAAS
## Simplifies how to override dependencies

```nix
{
  description = "CHANGEME";

  inputs.mc-rtc-nix.url = "github:mc-rtc/nixpkgs";

  outputs =
    inputs:
    inputs.mc-rtc-nix.lib.mkFlakoboros inputs (
      { lib, ... }:
      {
        overrideAttrs.CHANGEME = {
          src = lib.fileset.toSource {
            root = ./.;
            fileset = lib.fileset.unions [
              ./CHANGEME
            ];
          };
        };
      }
    );
}
```
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

mc-rtc/nixpkgs
===

[mc-rtc/nixpkgs documentation](https://mc-rtc.github.io/nixpkgs/)

<!-- column_layout: [2, 2] -->
<!-- column: 0 -->
# Built on top of flakoboros

* All packages from LAAS / INRIA available
* All ros packages available
* Flake module to provide "mc-rtc-superbuild" shells

# mc-rtc-superbuild shells

```nix
{
  description = "ismpc-walking-controller";

  inputs = {
    mc-rtc-nix.url = "github:mc-rtc/nixpkgs";
    flake-parts.follows = "mc-rtc-nix/flake-parts";
    systems.follows = "mc-rtc-nix/systems";
    gepetto.follows = "mc-rtc-nix/gepetto";
    private-trigger.follows = "mc-rtc-nix/private-trigger";
    ccache-trigger.follows = "mc-rtc-nix/ccache-trigger";
  };

  outputs =
    inputs:
    inputs.mc-rtc-nix.lib.mkMcRtcController 
      inputs "ismpc-walking-controller" (
      { lib, ... }:
      {
        # whether to include private packages
        mc-rtc-nix.overlays.private =
          inputs.private-trigger.value;
        # whether to build with ccache
        mc-rtc-nix.overlays.ccache =
          inputs.ccache-trigger.value;

        # this configuration is auto-generated
        # mc-rtc-superbuild = {} 

        flakoboros = {
          overrideAttrs.ismpc-walking-controller = {
            src = lib.cleanSource ./.;
          };
        };
      }
    );
}
```


<!-- column: 1 -->

In this example the `mc-rtc-superbuild` configuration is generated from the controller's derivation:

```nix
{
mc-rtc-superbuild =
{ pkgs, ... }:
{
  enable = true; # enables the mc-rtc-superbuild module
  configurations = {
    ismpc-walking-controller = {
      extends = [ "minimal" ];
      enabled = "ismpc_walking";
      runtime = {
        robots = [ pkgs.mc-hrp4 pkgs.mc-hrp5-p ]; #...
        controllers = [];
        plugins = [ pkgs.mc-joystick-plugin pkgs.mc-rtc-footstep-planner-plugin ];

        apps = [
          pkgs.mc-rtc-magnum
        ];
      };
      devel = {
        controllers = [ pkgs.ismpc-walking-controller];
      };
    };
  };
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



<!-- alignment: center -->
<!-- jump_to_middle -->
<!-- font_size: 4 -->
Need a break?
===
<!-- font_size: 1 -->
# Upcoming: live coding
<!-- end_slide -->

Simple c++ template
===

```
mkdir test-cpp
cd test-cpp
nix flake init -t github:mc-rtc/nixpkgs#flakoboros-new-cpp-package
```

* Using nix to build: `nix build -L .#cpp-example`
* To develop `nix develop .#cpp-example` and follow instructions

<!-- end_slide -->

mc_rtc controller
===

```
nix shell github:mc-rtc/nixpkgs#mc-rtc -c mc_rtc_new_fsm_controller Controller Controller
cd Controller
nix flake init -t github:mc-rtc/nixpkgs#controller
```

# We need to define a new package derivation
  * *yes there should be a template for this*
  * let's make it an example/exercice

# Solution:

<!-- pause -->
```nix
{
  flakoboros = {
    packages.your-controller = {lib, mkMcRtcController, cmake, mc-rtc}:
      mkMcRtcController
      {
        pname = "your-controller"; version = "0.0.1";
        nativeBuildInputs = [ cmake ];
        propagatedBuildInputs = [ mc-rtc ];
        src = lib.cleanSource ./.;
        passthru.mc-rtc = {
          controller = {
            MainRobot = "JVRC1";
            Enabled = "Test";
          };
        };
      };
  };
}
```









