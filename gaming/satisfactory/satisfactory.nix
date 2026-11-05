{ inputs, lib, ... }:

let
  presets = import (inputs.steamcmd-servers + "/presets.nix") { inherit lib; };
in
{
  imports = [
    inputs.steamcmd-servers.nixosModules.default
  ];
  services.steamcmd-servers = {
    enable = true;
    servers.satisfactory = lib.recursiveUpdate presets.satisfactory {
      executableArgs = [
        "-Port 7777"
        "-ReliablePort 8888"
        "-log"
        "-unattended"
      ];
      beta = lib.mkForce null; # Because for some fuckass reason steamcmd-servers wants me to run the beta version :(((
      # > beta = "experimental";
      ports = lib.mkForce { };
      resources.memoryLimit = lib.mkForce "8G";
    };
  };
  networking.firewall = {
    allowedTCPPorts = [
      8888
    ];
    allowedUDPPorts = [
      7777
    ];
  };
}
