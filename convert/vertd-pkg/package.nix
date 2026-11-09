{
  lib,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  openssl,
  zstd,
  ...
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vertd";
  version = "0-unstable-2026-10-19";

  src = fetchFromGitHub {
    owner = "vert-sh";
    repo = "vertd";
    rev = "9bf1ea2a2981396d90b11c295d42784c60d1f98f";
    hash = "sha256-ooUYHHx+YeMfXUAjZja6e02yMkqyVMtvsVgKmcnZtic=";
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    pkg-config
  ];

  buildInputs = [
    openssl
    openssl.dev
    zstd
  ];

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  meta = {
    description = "VERT's solution to crappy video conversion services.";
    homepage = "https://github.com/VERT-sh/vertd";
    license = lib.licenses.gpl3;
    mainProgram = "vertd";
  };
})
