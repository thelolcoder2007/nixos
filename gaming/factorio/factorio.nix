{ inputs, lib, pkgs, ... }:

{
  services.factorio = {
    enable = true;
    admins = [

    ];
    mods =
      let
        modDir = inputs.factoriomods.outPath;
        modList = lib.pipe modDir [
          builtins.readDir
          (lib.filterAttrs (_k: v: v == "regular"))
          (lib.mapAttrsToList (k: _v: k))
          (builtins.filter (lib.hasSuffix ".zip"))
        ];
        validPath =
          modFileName:
          builtins.path {
            path = modDir + "/${modFileName}";
            name = lib.strings.sanitizeDerivationName modFileName;
          };
        modToDrv =
          modFileName:
          pkgs.runCommand "copy-factorio-mods" { } ''
            mkdir $out
            ln -s '${validPath modFileName}' $out/'${modFileName}'
          ''
          // {
            deps = [ ];
          };
      in
      map modToDrv modList;
    loadLatestSave = true;
    openFirewall = true;
    autosave-interval = 10;
    description = "NixOS-based Factorio dedicated server";
    game-name = "NixOS-factorio";
    lan = true;
    bind = "[::]";
    saveName = "nixos-1";
    nonBlockingSaving = true;
    requireUserVerification = true;
  };
  nixpkgs.config.allowUnfree = true;
}
