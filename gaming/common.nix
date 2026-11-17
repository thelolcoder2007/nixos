{ inputs, ... }:
{
	# I hate this I hate this I hate this so much why did you do this to me
	# Some context: I want to run both Rust and Satisfactory dedicated servers on the same host.
	# But when using normal `imports = [ inputs.[...] ];` it fails with something that is set as duplicate.
	# I don't know WHY is happens, I just have to deduplicate the import in this god awful way
	# I can't even have a global let binding for the steamcmd-servers presets, I have to do those every module
	# I hate this so much I want to pull my eyes out
	# Nix is dumb why did we ever do this
	# </rant>
  imports = [
    inputs.steamcmd-servers.nixosModules.steamcmd-servers
  ];
}
