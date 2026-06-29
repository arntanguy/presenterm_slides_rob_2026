---
title: "Dévelopements et déploiements reproductibles (Nix)"
# sub_title: 
author: Arnaud TANGUY - CDD BIATSS - Appui a la recherche 
---

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

# nix run 

```bash +exec
echo "4 commandes: run, shell, build devel" | nix run nixpkgs#cowsay
```

<!-- end_slide -->

# Et si on exécutait cette présentation ?

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

# nix develop
## Et si on codais?

```bash
nix shell nixpkgs#gh # oops, il nous manque l'outil cli de github!
gh login
gh repo clone jrl-umi3218/SpaceVecAlg
gh pr checkout 74
nix develop .#spacevecalg
cmake -B build $cmakeFlags
cmake --build build
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

# ANR Rolkneematics

```bash +exec +acquire_terminal
kitty sh -c '
  nix develop github:arntanguy/panda_prosthesis/98ceb5790e6e353a5605142b0f7c57029600f86d#panda-prosthesis-full -c sh -c "
    mc-rtc-magnum & 
    mc_rtc_ticker
  "
'
```

<!-- end_slide -->

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

- puis chaque repo (ex. `SpaceVecAlg`) modifie les dérivations pour:
  - compiler depuis les dernières sources
  - tester des changements (ex: bindings python)
  - en CI: build et push dans le cache binaire de la dernière version

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
