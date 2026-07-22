# Tarefas

Cada tarefa exige código, testes e documentação correspondentes. O relatório deve listar arquivos, decisões, comandos executados, resultados e riscos.

## Entrega A

### 0 — Governança e esqueleto

Status: concluída em 2026-07-22.

Criar `AGENTS.md`, documentos, diretórios sob demanda e especificação. Não criar árvores vazias.

Aceite: links válidos, escopo explícito e tarefas rastreáveis.

### 1 — Projeto Python reproduzível

Status: concluída em 2026-07-22.

Configurar `pyproject.toml`, Python 3.13, `uv.lock`, pacote, Ruff, Mypy e Pytest.

Aceite: sync, import, lint, type check e testes mínimos passam.

### 2 — Configuração e aplicação

Status: próxima.

Settings, invariantes, logging, request ID, factory, lifespan, erros e health inicial.

Aceite: import sem rede, liveness 200 e erro interno seguro.

### 3 — Domínio e contratos

IDs, checksum, entidades, versões, chunks, resultados, citações e seções de resposta.

Aceite: domínio não importa frameworks/SDKs e IDs determinísticos têm testes.

### 4 — Ports, adapters e fakes

Contratos e fakes para chat, embeddings, PostgreSQL, Qdrant, web search e observabilidade; adapters OpenAI, Maritaca e Hugging Face.

Aceite: seleção por settings, capabilities validadas e testes sem rede.

### 5 — Processamento documental

PDF/TXT, limites, extração, chunking e metadatação nos modos determinístico/LLM.

Aceite: fixtures válidas, inválidas, excessivas e adversariais; fallback sem OpenAI real.

### 6 — Persistência

Migrations/catálogo PostgreSQL e coleção/índices/operações Qdrant.

Aceite: integração real, constraints de versão e filtro pela versão ativa.

### 7 — Ingestão e exclusão

Idempotência, preparação, ativação transacional, reconciliação e exclusão física.

Aceite: concorrência e falhas simuladas preservam a versão ativa; exclusão remove ambos os stores.

### 8 — Retrieval e citações

Top-k, score, filtros allowlisted, budget, deduplicação e verificador.

Aceite: retrieval vazio explícito e citação inventada rejeitada.

### 9 — LangGraph

Estado, prompts, tool budget, dados não confiáveis, insuficiência e seções por proveniência.

Aceite: injection não muda regras; citações documentais/web são observadas; grafo termina no limite.

### 10 — API por perfis

Chat, coleções, documentos, limites, OpenAPI público/operador e startup seguro.

Aceite: perfil público não contém rotas administrativas; produção rejeita configuração insegura.

### 11 — Frontend

UI sem framework, mesma origem, chat, citações, upload/operator UI local, estados e erros.

Aceite: sem `innerHTML` não confiável, sem URL fixa e smoke flow completo.

## Entrega B

### 12 — Observabilidade

Logs JSON, métricas, redaction, Langfuse opcional e readiness real.

Aceite: correlação por request ID, nenhum segredo/conteúdo nos logs e fail-open do Langfuse.

### 13 — Containers, CI e GCP

Dockerfile, Compose dev/prod, proxy HTTPS, volumes, backups, CI, Secret Manager e guia Compute Engine.

Aceite: build/smoke passam; PostgreSQL/Qdrant privados; guia cobre criação e remoção dos recursos cobrados.

### 14 — Evals e encerramento

Dataset, runner, baseline, ADRs restantes, documentação e runbooks.

Aceite: métricas reproduzíveis, links válidos e limitações/riscos documentados.
