{
  lib,
  fetchFromGitHub,
  pkgs,
  ...
}:

pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vertd";
  version = "0-unstable-2026-10-08";

  src = fetchFromGitHub {
    owner = "vert-sh";
    repo = "vertd";
    rev = "bbcd802a15fc63c01d41949d61b7bd5c78789853";
    hash = "sha256-kC0nf7e6PfUvbfpmLFJPD5KOOBpHGSkEFypJWAsim/E=";
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
