{ pkgs, ... }:

{
  imports = [
    ./options/options.nix
  ];
  services.minecraft-server = {
    enable = true;
    package = pkgs.minecraftServers.vanilla-26-3; # Force minecraft server version
    dataDir = "/opt/mcserver_26.3";
    declarative = true;
    eula = true;
    openFirewall = true;
    jvmOpts = "-Djava.net.preferIPV4stack=false -Djava.net.preferIPv6Addresses=true -Xms1024M -Xmx2048M";
    whitelist = {
      # keep-sorted start
      bitjammer66 = "8b05ee6a-5029-45e1-ad21-bc3fe4668dfe";
      gamemax2007 = "c3b97809-1aba-4c4b-a9f6-06f86a59188c";
      larsdeblaze = "60d1a6e2-792a-4e1c-9ed9-e22c13e18328";
      vladimir1989 = "4471b323-eaac-4112-ae0c-99f9fa0fdb06";
      # keep-sorted end
    };
    ops = [
      {
        name = "gamemax2007";
        uuid = "c3b97809-1aba-4c4b-a9f6-06f86a59188c";
        bypassesPlayerLimit = true;
      }
      {
        name = "bitjammer66";
        uuid = "8b05ee6a-5029-45e1-ad21-bc3fe4668dfe";
        bypassesPlayerLimit = true;
      }
      {
        name = "larsdeblaze";
        uuid = "60d1a6e2-792a-4e1c-9ed9-e22c13e18328";
        bypassesPlayerLimit = true;
      }
      {
        name = "vladimir1989";
        uuid = "4471b323-eaac-4112-ae0c-99f9fa0fdb06";
        bypassesPlayerLimit = true;
      }
    ];
    serverProperties = {
      # keep-sorted start
      allow-flight = true;
      difficulty = "normal";
      gamemode = 0;
      log-ips = true;
      server-port = 25678;
      white-list = true;
      # keep-sorted end
    };
  };
}
