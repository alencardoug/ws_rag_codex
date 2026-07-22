# Proposta melhorada — Agentic RAG seguro, testável e operacional

**Natureza do projeto:** implementação nova, orientada por esta especificação
**Data da proposta:** 22 de julho de 2026  
**Princípio central:** construir uma aplicação profissional de Agentic RAG, publicável e operacional, sem complexidade distribuída desnecessária

## Premissas do produto

A aplicação será um **Agentic RAG** que:

- recebe documentos;
- extrai, divide e indexa seus conteúdos;
- armazena embeddings no Qdrant;
- usa um agente LangGraph;
- permite ao modelo consultar documentos como ferramenta;
- gera respostas em linguagem natural com referências;
- expõe FastAPI;
- oferece uma interface web simples;
- integra observabilidade de LLM com Langfuse.

Não existe dependência de um projeto anterior. A solução será construída do zero como um **monólito modular profissional**, suficientemente robusto para portfólio, publicação online e evolução posterior. A stack pode evoluir quando houver uma razão técnica mensurável, sem introduzir Kubernetes ou microsserviços por padrão.

## Decisões consolidadas

- PostgreSQL é o catálogo transacional de coleções, documentos, versões, estados de ingestão e versão ativa.
- Qdrant armazena chunks, embeddings e payloads necessários ao retrieval; não é o catálogo administrativo.
- `document_id` representa a identidade lógica estável do documento.
- `content_sha256` identifica o conteúdo e garante idempotência.
- `version_id` identifica uma versão concreta do documento.
- Uma nova versão só se torna visível após processamento, persistência e validação completos.
- Exclusão de documento é física no PostgreSQL e no Qdrant, com confirmação explícita e registro de auditoria sem conteúdo sensível.
- O chat suporta providers independentes: OpenAI, Maritaca e Hugging Face Inference Providers.
- Metadatação possui dois modos: determinístico, sem LLM, e assistido por LLM com fallback determinístico.
- Respostas distinguem evidência da base documental, conhecimento geral do modelo e resultados de busca web.
- A primeira publicação na GCP usa uma VM do Compute Engine executando um único Docker Compose. Cloud Run e Cloud SQL são caminhos posteriores, não requisitos do MVP.
- Em publicação pública, a interface não solicita nem armazena credenciais administrativas ou de providers. Segredos pertencem ao servidor.

---

# 1. Visão da versão melhorada

## 1.1. Resultado esperado

A versão melhorada será uma aplicação:

- reproduzível;
- segura por padrão;
- testável sem depender de serviços externos;
- consistente entre frontend e backend;
- resiliente a falhas comuns;
- rastreável;
- limitada contra abuso de recursos e custos;
- preparada para evolução incremental.

## 1.2. O que permanece

| Elemento | Decisão |
|---|---|
| FastAPI | Mantido como API e servidor do frontend |
| LangGraph | Mantido como runtime do fluxo agêntico |
| OpenAI | Provider padrão de chat e embeddings |
| Maritaca | Provider opcional de chat, especializado em português |
| Hugging Face | Provider opcional de chat para modelos abertos hospedados |
| Qdrant | Mantido como banco vetorial |
| PostgreSQL | Catálogo transacional e controle de versões |
| Langfuse | Mantido como integração opcional de observabilidade |
| PyMuPDF | Mantido como extrator principal de PDF |
| Interface web simples | Mantida, separada em arquivos e servida na mesma origem |
| Múltiplas coleções | Mantidas, com nomes validados e autorização |
| Extração de metadados | Mantida, com limites, fallback e rastreamento |
| Citações por fonte/página | Mantidas e transformadas em contrato estruturado |

## 1.3. O que muda

1. O código passa a ter camadas claras: API, serviços, domínio, grafo, documentos e integrações.
2. Clientes externos deixam de ser globais e passam a usar lifespan e injeção.
3. Rotas administrativas deixam de existir no perfil público.
4. Chat público e operação administrativa usam perfis de execução distintos.
5. Arquivos e histórico passam a ter limites e validação.
6. Documentos recebem identidade lógica estável, checksum de conteúdo e versionamento.
7. Atualização deixa de apagar o conteúdo válido antes de preparar o novo.
8. Resultados de retrieval e citações passam a ser estruturados.
9. Conteúdo recuperado e anexado passa a ser tratado explicitamente como não confiável.
10. O frontend deixa de renderizar HTML não sanitizado.
11. O projeto ganha testes, CI, Docker, documentação e avaliação.
12. Health check é dividido em liveness e readiness.

## 1.4. Arquitetura-alvo

```text
┌──────────────────────────────────────────────────────────────┐
│ Browser                                                      │
│ Frontend estático, mesma origem, renderização segura          │
└──────────────────────────────┬───────────────────────────────┘
                               │ HTTP /api/v1
┌──────────────────────────────▼───────────────────────────────┐
│ FastAPI                                                      │
│ Auth • limites • validação • request ID • erros padronizados  │
├──────────────────────────────────────────────────────────────┤
│ Casos de uso / serviços                                      │
│ Chat • ingestão • retrieval • documentos • coleções           │
├──────────────────────────────────────────────────────────────┤
│ Domínio e contratos                                          │
│ DocumentId • versão • chunk • citação • respostas             │
├───────────────────────┬───────────────────────┬──────────────┤
│ LangGraph             │ Processamento         │ Observability │
│ agente e tools        │ PDF/chunk/metadata    │ logs/Langfuse │
├───────────────────────┴───────────┬───────────┴──────────────┤
│ Integrações                       │                           │
│ OpenAI • Maritaca • Hugging Face │ Qdrant • PostgreSQL       │
└───────────────────────────────────┴───────────────────────────┘
```

## 1.5. Estilo arquitetural

A recomendação é um **monólito modular**, porque:

- preserva a simplicidade didática;
- não exige rede entre microsserviços;
- facilita execução local;
- permite testes por camada;
- mantém um único deploy;
- oferece fronteiras que podem ser separadas futuramente.

Não se recomenda iniciar com microsserviços, Kubernetes, broker ou armazenamentos adicionais além de PostgreSQL e Qdrant. Esses elementos só devem ser introduzidos por demanda comprovada.

---

# 2. Correções de falhas e vulnerabilidades

## 2.1. Autenticação e autorização

### Versão inicial publicável

Credenciais da OpenAI, Maritaca e Hugging Face são segredos exclusivos do servidor. Elas entram por `.env` não versionado no desenvolvimento, por Docker secrets quando disponível e pelo Secret Manager na GCP. O navegador nunca recebe nem solicita essas credenciais.

O MVP não usa uma chave administrativa compartilhada. Em execução pública:

- chat pode ser público, com rate limit, quota e proteção contra abuso;
- rotas administrativas e de ingestão ficam desabilitadas no listener público;
- o operador administra por CLI dentro do container, SSH/IAP e acesso local autenticado à VM;
- uma evolução pode usar Identity-Aware Proxy ou OIDC sem alterar os serviços de domínio.

Em desenvolvimento local, rotas administrativas podem ser habilitadas explicitamente e limitadas a loopback/rede confiável. O backend nunca deve interpretar a ausência de autenticação como autorização administrativa.

| Perfil | Interface pública | Ingestão/administração |
|---|---|---|
| `development` | local | habilitada para desenvolvimento |
| `public` | chat e leitura permitida | não registrada pela aplicação |
| `operator` | somente loopback/túnel SSH/IAP | habilitada sem expor credenciais de provider ao browser |

### Caminho de evolução

Quando houver usuários administrativos via navegador:

- substituir API keys por OIDC/OAuth 2.1;
- validar JWT;
- criar papéis;
- associar coleções a tenant ou usuário;
- aplicar autorização por recurso.

Credenciais de providers não são credenciais de usuário e nunca devem ser usadas para autenticar administração.

## 2.2. Correção de XSS

O frontend deve:

- usar `textContent` para mensagens e erros;
- criar elementos DOM explicitamente;
- não interpolar resposta do modelo em `innerHTML`;
- sanitizar Markdown com biblioteca conhecida somente se Markdown for requisito;
- manter links desabilitados ou validados por esquema;
- não executar HTML retornado pelo modelo.

## 2.3. CORS e mesma origem

A aplicação deve servir o frontend estático pela própria FastAPI.

Vantagens:

- elimina necessidade de CORS no caminho padrão;
- evita URL fixa;
- simplifica deploy;
- reduz configuração insegura.

Quando frontend e API forem separados, `ALLOWED_ORIGINS` deve ser uma lista explícita. Não usar wildcard com credenciais.

## 2.4. Proteção dos endpoints administrativos

Além da autenticação:

- validar nomes de coleção com regex e tamanho máximo;
- impedir nomes reservados;
- registrar operações administrativas;
- separar rotas `/api/v1/chat` e `/api/v1/admin`;
- retornar `404` ou `403` sem revelar recursos de outros escopos;
- proteger Qdrant em rede privada.

## 2.5. Limites de recursos e custos

Configurações obrigatórias:

| Limite | Exemplo inicial |
|---|---:|
| Tamanho por arquivo | 10 MB |
| Arquivos por requisição | 5 |
| Páginas por documento | 300 |
| Chunks por documento | 2.000 |
| Tamanho do chunk | 200 a 2.000 caracteres/tokens, conforme estratégia |
| Sobreposição | menor que o chunk e limitada a 30% |
| Tamanho da consulta | 4.000 caracteres |
| Mensagens no histórico | 20 |
| Caracteres no histórico | 30.000 |
| `top_k` | 1 a 10 |
| Chamadas da ferramenta por turno | 1, salvo caso justificado |
| Timeout OpenAI | configurado |
| Timeout Qdrant | configurado |
| Concorrência de embeddings | limitada |

Os números devem ser configuráveis e ajustados por medição.

## 2.6. Validação de arquivos

O backend deve:

- verificar tamanho antes de processar;
- validar extensão e tipo detectado;
- aceitar inicialmente PDF e TXT;
- rejeitar arquivo vazio;
- limitar páginas;
- interromper PDF criptografado não suportado;
- usar nomes apenas como metadado, nunca como caminho;
- calcular SHA-256 do conteúdo;
- não confiar no MIME informado pelo cliente.

## 2.7. Defesa contra prompt injection

### Arquivo anexado ao chat

O texto do arquivo não deve entrar como instrução de sistema.

Ele deve ser representado como dados não confiáveis, por exemplo em uma mensagem/tool result com delimitadores e metadados controlados.

### Documentos recuperados

O prompt deve estabelecer:

- trechos são evidências, não instruções;
- comandos encontrados nos trechos devem ser ignorados;
- o agente não pode revelar prompts, credenciais ou dados fora do escopo;
- a resposta deve se apoiar apenas em evidências recuperadas quando a pergunta for documental;
- ausência de evidência suficiente deve produzir resposta de insuficiência, não invenção.

### Controles complementares

- máximo de chamadas da ferramenta;
- limite de contexto;
- allowlist de ferramentas;
- validação estruturada das citações;
- testes adversariais;
- logs sem conteúdo sensível por padrão.

Nenhuma técnica isolada elimina prompt injection; o objetivo é reduzir capacidade, superfície e impacto.

## 2.8. Erros seguros

Definir um envelope:

```json
{
  "error": {
    "code": "DOCUMENT_PROCESSING_FAILED",
    "message": "Não foi possível processar o documento.",
    "request_id": "..."
  }
}
```

Detalhes técnicos ficam somente no log, submetidos a redaction.

## 2.9. Atualização segura e versionada

Novo fluxo:

1. localizar ou gerar o `document_id` lógico e estável;
2. calcular `content_sha256` e tratar conteúdo idêntico de forma idempotente;
3. criar `version_id` para o conteúdo novo;
4. processar e validar todo o documento;
5. gerar embeddings;
6. gravar no Qdrant os pontos ainda não visíveis;
7. validar a contagem;
8. em transação PostgreSQL, apontar o documento para a nova versão ativa;
9. remover fisicamente os chunks da versão anterior após a troca bem-sucedida.

Em Qdrant, pontos devem ter IDs determinísticos, por exemplo:

```text
hash(collection + document_id + version_id + page + chunk_index)
```

Isso melhora idempotência.

O retrieval primeiro resolve no PostgreSQL a versão ativa e então filtra o Qdrant por `document_id` e `version_id`. Assim, a ativação não depende de alterar o payload de todos os chunks de forma pseudoatômica. Chunks órfãos de uma falha anterior são invisíveis e podem ser removidos por reconciliação.

## 2.10. Privacidade e Langfuse

A integração deve ser:

- opcional;
- fail-open para o fluxo principal;
- configurada por ambiente;
- capaz de remover ou resumir conteúdo sensível;
- associada a request ID;
- desabilitada em testes;
- documentada quanto a retenção e destino dos dados.

## 2.11. Qdrant protegido

Em produção:

- não publicar a porta do Qdrant para a internet;
- usar rede interna;
- habilitar API key;
- usar TLS quando houver tráfego fora do host/rede confiável;
- restringir backup;
- fixar a versão da imagem;
- definir persistência;
- criar health check.

## 2.12. Segredos e publicação inicial na GCP

No desenvolvimento, `.env` é permitido desde que esteja ignorado pelo Git e tenha permissões locais restritas. O Compose aceita também o padrão `*_FILE` para Docker secrets.

Na GCP, a VM usa uma service account de privilégio mínimo para ler versões específicas no Secret Manager, sem baixar chave JSON. O bootstrap materializa os segredos somente em arquivos temporários montados nos containers, com permissões restritas. PostgreSQL e Qdrant não publicam portas; apenas o proxy HTTPS publica 80/443. Administração ocorre por túnel via IAP/SSH, não por endpoint aberto na internet.

Essa topologia prioriza simplicidade operacional: uma VM, um persistent disk e um Docker Compose. Backups, restore testado, atualização da imagem e remoção dos recursos que geram cobrança fazem parte da Entrega B.

---

# 3. Melhorias de arquitetura, performance, segurança e manutenção

## 3.1. Estrutura sugerida

```text
src/rag_production/
├── __init__.py
├── main.py
├── api/
│   ├── deps.py
│   ├── errors.py
│   ├── middleware.py
│   └── routers/
│       ├── health.py
│       ├── chat.py
│       ├── collections.py
│       └── documents.py
├── core/
│   ├── config.py
│   ├── logging.py
│   ├── security.py
│   └── limits.py
├── domain/
│   ├── models.py
│   ├── schemas.py
│   └── exceptions.py
├── services/
│   ├── chat_service.py
│   ├── ingestion_service.py
│   ├── retrieval_service.py
│   ├── document_service.py
│   └── collection_service.py
├── graph/
│   ├── state.py
│   ├── prompts.py
│   ├── tools.py
│   └── workflow.py
├── document/
│   ├── extractors.py
│   ├── splitters.py
│   └── metadata.py
└── integrations/
    ├── openai.py
    ├── qdrant.py
    └── langfuse.py
```

## 3.2. Direção de dependências

```text
API → serviços → domínio
serviços → interfaces de integrações
grafo → serviços de retrieval
integrações → SDKs externos
domínio → nenhuma infraestrutura
```

Routers não devem acessar Qdrant ou OpenAI diretamente.

## 3.3. Application factory e lifespan

`create_app()` deve:

- validar settings;
- registrar middleware;
- registrar handlers;
- criar dependências;
- abrir clientes;
- fechar clientes no shutdown;
- montar frontend;
- expor OpenAPI.

Isso evita efeitos colaterais no import e facilita testes.

## 3.4. Configuração

Usar somente `pydantic-settings` com `SettingsConfigDict`.

Separar:

- obrigatórias;
- opcionais;
- limites;
- segurança;
- observabilidade;
- integrações.

Validar invariantes, por exemplo:

- `MAX_CHUNK_OVERLAP < MAX_CHUNK_SIZE`;
- pelo menos uma origem explícita quando CORS for habilitado;
- configuração de produção não pode habilitar o perfil administrativo público;
- OpenAI obrigatória apenas nos modos que usam a integração real.

## 3.5. Async e concorrência

- usar métodos assíncronos de OpenAI/LangChain quando disponíveis;
- usar cliente assíncrono do Qdrant;
- colocar parsing pesado em thread pool, se necessário;
- gerar embeddings em lotes limitados;
- aplicar semáforo de concorrência;
- evitar carregar múltiplos documentos grandes simultaneamente;
- definir timeouts e retries somente para falhas transitórias.

## 3.6. Contratos estruturados

### Resposta de chat

```json
{
  "sections": [
    {
      "kind": "retrieval",
      "text": "Resposta fundamentada nos documentos.",
      "citations": [
        {
          "document_id": "doc_...",
          "source": "arquivo.pdf",
          "page": 3,
          "chunk_id": "chunk_...",
          "score": 0.82
        }
      ]
    },
    {
      "kind": "general_knowledge",
      "text": "Complemento baseado no conhecimento geral do modelo.",
      "citations": []
    }
  ],
  "request_id": "req_...",
  "retrieval_used": true,
  "web_search_used": false
}
```

Cada seção declara sua proveniência: `retrieval`, `general_knowledge` ou `web_search`. Citações documentais são montadas deterministicamente a partir dos chunks recuperados. Uma seção de busca web contém URLs e títulos realmente retornados pela ferramenta; conhecimento geral sem fonte externa não deve receber uma citação inventada.

### Resposta de ingestão

```json
{
  "document_id": "doc_...",
  "version_id": "ver_...",
  "status": "completed",
  "chunks_indexed": 42,
  "request_id": "req_..."
}
```

## 3.7. Retrieval estruturado

O serviço deve retornar objetos, não pseudo-XML livre.

Cada resultado contém:

- `chunk_id`;
- `document_id`;
- `version_id`;
- `source`;
- `page`;
- `content`;
- `score`;
- metadados permitidos.

Aplicar:

- `top_k` limitado;
- score mínimo opcional;
- filtros permitidos;
- somente versão ativa;
- limite total de caracteres/tokens;
- ordenação determinística;
- deduplicação.

## 3.8. Citações verificáveis

O modelo pode selecionar identificadores de evidência, mas a API deve montar as citações a partir dos resultados realmente recuperados.

Não aceitar citação inventada pelo modelo.

Uma verificação determinística deve confirmar que todo ID citado pertence ao conjunto recuperado.

## 3.9. Modelo de dados vetorial

Payload sugerido:

```json
{
  "schema_version": 1,
  "document_id": "doc_...",
  "version_id": "ver_...",
  "is_active": true,
  "source_name": "manual.pdf",
  "content_sha256": "...",
  "page": 4,
  "chunk_index": 7,
  "content": "...",
  "classification": "...",
  "description": "...",
  "created_at": "..."
}
```

Criar índices de payload para campos consultados:

- `document_id`;
- `version_id`;
- `is_active`;
- `source_name`;
- eventualmente `classification`.

## 3.10. Dense primeiro, híbrido depois

A primeira versão melhorada deve usar apenas dense retrieval, removendo a configuração esparsa não utilizada.

Busca híbrida só deve ser adicionada quando:

- houver dataset de avaliação;
- o baseline dense estiver medido;
- existir ganho demonstrável;
- o custo operacional for aceito.

## 3.11. Observabilidade

### Logs

- JSON em produção;
- human-readable no desenvolvimento;
- request ID;
- rota;
- status;
- latência;
- IDs técnicos;
- sem chave, conteúdo integral ou embedding.

### Métricas

- requisições e erros;
- latência HTTP;
- latência de OpenAI e Qdrant;
- chunks processados;
- bytes/páginas;
- tokens e custo estimado;
- taxa de retrieval vazio;
- taxa de respostas sem evidência;
- falhas de ingestão.

### Health

- `/health/live`: processo vivo;
- `/health/ready`: configuração e Qdrant disponíveis;
- OpenAI não precisa ser chamado a cada readiness;
- Langfuse não deve impedir prontidão do serviço principal.

## 3.12. Testabilidade

Todas as integrações devem expor protocolos/interfaces substituíveis.

Testes usam:

- fake embedder;
- fake chat model;
- repositório vetorial fake;
- Qdrant real em integração;
- respostas determinísticas;
- arquivos pequenos versionados em fixtures.

## 3.13. CI

Pipeline mínimo:

1. instalar com lock;
2. validar formatação;
3. lint;
4. type check;
5. testes unitários;
6. testes de integração;
7. cobertura;
8. auditoria de dependências;
9. scanner de segurança estático;
10. build da imagem;
11. smoke test.

---

# 4. Novas funcionalidades e refinamentos

## 4.1. Listagem de coleções e documentos

Justificativa: a interface atual cria e usa recursos sem oferecer visibilidade administrativa.

Adicionar:

- listar coleções permitidas;
- listar documentos e versão ativa;
- consultar status;
- excluir com confirmação;
- atualizar de forma segura.

## 4.2. Estado explícito de ingestão

Mesmo no processamento síncrono inicial, retornar estados consistentes:

- `accepted`;
- `processing`;
- `completed`;
- `failed`.

Se a ingestão permanecer síncrona, a resposta final pode ser `completed`. Ao introduzir worker, o contrato já estará preparado.

## 4.3. Resposta de evidência insuficiente

Quando retrieval não atingir score ou não houver trechos relevantes:

- não inventar resposta documental;
- informar que a base não contém evidência suficiente;
- opcionalmente responder conhecimento geral apenas se o modo da aplicação permitir e deixando isso explícito.

## 4.4. Filtros de metadados controlados

Disponibilizar filtros com allowlist:

- classificação;
- documento;
- intervalo de página;
- versão ativa.

O cliente não deve poder enviar filtros Qdrant arbitrários.

## 4.5. Histórico validado

Opções:

1. manter histórico client-side, porém aceitar somente esquema estrito e papéis permitidos;
2. adicionar armazenamento de sessões posteriormente.

Para preservar simplicidade, a primeira opção é suficiente no início.

## 4.6. Avaliação RAG

Criar dataset pequeno com:

- pergunta;
- coleção;
- documentos esperados;
- páginas esperadas;
- critérios de resposta;
- ataques de prompt injection.

Métricas iniciais:

- Recall@k;
- MRR;
- precisão de citação;
- taxa de resposta com evidência;
- groundedness avaliada por regras e, opcionalmente, juiz LLM;
- latência;
- tokens;
- custo.

## 4.7. Interface segura e coerente

A interface deve oferecer:

- criação e seleção de coleção;
- upload múltiplo;
- resultado por documento;
- listagem;
- chat;
- citações;
- erros amigáveis;
- estado de carregamento;
- limpeza do histórico.

Sem framework JavaScript inicialmente, para preservar o caráter simples do projeto.

## 4.8. Fila de ingestão como evolução opcional

Adicionar worker e Redis somente quando:

- arquivos excederem o tempo aceitável de request;
- houver concorrência real;
- for necessário retry durável;
- o deploy suportar componentes adicionais.

Até lá, ingestão assíncrona limitada no processo é suficiente para o objetivo educacional.

---

# 5. Escolhas de bibliotecas

## 5.1. Bibliotecas mantidas

| Biblioteca | Decisão | Motivo |
|---|---|---|
| FastAPI | Manter | Boa tipagem, OpenAPI, DI e async |
| Uvicorn | Manter | Servidor ASGI adequado |
| Pydantic | Manter | Contratos e validação |
| pydantic-settings | Manter | Configuração centralizada |
| LangGraph | Manter | É parte central da proposta agêntica |
| langchain-core | Manter | Mensagens e tools |
| langchain-openai | Declarar e manter | Integração efetivamente usada |
| qdrant-client | Manter | Integração vetorial escolhida |
| PyMuPDF | Manter | Extração de PDF consolidada |
| python-multipart | Manter | Upload FastAPI |
| Langfuse | Manter como opcional | Observabilidade de LLM |
| tiktoken | Manter se usado | Limites e chunking por tokens |

## 5.1.1. Providers e perfis de modelo

O domínio usa protocolos próprios; nomes de modelos ficam em configuração e não espalhados pelo código.

| Perfil | Provider/modelo inicial | Uso |
|---|---|---|
| Econômico OpenAI | `gpt-5-mini` | alto volume e prompts bem definidos |
| Intermediário OpenAI | `gpt-5.6-terra` | melhor equilíbrio entre capacidade e custo |
| Econômico atual alternativo | `gpt-5.6-luna` | tarefas sensíveis a custo |
| Português | Maritaca, modelo configurável da família Sabiá | português e contexto brasileiro |
| Aberto hospedado | Hugging Face Inference Providers, model ID configurável | experimentação com modelos abertos |

Maritaca e Hugging Face são providers distintos. Ambos podem oferecer interface compatível com APIs OpenAI, mas usam URLs, credenciais, capacidades e políticas próprias. Tool calling, structured output e busca web devem ser declarados como capabilities do adapter; o grafo não deve pressupor suporte uniforme.

Embeddings são configurados separadamente do chat. Trocar o modelo de embeddings exige nova dimensão/coleção ou migração explícita; nunca se reutiliza silenciosamente uma coleção com vetores incompatíveis.

## 5.2. Bibliotecas removidas ou reduzidas

| Biblioteca | Decisão | Motivo |
|---|---|---|
| `fitz` | Remover | Pacote inadequado e potencial conflito com PyMuPDF |
| PyPDF2 | Remover | Evitar duas implementações de PDF |
| `python-dotenv` | Remover do código | `pydantic-settings` já lê `.env` |
| `langchain` completo | Avaliar remoção | Usar somente pacotes específicos reduz superfície |
| SDK `openai` direto | Manter apenas se houver uso direto | Evitar dependência redundante |

## 5.3. Dependências de desenvolvimento

Adicionar:

- `pytest`;
- `pytest-asyncio`;
- `pytest-cov`;
- `httpx`;
- `respx` ou mocks equivalentes;
- `ruff`;
- `mypy` ou `pyright`;
- `bandit`;
- `pip-audit`;
- tipos auxiliares quando necessários.

Fixar resolução no `uv.lock`.

## 5.4. Dependências opcionais

- instrumentação Prometheus;
- `tenacity` para retries controlados;
- sanitizador de Markdown, caso a interface suporte Markdown;
- Redis e biblioteca de jobs somente na fase de escala.

Cada dependência opcional precisa de uso concreto e teste; não deve ser adicionada “por precaução”.

---

# 6. Trade-offs e riscos

| Mudança | Benefício | Custo ou risco | Mitigação |
|---|---|---|---|
| API keys separadas | Proteção rápida | Gestão manual e baixa granularidade | Documentar rotação e migrar para OIDC |
| Mesma origem | CORS mais simples e seguro | Frontend menos independente | Separar apenas quando necessário |
| Monólito modular | Simplicidade e testabilidade | Escala conjunta | Extrair worker quando houver evidência |
| Limites rígidos | Protege custo e disponibilidade | Pode rejeitar documentos legítimos | Configuração por ambiente e métricas |
| Versionamento de documento | Atualização segura e idempotência | Armazenamento temporário maior | Retenção e limpeza programada |
| IDs determinísticos | Retry seguro | Exige desenho de identidade | Testes de colisão e hash estável |
| Dense only inicialmente | Menor complexidade | Pode perder consultas lexicais | Medir baseline antes do híbrido |
| Citação estruturada | Rastreabilidade | Contrato mais complexo | Schemas claros e testes |
| Defesa contra injection | Reduz impacto | Não elimina o problema | Controles em camadas e testes adversariais |
| Redaction no Langfuse | Mais privacidade | Menos detalhe de debugging | Ambientes e níveis configuráveis |
| Async e batch | Melhor throughput | Mais complexidade de concorrência | Limites e testes |
| Readiness real | Deploy confiável | Dependência de checks | Timeouts curtos e checks essenciais |
| CI completo | Evita regressões | Tempo de pipeline | Separar jobs rápidos e integração |
| Avaliação RAG | Evolução baseada em evidência | Manutenção de dataset | Começar pequeno e versionado |
| Worker futuro | Retry e durabilidade | Mais infraestrutura | Não introduzir prematuramente |

## 6.1. Risco de excesso arquitetural

O maior risco da proposta melhorada é transformar um projeto educacional em uma plataforma excessivamente complexa.

Guardrails da implementação:

- uma aplicação;
- um banco vetorial;
- sem Kubernetes;
- sem event bus;
- sem múltiplos serviços até haver necessidade;
- sem framework frontend;
- sem abstrações genéricas para múltiplos vendors no primeiro ciclo;
- cada componente novo deve resolver um achado concreto.

## 6.2. Risco de compatibilidade

LangChain, LangGraph e integrações de LLM evoluem rapidamente.

Mitigações:

- lock versionado;
- imports específicos;
- testes do grafo;
- atualização deliberada de dependências;
- changelog;
- dependabot/Renovate opcional com revisão humana.

---

# 7. Roadmap sugerido

## Fase 0 — Baseline e reprodutibilidade

**Objetivo:** o projeto instala e inicia de modo consistente.

- corrigir manifesto;
- declarar dependências diretas;
- remover `fitz` e PyPDF2;
- criar `.env.example`;
- criar application factory;
- criar Dockerfile e compose;
- corrigir README;
- adicionar lint, format e type check.

**Critério de saída:** instalação com lock, import da aplicação, liveness e testes básicos funcionando.

## Fase 1 — Correção funcional e segurança mínima

**Objetivo:** nenhum fluxo básico conhecido permanece quebrado ou público.

- corrigir upload frontend/backend;
- substituir `innerHTML`;
- servir frontend na mesma origem;
- autenticar chat e administração;
- validar coleção;
- limitar uploads e histórico;
- padronizar erros;
- corrigir CORS;
- criar testes de API e segurança.

**Critério de saída:** chat e ingestão funcionam por UI/API, endpoints destrutivos exigem credencial e testes cobrem os achados críticos/altos.

## Fase 2 — Ingestão confiável

**Objetivo:** documentos têm identidade, idempotência e atualização segura.

- hash;
- `document_id`;
- `version_id`;
- IDs determinísticos;
- índices de payload;
- preparação antes de ativação;
- retries controlados;
- limpeza de versões;
- validação de PDF.

**Critério de saída:** reenviar o mesmo arquivo não duplica pontos e falha na atualização não remove a versão ativa.

## Fase 3 — Retrieval e agente seguros

**Objetivo:** evidências e citações são estruturadas e conteúdo externo não controla o sistema.

- serviço de retrieval;
- `top_k`, score e filtros;
- payload estruturado;
- prompt revisado;
- conteúdo não confiável isolado;
- limite de tools;
- resposta de insuficiência;
- verificador de citações.

**Critério de saída:** toda citação corresponde a resultado recuperado e testes de injection não alteram as regras principais.

## Fase 4 — Operação e observabilidade

**Objetivo:** diagnosticar disponibilidade, custo e falhas.

- logs JSON;
- request ID;
- readiness;
- métricas;
- timeouts;
- tracking Langfuse opcional;
- redaction;
- health checks de containers.

**Critério de saída:** é possível identificar uma requisição, medir suas etapas e operar sem Langfuse.

## Fase 5 — Qualidade contínua

**Objetivo:** impedir regressões e medir qualidade RAG.

- CI;
- testes unitários, integração, e2e e segurança;
- auditoria de dependências;
- dataset de avaliação;
- métricas de retrieval e citação;
- relatório de custo/latência.

**Critério de saída:** pull request falha em regressão funcional, de segurança ou qualidade mínima definida.

## Fase 6 — Recursos desejáveis

Somente após métricas:

- busca híbrida;
- reranking;
- worker e fila;
- sessões persistentes;
- OIDC;
- multi-tenancy;
- painel administrativo separado;
- deploy com autoscaling.

---

# Conclusão

A aplicação busca qualidade profissional sem depender de uma implementação anterior. O ganho principal não virá de adicionar mais frameworks, mas de:

1. corrigir contratos;
2. proteger operações;
3. controlar conteúdo e recursos não confiáveis;
4. tornar ingestão e atualização confiáveis;
5. estruturar retrieval e citações;
6. criar testes e operação verificável.

Essa ordem produz um projeto de portfólio mais convincente e uma base que pode ser adaptada para produção sem afirmar maturidade que ainda não foi implementada.
