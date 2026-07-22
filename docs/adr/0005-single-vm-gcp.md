# ADR 0005 — Uma VM GCP para a primeira publicação

- Status: aceito
- Data: 2026-07-22

## Contexto

O MVP usa FastAPI, PostgreSQL e Qdrant com persistência. O objetivo é publicar sem Kubernetes ou composição de vários produtos gerenciados.

## Decisão

Executar `compose.prod.yaml` em uma VM Compute Engine com persistent disk, proxy HTTPS, Secret Manager e bancos em rede interna.

## Consequências

A arquitetura é simples e portátil, mas patching, backups, capacidade e disponibilidade da VM são responsabilidade do projeto. Cloud Run/Cloud SQL permanecem evolução possível.
