# Desenvolvimento

## Pré-requisitos

- Python 3.13;
- `uv`;
- Docker Engine com Compose;
- credencial de provider somente para execução real.

## Configuração

```bash
cp .env.example .env
uv sync --all-groups
docker compose up -d postgres qdrant
uv run alembic upgrade head
uv run uvicorn rag_production.main:app --reload
```

O modo fake deve permitir desenvolver e testar sem rede. `.env` nunca é versionado.

O `uv` usa a versão declarada em `.python-version` e pode gerenciar o Python 3.13 mesmo quando `python3.13` não está no `PATH`. `uv.lock` é versionado e CI/deploy devem usar `uv sync --all-groups --locked`.

## Qualidade

Consulte `TEST_PLAN.md` para os gates. Comandos devem aparecer explicitamente no Makefile e na documentação; atalhos não podem esconder o que executam.

## Disciplina de mudança

- uma tarefa numerada por vez;
- teste e documentação junto ao comportamento;
- não avançar com check aplicável quebrado;
- registrar decisão arquitetural material em ADR;
- reportar comandos realmente executados e riscos restantes.
