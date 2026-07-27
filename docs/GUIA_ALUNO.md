# Guia do Aluno - signature-validation-01

## Objetivo

Explorar uma falha de validacao de assinatura em que a ausencia de controle de nonce permite replay de uma autorizacao valida.

## Requisitos

- Foundry instalado (`forge`, `cast`, `anvil`)
- Python 3.10+

## Passo a passo

1. Compile os contratos.

   ```bash
   forge build
   ```

2. Execute os testes.

   ```bash
   forge test -vvv
   ```

3. Gere a evidencia.

   ```bash
   python3 scripts/generate_evidence.py
   ```

4. Valide a evidencia gerada.

   ```bash
   python3 scripts/generate_evidence.py --validate-only evidence/evidence.json
   ```

## O que observar

- A vault vulneravel permite uso repetido da mesma assinatura.
- A vault corrigida rejeita replay com nonce ja usado.
- Assinaturas invalidas e autorizacoes expiradas falham como esperado.

## Testes-chave

- `testReplayDrainsVulnerableVault`
- `testReplayFailsAgainstFixedVault`
- `testNegativeControlInvalidSignerNoSignal`
- `testFuzzFixedClaimUsesUniqueNonce`
- `testFuzzExpiredAuthorizationAlwaysFails`

## Dica

Compare o digest assinado no caminho vulneravel e no caminho corrigido para entender onde o nonce bloqueia o replay.
