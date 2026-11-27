<!-- markdownlint-disable MD013 -->

# nixos

## Setup

1. Boot into system like normal
2. `git clone https://github.com/thelolcoder2007/nixos <somewhere>`
3. Run `<somewhere>/setup/setup.sh`
4. Put GUIDs of disks into `flake.nix`
5. `sudo nixos-install --flake ".#<hostname>"`
6. Reboot

## TODO

- [x] Make nginx work modularly without weird `(import ./bullshit.nix)` shennanigans
- [x] Implement database/postgres.nix
- [x] Implement networking/server/HTTP/defaults.nix
- [x] Implement Poseidon
- [x] Find a better place for networking/server/BGP/DN42-cert.nix
- [x] Make sure the cert gets checked every couple days
- [x] Add ACME server
- [x] Make sure nixos hosts can receive certs from ACME server (`x.nginx.virtualHosts.<name>.localAcmeHost`)
- [ ] Add centralized logging facility to Hera
- [ ] Make all logs point to Hera instead of local files
- [ ] Set up pxeboot
- [ ] Dynamically add DN42 advertisement to Tailscale
- [ ] Make reverse-DNS automatically set its records based on the respective forward DNS
  - [x] IPv4
  - [ ] IPv6
- [ ] Add `nix-collect-garbage -d --except <the last derivation of these hosts>` makefile target
- [ ] Make use of new lk-jwt-service options (matrix-irc/livekit.nix)
- [x] Make up a name for games server
- [ ] Add games
  - [ ] Factorio
  - [x] Mindustry
  - [x] Minecraft
  - [ ] OpenRCT2
  - [x] OpenTTD
  - [x] Satisfactory
  - [ ] Rust
- [ ] Decrease the amount of secrets Xenoi can read (it is a worrying amount)
- [ ] Set up impermanence
