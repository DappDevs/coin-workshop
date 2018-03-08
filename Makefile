.PHONY: contracts.json
contracts.json:
	solc --combined-json abi,bin,bin-runtime contracts/*.sol > $@

test: contracts.json
	py.test --assets-file $^ tests/
