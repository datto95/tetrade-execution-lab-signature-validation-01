# Checklist Rapida de Auditoria - Fluxos Baseados em Assinatura

## Origem da autorizacao

- [ ] Existe um signer confiavel claramente definido?
- [ ] A mensagem assinada inclui todos os campos relevantes?
- [ ] O dominio da assinatura e especifico ao contrato e ao contexto?

## Protecao contra replay

- [ ] Ha nonce, contador ou identificador unico por autorizacao?
- [ ] O nonce e consumido exatamente uma vez?
- [ ] Assinaturas antigas continuam invalidas apos uso?
- [ ] O deadline sozinho e insuficiente para impedir replay?

## Validacao criptografica

- [ ] O contrato valida o signer esperado?
- [ ] O contrato rejeita assinaturas com tamanho invalido?
- [ ] O contrato trata assinaturas expiradas e signer incorreto de forma distinta?

## Fluxo economico

- [ ] O valor autorizado e limitado por colateral, saldo ou orcamento?
- [ ] O receptor da autorizacao e o mesmo receptor executando a chamada?
- [ ] Existe risco de reutilizacao da mesma autorizacao em outro contexto?

## Cobertura de teste

- [ ] Existe exploit de replay?
- [ ] Existe teste do caminho protegido?
- [ ] Existe negative control com signer invalido ou assinatura expirada?
- [ ] Existe fuzz para nonce, valor e janela de validade?

## Evidencia

- [ ] O resultado e reproduzivel em ambiente limpo?
- [ ] A evidencia distingue exploit, fix e controle negativo?
- [ ] A documentacao explica claramente o anti-replay adotado?
