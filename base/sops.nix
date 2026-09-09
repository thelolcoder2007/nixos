{
  config,
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  sops = {
    defaultSopsFile = ../secrets/${config.networking.hostName}.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = lib.mkForce [
      "/nix/persist/var/lib/sops-nix/key.txt"
    ];
    gnupg.sshKeyPaths = lib.mkForce [ ];
  };
}
