{
  imports = [
    ./options.nix
  ];
  services.mindustry-server = {
    enable = true;
    openFirewall = true;
  };
}
