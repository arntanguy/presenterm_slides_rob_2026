{
  description = "CHANGEME";

  inputs.mc-rtc-nix.url = "github:mc-rtc/nixpkgs";

  outputs =
    inputs:
    inputs.mc-rtc-nix.lib.mkFlakoboros inputs (
      { ... }:
      let
        makeSlidePackage =
          slideName:
          {
            stdenv,
            presenterm,
            kitty,
            lib,
            ...
          }:
          stdenv.mkDerivation {
            name = slideName;
            version = "1.0.0";
            outputs = [
              "out"
              "html"
            ];
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

        slideNames = [
          "journee_departement_rob_2026"
          "nix_workshop_lirmm_2026"
          "nix_workshop_jrl_2026"
        ];

        makeBothPackages = slideName: {
          "${slideName}" = makeSlidePackage slideName;
        };

        allPackages = builtins.foldl' (acc: slideName: acc // makeBothPackages slideName) { } slideNames;

        # Collect all html outputs and generate index.html
        slidesHtml =
          {
            stdenv,
            lib,
            presenterm,
            kitty,
            ...
          }:
          stdenv.mkDerivation {
            name = "slides-html";
            buildCommand = ''
              mkdir -p $out
              # Copy all slides.html to $out and rename
              ${lib.concatStringsSep "\n" (
                map (
                  slideName:
                  let
                    drv = makeSlidePackage slideName {
                      inherit
                        stdenv
                        presenterm
                        kitty
                        lib
                        ;
                    };
                  in
                  ''
                    cp ${drv.html}/slides.html $out/${slideName}.html
                  ''
                ) slideNames
              )}
              # Generate index.html
              cat > $out/index.html <<EOF
              <html>
              <body>
              <h1>Slides Index</h1>
              <ul>
              ${lib.concatStringsSep "\n" (
                map (slideName: "<li><a href=\"${slideName}.html\">${slideName}</a></li>") slideNames
              )}
              </ul>
              </body>
              </html>
              EOF
            '';

            shellHook = ''
              echo "-------"
              echo "To use the slides, run:"
              echo "$ presenterm -x <folder>/slides.md"
              echo ""
              run_kitty_() {
                kitty sh -c "presenterm \"$@\""
              }
              export -f run_kitty
              echo "Note: some terminals do not have the full feature set needed by presenterm. For best result, use 'kitty' as:"
              echo "$ run_kitty -x <folder>/slides.md"
              echo ""
              echo "Note: run_kitty is an alias for:"
              declare -f run_kitty
              echo ""
              echo "Use: Ctrl +/- to increase/decrease font size"
              echo "-------"
            '';
          };
      in
      {
        packages = allPackages // {
          slides-html = slidesHtml;
        };
      }
    );
}
