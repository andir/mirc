let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {
    overlays = [
      (self: super: {
        npmlock2nix = self.callPackage sources.npmlock2nix { };
      })
    ];
  };

  src = pkgs.applyPatches {
    name = "matrix-appservice-irc-src";
    src = sources.matrix-appservice-irc;
    patches = [
      #      (builtins.fetchurl "https://patch-diff.githubusercontent.com/raw/matrix-org/matrix-appservice-irc/pull/1337.patch")
      (builtins.fetchurl "https://patch-diff.githubusercontent.com/raw/matrix-org/matrix-appservice-irc/pull/1339.patch")
    ];
  };

  pkg = pkgs.npmlock2nix.build {
    name = "matrix-appservice-irc";
    inherit src;
    #buildInputs = [ ];

    #buildPhase = ''
    #  ls -la
    #  npm run-script build
    #'';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/node_modules
      cp -r $PWD $out/node_modules/matrix-apservice-irc
      runHook postInstall
    '';

    postFixupPhase = ''
      makeWrapper '${pkg.node_modules.nodejs}/bin/node' "$out/bin/matrix-appservice-irc" \
      --set NODE_MODULES ${pkg.node_modules} \
       --add-flags "$out/lib/node_modules/matrix-appservice-irc/app.js"
    '';
  };
in
pkg
