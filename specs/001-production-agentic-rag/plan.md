# Plano técnico

## Entrega A — MVP funcional, seguro e publicável

1. Fundamentos do repositório e ferramentas.
2. Configuração, aplicação e health básico.
3. Domínio e contratos.
4. Ports, adapters e fakes.
5. Extração, chunking e metadatação.
6. PostgreSQL, migrations e Qdrant.
7. Ingestão versionada e exclusão física.
8. Retrieval e citações.
9. LangGraph e separação de proveniência.
10. API por perfis.
11. Frontend seguro e smoke flow.

Ao final, o stack roda com PostgreSQL/Qdrant reais e providers fake; uma credencial habilita execução real.

## Entrega B — Operacionalização

12. Logs, métricas, traces e readiness completo.
13. Containers endurecidos, CI e deployment Compute Engine.
14. Evals, baseline, documentação final e runbooks.

## Estratégia de implementação

- incrementos verticais pequenos;
- domínio antes de adapters;
- fake antes da integração real;
- migrations e contratos versionados;
- cada tarefa encerra com checks aplicáveis;
- nenhum componente opcional bloqueia o núcleo.

## Dependências críticas

```text
fundamentos → domínio → adapters → persistência
persistência + documentos → ingestão → retrieval → grafo → API/UI
MVP → observabilidade → GCP/CI → evals/runbooks
```

## Decisões

Consultar `docs/adr/`. Mudança nas decisões aceitas exige novo ADR que substitua o anterior, não edição silenciosa da justificativa histórica.
