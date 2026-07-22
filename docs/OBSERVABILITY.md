# Observabilidade

## Objetivos

- correlacionar uma requisição entre API, grafo, PostgreSQL, Qdrant e providers;
- diagnosticar disponibilidade, latência e custo;
- evitar coleta de conteúdo ou segredos por padrão.

## Logs

Produção usa JSON; desenvolvimento pode usar formato humano. Campos mínimos:

- timestamp, nível, serviço e ambiente;
- `request_id`, rota, método, status e latência;
- IDs técnicos de coleção/documento/versão;
- provider, modelo e duração, sem prompt integral.

Redigir chaves, headers de autorização, DSNs, documentos, embeddings e histórico bruto.

## Métricas

- requests, erros, latência e rate limit;
- latência/falhas por integração;
- bytes, páginas e chunks ingeridos;
- tokens e custo estimado por provider/modelo;
- retrieval vazio e resposta sem evidência;
- exclusões parciais e resíduos reconciliados;
- pool PostgreSQL e disponibilidade Qdrant.

## Traces e Langfuse

Langfuse é opcional, fail-open e desabilitado nos testes. Captura de conteúdo deve ser opt-in e documentada. `request_id` correlaciona trace e log. Indisponibilidade do Langfuse não afeta readiness.

## Health checks

- `/health/live`: processo e event loop estão vivos.
- `/health/ready`: configuração válida, PostgreSQL acessível e Qdrant pronto.
- providers não são chamados a cada readiness; sua falha aparece na requisição e em métricas próprias.

## Alertas iniciais

- readiness falhando;
- taxa de erro/429 elevada;
- disco ou volume próximo do limite;
- backup ausente;
- custo/tokens acima do orçamento;
- crescimento de versões/chunks órfãos.
