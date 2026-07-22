# ADR 0001 — Monólito modular

- Status: aceito
- Data: 2026-07-22

## Contexto

O produto exige API, agente, processamento documental e integrações, mas não possui demanda demonstrada por deploys independentes.

## Decisão

Usar um monólito modular com direção de dependência explícita e um único artefato de aplicação.

## Consequências

Deploy e testes são simples. Escala ocorre em conjunto. Um worker só será extraído quando ingestões longas ou concorrência justificarem o custo.
