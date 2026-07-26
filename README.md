# signature-validation-01

[![CI](https://github.com/datto95/tetrade-execution-lab-signature-validation-01/actions/workflows/ci.yml/badge.svg)](https://github.com/datto95/tetrade-execution-lab-signature-validation-01/actions/workflows/ci.yml)

Didactic proof of concept for the Tetrade execution lab.

This lab demonstrates a common signature-validation pitfall:

- vulnerable path: valid signature can be replayed because authorization omits nonce tracking.
- fixed path: nonce-bound authorization prevents replay while keeping delegated execution.

## Lab scope

- `src/VulnerableSignatureVault.sol`: authorizer-signed claims with replay risk.
- `src/FixedSignatureVault.sol`: nonce-based replay protection.
- `src/SignatureReplayAttacker.sol`: simulator contract that attempts replay.
- `test/SignatureValidationExploit.t.sol`: exploit, fix, negative control, and fuzz tests.
- `scripts/generate_evidence.py`: reproducible JSON evidence generation and schema check.

## Prerequisites

- Foundry installed (`forge --version`)
- Python 3.10+

## Quick start

```bash
forge build
forge test -vvv
python3 scripts/generate_evidence.py
python3 scripts/generate_evidence.py --validate-only evidence/evidence.json
```

## Expected signals

- vulnerable contract allows two withdrawals using one signature.
- fixed contract allows first withdrawal and rejects replay with used nonce.
- invalid signer and expired authorization paths fail as expected.

## Useful commands

```bash
make build
make test
make gas-report
make evidence
make validate
```
