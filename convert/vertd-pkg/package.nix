{
  lib,
  fetchFromGitHub,
  pkgs,
  ...
}:

pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vertd";
  version = "0-unstable-2026-09-25";

  src = fetchFromGitHub {
    owner = "vert-sh";
    repo = "vertd";
    rev = "24bff68d59c03e24914624ad78f7cc125b4870db";
    hash = "sha256-wXKN22QLH21YGcYGCQ5S9IHW5RvrhZMrnRLVW1pZUf0=";
  };

  nativeBuildInputs = with pkgs; [
    rustPlatform.bindgenHook
    pkg-config
  ];

  buildInputs = with pkgs; [
    openssl
    openssl.dev
  ];

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  meta = {
    description = "VERT's solution to crappy video conversion services.";
    homepage = "https://github.com/VERT-sh/vertd";
    license = lib.licenses.gpl3;
    mainProgram = "vertd";
  };
})
