{
  description = "CHANGEME";

  inputs.mc-rtc-nix.url = "github:mc-rtc/nixpkgs";

  outputs =
    inputs:
    inputs.mc-rtc-nix.lib.mkFlakoboros inputs (
      { ... }:
      let
        makeSlidePackage =
          slideName: html:
          {
            stdenv,
            presenterm,
            kitty,
            lib,
            buildHtml ? html,
            ...
          }:
          stdenv.mkDerivation {
            name = slideName;
            version = "1.0.0";
            outputs = [ "out" ] ++ lib.optional buildHtml "html";
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

            ''
            + lib.optionalString buildHtml ''
              mkdir -p $html
              ${presenterm}/bin/presenterm --export-html -c config.yaml ./${slideName}/slides.md
              cp ./${slideName}/slides.html $html/ || true
            '';
            meta.mainProgram = "run-slides";
          };

        slideNames = [
          "journee_departement_rob_2026"
          "nix_workshop_lirmm_2026"
        ];

        makeBothPackages = slideName: {
          "${slideName}" = makeSlidePackage slideName false;
          "${slideName}_html" = makeSlidePackage slideName true;
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
                    drv = makeSlidePackage slideName true {
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
          };
      in
      {
        rosDistros = [ ];
        packages = allPackages // {
          slides-html = slidesHtml;
        };
      }
    );
}
