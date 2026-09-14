{
  config,
  inputs,
  lib,
  emulatedHost,
  ...
}:

let
  hostname = if emulatedHost == "" then config.networking.hostName else emulatedHost;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  sops = {
    defaultSopsFile = ../secrets/${hostname}.yml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = lib.mkForce [
      "/nix/persist/var/lib/sops-nix/key.txt"
    ];
    gnupg.sshKeyPaths = lib.mkForce [ ];
  };
}
