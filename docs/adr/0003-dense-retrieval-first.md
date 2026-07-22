# ADR 0003 — Dense retrieval primeiro

- Status: aceito
- Data: 2026-07-22

## Contexto

Busca híbrida e reranking ampliam complexidade antes de existir baseline.

## Decisão

Começar com embeddings dense, filtros controlados e avaliação versionada.

## Consequências

Consultas lexicais podem ter recall menor. Busca híbrida só será introduzida se evals demonstrarem ganho relevante e custo aceitável.
