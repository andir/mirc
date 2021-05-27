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
    name = "matrix-dimensions";
    src = sources.matrix-dimension;
    patches = [
    ];
  };

  pkg = pkgs.npmlock2nix.build {
    name = "matrix-dimensions";
    inherit src;

    node_modules_attrs = {
      nativeBuildInputs = [ pkgs.pkgconfig pkgs.python3 pkgs.python2 ];
      buildInputs = [ pkgs.vips ];
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/node_modules
      cp -r build $out/node_modules/matrix-dimensions
      runHook postInstall
    '';

    postFixup = ''
      mkdir -p $out/bin
     makeWrapper '${pkg.node_modules.nodejs}/bin/node' "$out/bin/matrix-dimensions" \
       --set NODE_PATH ${pkg.node_modules}/node_modules \
       --add-flags "$out/node_modules/matrix-dimensions/app/index.js"
   '';
  };
in
pkg
