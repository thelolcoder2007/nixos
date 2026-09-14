{
  lib,
  fetchFromGitHub,
  pkgs,
  ...
}:

pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vertd";
  version = "0-unstable-2026-09-11";

  src = fetchFromGitHub {
    owner = "vert-sh";
    repo = "vertd";
    rev = "e94eca2b47237d4e1d698b3bd1162111edcd45c6";
    hash = "sha256-/ksPeJ5ZdPBVTvxgK0B9aEPmHkBDbyCSn1Zjc8uUq/0=";
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
