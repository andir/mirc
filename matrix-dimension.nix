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
    name = "matrix-dimension";
    src = sources.matrix-dimension;
    patches = [
    ];
  };

  pkg = pkgs.npmlock2nix.build {
    name = "matrix-dimension";
    inherit src;

    node_modules_attrs = {
      nativeBuildInputs = [ pkgs.pkgconfig pkgs.python3 pkgs.python2 ];
      buildInputs = [ pkgs.vips ];
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    outputs = [ "out" "web" ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      cp -r build/app $out/lib/matrix-dimension
      cp -r build/web $web
      runHook postInstall
    '';

    postFixup = ''
      mkdir -p $out/bin
     makeWrapper '${pkg.node_modules.nodejs}/bin/node' "$out/bin/matrix-dimension" \
       --set NODE_PATH ${pkg.node_modules}/node_modules \
       --add-flags "$out/lib/matrix-dimension/index.js"
   '';
  };
in
pkg
