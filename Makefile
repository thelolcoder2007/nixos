.SILENT: pull push update

update:
	nh os switch -u --commit-lock-file --target-host "thomas@10.0.116.125" -H "xenoi"
	nh os switch --target-host "thomas@10.0.111.14" -H "poseidon"
	${MAKE} pull

pull push:
	git push
	ssh thomas@10.0.116.125 "git -C /etc/nixos/nixos-repository pull"
	ssh thomas@10.0.111.14 "git -C /etc/nixos/nixos-repository pull"
