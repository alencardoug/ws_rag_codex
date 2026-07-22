# Especificação — Production Agentic RAG

## Problema

Usuários precisam consultar documentos PDF/TXT com respostas rastreáveis, enquanto um operador precisa gerir o acervo com atualização segura, custos limitados e implantação simples.

## Objetivos

- ingerir e versionar documentos de forma idempotente;
- responder com citações verificáveis;
- separar conteúdo documental, conhecimento geral e busca web;
- suportar providers de chat configuráveis;
- funcionar localmente e em uma única VM GCP via Compose;
- ser testável sem serviços externos.

## Requisitos funcionais

### Coleções e documentos

- criar/listar coleções no perfil operador;
- ingerir PDF e TXT dentro dos limites;
- atualizar pelo `document_id` lógico;
- listar documento e versão ativa;
- excluir fisicamente documento e vetores;
- reenvio idêntico não duplica conteúdo.

### Chat

- consultar coleção selecionada;
- limitar consulta, histórico, contexto, top-k e tools;
- responder insuficiência quando não houver evidência;
- opcionalmente produzir seção distinta de conhecimento geral;
- opcionalmente usar busca web e citar somente resultados observados.

### Providers

- chat: OpenAI, Maritaca ou Hugging Face;
- embeddings configurados separadamente;
- metadatação determinística ou por LLM com fallback;
- Langfuse opcional.

## Requisitos não funcionais

- nenhuma rede em import ou teste unitário;
- PostgreSQL e Qdrant privados em produção;
- segredos ausentes do browser, Git, logs e erros;
- atualização com falha preserva versão ativa;
- frontend não executa HTML não confiável;
- readiness reflete PostgreSQL e Qdrant;
- logs correlacionáveis e redigidos.

## Fora do escopo do MVP

- Kubernetes e microsserviços;
- Redis/worker;
- multi-tenancy;
- OIDC e painel administrativo público;
- busca híbrida e reranking;
- sessões persistentes;
- edição de documentos.

## Critérios de sucesso

- instalação reproduzível com lock;
- fluxo ingestão → consulta → atualização → exclusão funciona;
- concorrência/falha não produz versão ativa inválida;
- citações pertencem às evidências recuperadas;
- suíte normal usa fakes;
- Compose local e de VM têm health checks e volumes;
- documentação leva outra pessoa do clone ao smoke test.

## Questões deliberadamente configuráveis

- provider/modelo padrão por ambiente;
- permitir ou não conhecimento geral e busca web;
- limites e quotas iniciais;
- metadatação determinística ou LLM;
- retenção de auditoria técnica.
