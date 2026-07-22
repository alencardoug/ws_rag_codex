# Providers de modelo e busca

## Princípio

Chat, embeddings, metadatação e busca web são capacidades separadas. O provider é escolhido por configuração do servidor, nunca por entrada arbitrária do cliente.

## Chat

| Perfil | Provider/modelo inicial | Uso esperado |
|---|---|---|
| econômico OpenAI | `gpt-5-mini` | alto volume e tarefas bem definidas |
| intermediário OpenAI | `gpt-5.6-terra` | equilíbrio entre capacidade e custo |
| econômico atual alternativo | `gpt-5.6-luna` | cargas sensíveis a custo |
| português | Maritaca, família Sabiá configurável | português e contexto brasileiro |
| aberto hospedado | Hugging Face Inference Providers | experimentação com model ID configurável |

Maritaca e Hugging Face são providers distintos, mesmo quando expõem contratos compatíveis com clientes OpenAI.

## Capabilities

Cada adapter declara suporte a:

- tool calling;
- structured output;
- streaming;
- busca web nativa;
- limites de contexto;
- retries seguros.

O LangGraph não presume que todos os providers possuam as mesmas capacidades. Configurações incompatíveis falham no startup.

## Embeddings

O provider/modelo de embeddings é independente do chat. O MVP pode começar com OpenAI; outro adapter poderá ser adicionado sem alterar o domínio. Mudança de dimensão exige migração conforme `DATA_MODEL.md`.

## Metadatação

- `deterministic`: regras locais, sem custo ou rede.
- `llm`: saída estruturada usando provider/modelo configurado, com limites e fallback determinístico.

Falha na metadatação por LLM não deve invalidar conteúdo que possa ser ingerido com metadados mínimos.

## Busca web

Busca web é opcional e implementa um `WebSearchPort`. O primeiro adapter pode usar uma ferramenta nativa do provider selecionado; adapters futuros não mudam o contrato de resposta. URLs retornadas são validadas por esquema e preservadas como evidência observada.

## Segredos

- desenvolvimento: `.env` ignorado pelo Git ou Docker secrets;
- containers: suporte ao padrão `*_FILE`;
- GCP: Secret Manager com service account de privilégio mínimo;
- nunca enviar credenciais ao navegador, logs, traces ou respostas.
