{ inputs, ... }:
{
  imports = [
    inputs.steamcmd-servers.nixosModules.steamcmd-servers
  ];
}
