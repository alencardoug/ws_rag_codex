# Plano de testes

## Princípios

- suíte normal não usa OpenAI, Maritaca, Hugging Face ou busca web reais;
- fakes são determinísticos;
- correção de segurança recebe teste de regressão;
- testes com containers ficam marcados e separados dos unitários.

## Camadas

### Unitários

Configuração, IDs, segurança, extração, chunking, limites, citações, roteamento do grafo e serviços com fakes.

### Integração

PostgreSQL e Qdrant reais em Compose: migrations, constraints, índices, idempotência, ativação, filtros e exclusão física.

### API

Contratos, profiles, status codes, uploads, erros seguros, OpenAPI e limites.

### Segurança

Prompt injection, XSS, disclosure, administração ausente no perfil público, upload excessivo, histórico/query/top-k e SSRF.

### End-to-end

Criar coleção, ingerir TXT/PDF, consultar com citação, atualizar, confirmar versão ativa e excluir.

### Concorrência e falhas

- dois uploads idênticos simultâneos;
- duas atualizações concorrentes;
- falha após upsert e antes da ativação;
- falha durante exclusão;
- PostgreSQL ou Qdrant indisponível.

### Evals RAG

Dataset versionado com pergunta, documentos/páginas esperados, critérios, injection e resposta insuficiente. Métricas: Recall@k, MRR, precisão de citação, groundedness, latência, tokens e custo.

## Gates

```bash
uv run ruff format --check .
uv run ruff check .
uv run mypy src
uv run pytest -q
uv run pytest tests/integration -q
uv run bandit -q -r src
uv run pip-audit
```

Cobertura deve ganhar limiar após o primeiro baseline; perseguir percentual sem avaliar caminhos críticos não substitui os cenários acima.
