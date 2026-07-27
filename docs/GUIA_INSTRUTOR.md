# Guia do Instrutor - signature-validation-01

## Objetivo da atividade

Demonstrar como uma assinatura valida, quando nao vinculada a um nonce, pode ser reutilizada para repetir um saque autorizado.

## Roteiro sugerido

1. Apresente a vault vulneravel e a origem da assinatura.
2. Mostre como o atacante replica a mesma chamada com o mesmo payload.
3. Execute o teste do contrato corrigido.
4. Discuta por que o nonce impede replay sem quebrar a autorizacao delegada.
5. Feche com a evidencia em JSON.

## Perguntas para debate

- O que torna uma assinatura reutilizavel?
- Por que deadline sozinho nao evita replay?
- Onde o nonce deve viver: no contrato, no payload ou nos dois?
- O negative control evita qual falso positivo?
- Como o fuzz ajuda a validar a faixa de nonce e valor?

## Resultado esperado

O participante deve concluir que:

- assinatura valida nao basta sem anti-replay;
- nonce e expiracao sao controles complementares;
- a validacao precisa cobrir exploit, fix e negative control;
- evidencia automatizada reduz ambiguidade na avaliacao.

## Materiais de apoio

- `README.md`
- `docs/ROTEIRO.md`
- `docs/CHECKLIST_AUDITORIA.md`
