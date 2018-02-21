contracts.json:
	solc --combined-json abi,bin,bin-runtime contracts/*.sol > $@
