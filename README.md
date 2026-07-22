# Agentic RAG seguro, testável e operacional

Implementação nova de um Agentic RAG profissional para ingestão de PDF/TXT e respostas com citações verificáveis.

## Visão

O sistema usa:

- FastAPI e frontend web simples na mesma origem;
- LangGraph para o fluxo agêntico;
- PostgreSQL como catálogo transacional;
- Qdrant para chunks e embeddings;
- OpenAI, Maritaca ou Hugging Face como providers configuráveis;
- PyMuPDF para PDF;
- Langfuse opcional;
- Docker Compose localmente e em uma VM do Compute Engine.

O projeto não depende de implementação anterior. Kubernetes, microsserviços, Redis, worker, busca híbrida e OIDC não fazem parte do MVP.

## Decisões centrais

- `document_id` é a identidade lógica estável.
- `content_sha256` identifica o conteúdo e garante idempotência.
- `version_id` identifica uma versão concreta.
- PostgreSQL ativa versões transacionalmente; Qdrant não é catálogo.
- falha de atualização preserva a versão ativa;
- exclusão é física nos dois stores;
- respostas separam `retrieval`, `general_knowledge` e `web_search`;
- o navegador nunca recebe chaves de providers;
- o perfil público não expõe ingestão ou administração;
- a publicação inicial usa uma única VM GCP com Compose.

## Entregas

### A — MVP funcional, seguro e publicável

Domínio, providers/fakes, processamento, PostgreSQL, Qdrant, ingestão versionada, retrieval, LangGraph, API e frontend.

### B — Operacionalização

Observabilidade, hardening, CI/CD, backup/restore, deployment GCP, evals e runbooks.

## Documentação

### Especificação e execução

- [Especificação](specs/001-production-agentic-rag/spec.md)
- [Plano técnico](specs/001-production-agentic-rag/plan.md)
- [Tarefas numeradas](specs/001-production-agentic-rag/tasks.md)
- [Plano resumido para o Codex](plano_replicacao_codex.md)
- [Regras para agentes](AGENTS.md)

### Design

- [Arquitetura](docs/ARCHITECTURE.md)
- [Modelo de dados](docs/DATA_MODEL.md)
- [Contratos da API](docs/API.md)
- [Providers e modelos](docs/PROVIDERS.md)
- [Modelo de ameaças](docs/THREAT_MODEL.md)

### Qualidade e operação

- [Plano de testes](docs/TEST_PLAN.md)
- [Observabilidade](docs/OBSERVABILITY.md)
- [Desenvolvimento](docs/DEVELOPMENT.md)
- [Deployment e GCP](docs/DEPLOYMENT.md)
- [Decisões arquiteturais](docs/adr/README.md)

## Estado atual

O repositório está na fase de planejamento. A implementação começa pela Tarefa 1; a Tarefa 0 fica concluída quando esta estrutura documental e seus links forem validados.
