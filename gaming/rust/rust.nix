{ inputs, lib, ... }:

let
  presets = import (inputs.steamcmd-servers + "/presets.nix") { inherit lib; };
in
{
  imports = [ ../common.nix ];
  services.steamcmd-servers = {
    enable = lib.mkDefault true;
    servers.rustds = lib.recursiveUpdate presets.rust {
      enable = true;
      executableArgs = lib.mkForce [
        "-batchmode"
        "+server.port 28015"
        "+rcon.port 28016"
        "+server.level Procedural Map"
        "+server.worldsize 4000"
        "+server.maxplayers 100"
        "+server.hostname \"NixOS Rust Server\""
      ];
      ports = lib.mkForce { };
      resources.memoryLimit = lib.mkForce "8G";
    };
  };
  networking.firewall.allowedTCPPorts = [ 28015 ];
  networking.firewall.allowedUDPPorts = [ 28015 ];
  # My main firewall will pick this up anyways, but let's catch it in case that doesn't happen:
  networking.firewall.extraInputRules = ''
    	ip saddr { 10.0.111.0/24, 10.0.116.0/24 } meta l4proto { tcp, udp } th dport 28016 accept;
    	ip6 saddr 2a07:54c1:4932::/48 meta l4proto { tcp, udp } th dport 28016 accept;
  '';
}
