# Plano de execução pelo Codex

Este documento descreve como executar o projeto. Ele não replica requisitos ou decisões detalhadas, que vivem nos documentos indicados abaixo.

## Fontes de verdade

| Assunto | Documento |
|---|---|
| requisitos e fora de escopo | [spec.md](specs/001-production-agentic-rag/spec.md) |
| sequência e dependências | [plan.md](specs/001-production-agentic-rag/plan.md) |
| tarefas e critérios de aceite | [tasks.md](specs/001-production-agentic-rag/tasks.md) |
| regras operacionais do Codex | [AGENTS.md](AGENTS.md) |
| arquitetura | [ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| dados e versionamento | [DATA_MODEL.md](docs/DATA_MODEL.md) |
| API | [API.md](docs/API.md) |
| providers | [PROVIDERS.md](docs/PROVIDERS.md) |
| segurança | [THREAT_MODEL.md](docs/THREAT_MODEL.md) |
| testes | [TEST_PLAN.md](docs/TEST_PLAN.md) |
| observabilidade | [OBSERVABILITY.md](docs/OBSERVABILITY.md) |
| GCP e operação | [DEPLOYMENT.md](docs/DEPLOYMENT.md) |

## Modo de trabalho

1. Ler `AGENTS.md`, a tarefa corrente e os documentos diretamente relacionados.
2. Trabalhar em uma única tarefa numerada.
3. Fazer a menor mudança completa que satisfaça o aceite.
4. Atualizar testes e documentação junto ao comportamento.
5. Executar todos os checks aplicáveis.
6. Corrigir falhas antes de avançar.
7. Não alegar execução de comando que não ocorreu.
8. Registrar decisão material em ADR.
9. Encerrar com relatório verificável.

## Fases

### Entrega A — MVP

Tarefas 1–11: fundação, domínio, integrações, persistência, RAG, API e UI.

Marco: Compose com PostgreSQL/Qdrant reais, providers fake e smoke flow completo. Uma credencial de provider habilita execução real.

### Entrega B — Operacionalização

Tarefas 12–14: observabilidade, CI, containers endurecidos, GCP, backups, evals e documentação final.

Marco: publicação reproduzível em uma VM Compute Engine, HTTPS, secrets externos, backup/restore testado e instruções para interromper cobrança.

## Checks esperados

Os checks passam a existir conforme as tarefas introduzem suas ferramentas:

```bash
uv sync --all-groups
uv run ruff format --check .
uv run ruff check .
uv run mypy src
uv run pytest -q
uv run pytest tests/integration -q
uv run bandit -q -r src
uv run pip-audit
docker compose config
docker compose build
```

Não executar checks inexistentes apenas para preencher relatório; registrar por que ainda não se aplicam.

## Relatório por tarefa

- tarefa concluída;
- arquivos criados/alterados;
- decisões e suposições;
- comandos executados e resultados;
- riscos restantes;
- próxima tarefa.

## Próximo passo

Validar os links desta documentação e iniciar a Tarefa 1 em [tasks.md](specs/001-production-agentic-rag/tasks.md).
