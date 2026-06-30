{
  description = "CHANGEME";

  inputs.mc-rtc-nix.url = "github:mc-rtc/nixpkgs";

  outputs =
    inputs:
    inputs.mc-rtc-nix.lib.mkFlakoboros inputs (
      { lib, ... }:
      {
        # overrideAttrs.CHANGEME = {
        #   src = lib.fileset.toSource {
        #     root = ./.;
        #     fileset = lib.fileset.unions [
        #       ./CHANGEME
        #     ];
        #   };
        # };
        rosDistros = [ ];
        packages = {
          rob_2026 =
            {
              stdenv,
              presenterm,
              kitty,
              ...
            }:
            stdenv.mkDerivation {
              name = "rob_2026";
              version = "1.0.0";
              nativeBuildInputs = [
                presenterm
                kitty
              ];
              src = lib.cleanSource ./.;
              installPhase = ''
                # 1. Create the output directory structure
                mkdir -p $out/bin $out/share/slides

                # 2. Copy your slides and assets to a shared directory
                cp -r ./journee_departement_rob_2026/* $out/share/slides/

                # 3. Create a wrapper script in $out/bin
                cat <<EOF > $out/bin/run-slides
                #!/bin/sh
                # Execute presenterm pointing to the slides in the Nix store
                exec ${presenterm}/bin/presenterm -x "$out/share/slides/slides.md" "\$@"
                EOF

                # 4. Make the script executable
                chmod +x $out/bin/run-slides
              '';

              meta = {
                # Now mainProgram points to a valid, executable binary script
                mainProgram = "run-slides";
              };
            };
        };
      }
    );
}
