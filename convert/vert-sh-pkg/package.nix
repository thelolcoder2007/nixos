{
  env ? {
    HOSTNAME = "localhost:5173";
    PLAUSIBLE_URL = "https://plausible.example.com";
    ENV = "production";
    VERTD_URL = "https://vertd.vert.sh";
    DISABLE_ALL_EXTERNAL_REQUESTS = "false";
    DISABLE_FAILURE_BLOCKS = "false";
    DONATION_URL = "https://donations.vert.sh";
    STRIPE_KEY = "pk_live_51TlrPaFTPjkhEGBSu5Kwy5jJQYxcX5yUUHXiH5g7Xzvb0NKzDqbooc126HjlW35uUkfAgQN2ruEoCuyQynoxpKaA00ojFgQ116";
  },
  lib,
  pkgs,
  fetchFromGitHub,
  bun2nix,
  ...
}:

let
  inherit (lib) mapAttrsToList concatStringsSep;
  envFile = pkgs.writeText "vert-sh.env" (
    concatStringsSep "\n" (mapAttrsToList (k: v: "PUB_${k}=${v}") env)
  );
in
bun2nix.mkDerivation (finalAttrs: {
  pname = "vert-sh";
  version = "0-unstable-2026-10-04";

  src = fetchFromGitHub {
    owner = "vert-sh";
    repo = "vert";
    rev = "3e95d75da8bc9705b6a3879596fe2f0d57635d7b";
    hash = "sha256-ThMmmJ4nQnJBB7vM6oLIfkf2ndDOHogJkUenBUFRG4Y=";
  };

  packageJson = "${finalAttrs.src}/package.json";

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
    useFakeNode = false;
  };

  patches = [
    ./all-encompassing.patch
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
  };
})
