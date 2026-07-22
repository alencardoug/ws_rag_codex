# ADR 0004 — Perfis público e operador

- Status: aceito
- Data: 2026-07-22

## Contexto

Não se deseja solicitar uma chave administrativa no navegador, e credenciais de providers não autenticam usuários.

## Decisão

O perfil público não registra rotas administrativas. O perfil operador fica em loopback e é acessado localmente ou por túnel SSH/IAP. Uma administração web pública futura exige IAP/OIDC.

## Consequências

O MVP evita credencial compartilhada e reduz superfície. Operação remota requer túnel. OpenAPI e testes existem por perfil.
