SHELL := /bin/sh

.PHONY: build test gas-report evidence validate clean

build:
	forge build

test:
	forge test -vvv

gas-report:
	forge test --gas-report > evidence/gas-report.txt

evidence:
	python3 scripts/generate_evidence.py

validate:
	python3 scripts/generate_evidence.py --validate-only evidence/evidence.json

clean:
	rm -rf out cache broadcast coverage evidence/evidence.json evidence/gas-report.txt evidence/last-forge-test-output.log