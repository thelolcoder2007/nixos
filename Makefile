.SILENT: pull push update

update:
	nh os switch -u --commit-lock-file --target-host "thomas@10.0.116.125" -H "xenoi"
	nh os switch --target-host "thomas@10.0.116.9" -H "poseidon"
	${MAKE} pull

pull push:
	git push
	ssh thomas@10.0.116.125 "git -C /etc/nixos/nixos-repository pull"
	ssh thomas@10.0.111.14 "git -C /etc/nixos/nixos-repository pull"

build:
	nix flake update --commit-lock-file
	nh os build -H apollo -d never
	nh os build -H athena -d never
	nh os build -H hera -d never
	nh os build -H hermes -d never
	nh os build -H poseidon -d never
	nh os build -H xenoi -d never
	nh os build -H zeus -d never
	rm result
