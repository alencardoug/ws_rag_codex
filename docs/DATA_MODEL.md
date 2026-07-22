# Modelo de dados

## PostgreSQL

### `collections`

- `id`: UUID.
- `slug`: nome público validado e único.
- `display_name`.
- `embedding_provider`, `embedding_model`, `vector_size`.
- timestamps.

### `documents`

- `id`: `document_id` lógico, UUID.
- `collection_id`.
- `source_name` apenas como metadado.
- `active_version_id`, anulável.
- timestamps.

### `document_versions`

- `id`: `version_id`, UUID.
- `document_id`.
- `content_sha256`.
- `status`: `processing`, `ready`, `active`, `failed` ou `deleting`.
- `chunk_count`, `byte_count`, `page_count`.
- metadados controlados e timestamps.

Invariantes:

- `content_sha256` é único por documento ou coleção conforme o caso de uso definido na especificação;
- um documento possui no máximo um `active_version_id`;
- o ponteiro só referencia versão do próprio documento em estado `active`;
- falha de processamento não altera o ponteiro ativo.

### `deletion_audit`

Registra IDs técnicos, resultado e timestamp. Não guarda conteúdo integral. Como a exclusão é física, este registro não permite reconstruir o documento.

## Identidade

- `document_id`: identidade lógica estável entre atualizações.
- `content_sha256`: identidade do conteúdo e chave de idempotência.
- `version_id`: ocorrência versionada desse conteúdo.
- `chunk_id`: hash determinístico de coleção, documento, versão, página e índice.

## Qdrant

Payload mínimo:

```json
{
  "schema_version": 1,
  "document_id": "...",
  "version_id": "...",
  "chunk_id": "...",
  "source_name": "manual.pdf",
  "content_sha256": "...",
  "page": 4,
  "chunk_index": 7,
  "content": "...",
  "classification": "...",
  "description": "..."
}
```

Criar índices para `document_id`, `version_id`, `source_name` e filtros de metadados realmente usados. A versão ativa não é mantida como flag em cada ponto; ela é resolvida no PostgreSQL.

## Mudança de embeddings

Uma coleção registra provider, modelo e dimensão. Alterá-los exige nova coleção vetorial ou migração explícita. Vetores incompatíveis nunca são gravados silenciosamente na coleção existente.

## Exclusão

Excluir um documento significa remover seus pontos do Qdrant e registros do PostgreSQL. A operação deve ser confirmada explicitamente, ser idempotente e reportar falha parcial para reconciliação.
