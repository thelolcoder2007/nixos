{ lib, pkgs, ... }:

let
  modZips = [
    "squeak-through-2_0.2.1.zip"
  ];
  modDrvs = builtins.attrValues (
    lib.genAttrs modZips (
      modName: (pkgs.callPackage pkgs.factorio-utils.modDrv { src = ./mods/${modName}; })
    )
  );
in
{
  services.factorio = {
    enable = true;
    admins = [

    ];
    # mods = modDrvs;
    # mods-dat = ./mods.dat;
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
