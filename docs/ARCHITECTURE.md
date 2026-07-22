# Arquitetura

## Objetivo

Construir um Agentic RAG profissional como monólito modular, executável localmente e publicável em uma única VM, sem Kubernetes ou microsserviços.

## Contexto

```text
Browser
  │ HTTPS
  ▼
Proxy ──► FastAPI / frontend estático
             │
             ├──► LangGraph ──► provider de chat / busca web
             ├──► PostgreSQL (catálogo e versão ativa)
             ├──► Qdrant (chunks e embeddings)
             └──► Langfuse opcional
```

## Módulos

- `api`: HTTP, schemas externos, middleware e composição de dependências.
- `services`: casos de uso de chat, ingestão, retrieval, documentos e coleções.
- `domain`: identidades, entidades, contratos e exceções sem dependência de infraestrutura.
- `graph`: estado, prompts, tools e workflow LangGraph.
- `document`: validação, extração, chunking e metadatação.
- `integrations`: PostgreSQL, Qdrant, providers de modelo, web search e Langfuse.

## Direção de dependências

```text
API → serviços → domínio
grafo → contratos de serviços/domínio
integrações → contratos do domínio
domínio → nenhuma infraestrutura
```

Routers não acessam SDKs. Clientes externos são criados e fechados pelo lifespan. Imports não iniciam rede.

## Perfis de execução

| Perfil | Superfície | Regra |
|---|---|---|
| `development` | UI e API locais completas | somente ambiente de desenvolvimento |
| `public` | chat e leitura permitida | não registra rotas de ingestão/administração |
| `operator` | operações administrativas | somente loopback ou túnel SSH/IAP |

Produção deve falhar na inicialização se administração for configurada no listener público.

## Fluxo de ingestão

1. Validar coleção, arquivo, tipo, tamanho e páginas.
2. Calcular `content_sha256`.
3. Localizar ou criar o `document_id` lógico.
4. Retornar idempotentemente se o conteúdo já estiver ativo.
5. Criar uma versão em estado `processing` no PostgreSQL.
6. Extrair, gerar metadados, dividir e criar embeddings.
7. Gravar chunks determinísticos no Qdrant, ainda invisíveis ao retrieval.
8. Validar a quantidade persistida.
9. Em transação PostgreSQL, marcar a versão como `active` e atualizar o ponteiro do documento.
10. Remover fisicamente a versão anterior e reconciliar resíduos de falhas.

## Fluxo de chat

1. Validar consulta, histórico, coleção e limites.
2. O grafo decide se retrieval é necessário dentro de um orçamento de tools.
3. Retrieval resolve a versão ativa no PostgreSQL e consulta Qdrant com filtro explícito.
4. Trechos entram no contexto como dados não confiáveis.
5. A resposta é separada em seções `retrieval`, `general_knowledge` e `web_search`.
6. A API monta citações documentais e web somente a partir de evidências observadas.

## Consistência

PostgreSQL é a fonte de verdade para coleção, documento, versão, estado e versão ativa. Qdrant pode conter pontos órfãos, mas eles não são recuperáveis sem uma versão ativa no catálogo. Não existe transação distribuída; reconciliação torna falhas parciais recuperáveis.

## Evolução

Cloud Run, Cloud SQL, worker, Redis, busca híbrida, reranking e OIDC são evoluções condicionadas a métricas ou necessidade real.
