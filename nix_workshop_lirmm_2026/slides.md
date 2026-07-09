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

<!-- font_size: 4 -->
Does it though?
<!-- font_size: 2 -->
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

<!-- alignment: left -->
<!-- font_size: 4 -->
# Can you share it?
<!-- font_size: 2 -->
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

<!-- alignment: left -->
<!-- font_size: 4 -->
# Maybe you tried to do things right
<!-- font_size: 2 -->
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

<!-- alignment: left -->
<!-- font_size: 4 -->
# Now... 
<!-- font_size: 2 -->
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



<!-- alignment: left -->
<!-- font_size: 4 -->
# Nix to the rescue 
<!-- font_size: 2 -->
Nix is a purely functional declarative package manager. 
<!-- incremental_lists: true -->
<!-- font_size: 2 -->
- **Declarative**: specify your dependencies explicitely

<!-- incremental_lists: false -->
<!-- end_slide -->


<!-- alignment: center -->
<!-- new_lines: 5 -->
<!-- font_size: 4 -->
Tester mes changements? 
<!-- font_size: 3 -->
T'es sûr ?
<!-- new_lines: 1 -->
<!-- font_size: 1 -->
Installe ça¸ ça, ça et ça aussi, ah et pour ça compile il te faut x,y,z!
<!-- font_size: 1 -->
<!-- new_lines: 2 -->
Et ça met 30mn à compiler
<!-- end_slide -->

<!-- alignment: center -->
<!-- new_lines: 7 -->
<!-- font_size: 4 -->
Ça n'a pas fonctionné?
<!-- font_size: 3 -->
Ah, mais t'es sous Ubuntu 26?
<!-- font_size: 2 -->
Moi je suis sous 20 depuis le début de ma thèse
<!-- font_size: 1 -->
Mais surtout j'y touche pas, ça fonctionne comme ça !
<!-- end_slide -->

<!-- alignment: center -->
<!-- new_lines: 7 -->
<!-- font_size: 4 -->
Nix 
<!-- font_size: 3 -->
- Déclaratif
- Reproductible
- Rapide : cache binaire
- Linux, MacOS, Windows (WSL2)


<!-- end_slide -->



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

<!-- alignment: center -->
<!-- new_lines: 3 -->
<!-- font_size: 3 -->
Nix c'est 4 commandes!

<!-- font_size: 1 -->
<!-- alignment: left -->
# nix run 


<!-- font_size: 1 -->

```bash +exec
echo "4 commandes: run, shell, build devel" | nix run nixpkgs#cowsay
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
