{
  lib,
  fetchFromGitHub,
  pkgs,
  ...
}:

pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vertd";
  version = "0-unstable-2026-10-16";

  src = fetchFromGitHub {
    owner = "vert-sh";
    repo = "vertd";
    rev = "9ef87ade85067812742854fa96b8d4d59dde9a29";
    hash = "sha256-BQACApiQbYsduzLtwt0cxWKpMcZ0x1Quzn05GqRO3ME=";
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
