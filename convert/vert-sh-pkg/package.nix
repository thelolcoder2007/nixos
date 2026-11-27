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
          ENV = "production";
          DONATION_URL = "https://donations.vert.sh";
          STRIPE_KEY = "pk_live_51TlrPaFTPjkhEGBSu5Kwy5jJQYxcX5yUUHXiH5g7Xzvb0NKzDqbooc126HjlW35uUkfAgQN2ruEoCuyQynoxpKaA00ojFgQ116";
        }
      )
    )
  );
in
bun2nix.mkDerivation (finalAttrs: {
  pname = "vert-sh";
  version = "0-unstable-2026-11-27";

  src = fetchFromGitHub {
    owner = "vert-sh";
    repo = "vert";
    rev = "5f014fb6fc9fadf17ac226741dd25058a6092c96";
    hash = "sha256-z88VVrZz8NeyzFiVTh2sk8nyKZw+MZ1nRPIOMjExv1g=";
  };

  packageJson = "${finalAttrs.src}/package.json";

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
    useFakeNode = false;
  };

  patches = [
    ./0002-bun.patch
  ];

  postPatch =
    let
      vectorizerWasmTgz = builtins.fetchurl {
        url = "https://registry.npmjs.org/@neplex/vectorizer-wasm32-wasi/-/vectorizer-wasm32-wasi-0.1.0.tgz";
        sha256 = "sha256:136yqn8nwfz8dhcqxr2lkc0glgyd0jfsflmm989rwb2zwh551k1q";
      };
    in
    ''
      cp ${vectorizerWasmTgz} vectorizer-wasm32-wasi-0.1.0.tgz
    '';

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
