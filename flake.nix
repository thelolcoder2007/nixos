{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    factoriomods = {
      url = "path:/home/thomas/git/github/factorio-mods";
      flake = false;
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bun2nix = {
      url = "github:nix-community/bun2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
    dns = {
      url = "github:kirelagin/dns.nix/pull/54/head";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Not implemented yet, have to do some other stuff first
    # impermanence = {
    #   url = "github:nix-community/impermanence";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    steamcmd-servers = {
      url = "github:kagurazaka-ayano/steamcmd-servers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixpkgs,
      self,
      treefmt-nix,
      ...
    }@inputs:
    let
      treefmt-fmt = treefmt-nix.lib.evalModule nixpkgs.outputs.legacyPackages.x86_64-linux ./base/treefmt.nix;
    in
    {
      # for `nix fmt`
      formatter.x86_64-linux = treefmt-fmt.config.build.wrapper;
      # for `nix flake check`
      checks.x86_64-linux.formatting = treefmt-fmt.config.build.check self;

      nixosConfigurations =
        let
          emulatedHost = "pankration";
          inherit (nixpkgs) lib;
          hosts = {
            # Hera sees everything Zeus does (which is mostly sleeping with other women)
            # Therefore it is my monitoring server ~~and does the home-assistant stuff~~
            "hera" = {
              guid_root = "0";
              guid_boot = "0";
              vmwareHost = true;
              qemuHost = false;
            };
            # Hermes brings messages to everybody.
            # Therefore it runs my Matrix homeserver and the Matrix and IRC clients.
            "hermes" = {
              guid_root = "0";
              guid_boot = "0";
              vmwareHost = true;
              qemuHost = false;
            };
            # Pankration was a kind of MMA in ancient Greece.
            # It is the server I run my games on
            "pankration" = {
              guid_root = "0";
              guid_boot = "0";
              vmwareHost = true;
              qemuHost = false;
            };
            # Poseidon talks with a lot of creatures others can't understand.
            # Therefore it runs the BGP for DN42 (underwater)
            "poseidon" = {
              guid_root = "2b92fb35-d027-4244-8c68-c01e62d198dd";
              guid_boot = "8383-403B";
              vmwareHost = true;
              qemuHost = false;
            };
            # The nixos tryout server. I use it to test hosts, which means that I build it to be a lot of different hosts
            # It gets a lot of "foreigners", "xenoi", in its body.
            "xenoi" = {
              guid_root = "6b726067-dbb2-481e-a323-1f61855ca34e";
              guid_boot = "9159-0D98";
              vmwareHost = false;
              qemuHost = true;
            };
            # Zeus is the leader of the gods. It will serve DNS, DHCPv4,
            # and will generally be owner of the subnet 10.0.116.0/24
            "zeus" = {
              guid_root = "624b634a-f08c-4618-9e64-a1156b267f48";
              guid_boot = "99EE-28F5";
              vmwareHost = true;
              qemuHost = false;
            };
          };
        in
        lib.genAttrs (builtins.attrNames hosts) (
          host:
          lib.nixosSystem {
            modules = [
              ./hosts/${host}.nix
              (import ./hosts/hardware-configuration.nix {
                inherit lib;
                host = hosts.${host};
              })
            ];
            specialArgs = {
              inherit inputs;
              emulatedHost = "";
            };
          }
        )
        // {
          xenoi = lib.nixosSystem {
            modules = [
              ./hosts/xenoi.overrides.nix
              ./hosts/${emulatedHost}.nix
              (import ./hosts/hardware-configuration.nix {
                inherit lib;
                host = hosts.xenoi;
              })
            ];
            specialArgs = {
              inherit inputs;
              inherit emulatedHost;
            };
          };
        };
    };
}
