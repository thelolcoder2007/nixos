{
  env,
  lib,
  pkgs,
  fetchFromGitHub,
  bun2nix,
  ...
}:

let
  inherit (lib) mapAttrsToList concatStringsSep;
  envFile = pkgs.writeText "vert-sh.env" (
    concatStringsSep "\n" (
      mapAttrsToList (k: v: "PUB_${k}=${v}") (
        env
        // {
          DONATION_URL = "https://donations.vert.sh";
          STRIPE_KEY = "pk_live_51TlrPaFTPjkhEGBSu5Kwy5jJQYxcX5yUUHXiH5g7Xzvb0NKzDqbooc126HjlW35uUkfAgQN2ruEoCuyQynoxpKaA00ojFgQ116";
        }
      )
    )
  );
in
bun2nix.mkDerivation (finalAttrs: {
  pname = "vert-sh";
  version = "0-unstable-2026-11-13";

  src = fetchFromGitHub {
    owner = "vert-sh";
    repo = "vert";
    rev = "35ebeb1679eb0b1af3f099c03060cb89f72e70f8";
    hash = "sha256-jYRkNgOtKDPK99qTQ/t5/pTKQy57UlnPUtW3abJ+T68=";
  };

  packageJson = "${finalAttrs.src}/package.json";

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
    useFakeNode = false;
  };

  patches = [
    ./0001-package.patch
    ./0002-bun.patch
  ];

  buildPhase = ''
    runHook preBuild

    cp ${envFile} .env
    bun run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r build $out

    runHook postInstall
  '';

  meta = {
    description = "VERT is a file conversion utility that uses WebAssembly to convert files on your device instead of a cloud.";
    homepage = "https://vert.sh";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.all;
    broken = true;
  };
})
