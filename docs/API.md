# Contratos da API

## Convenções

- Prefixo: `/api/v1`.
- JSON, exceto upload multipart.
- `request_id` em respostas e erros relevantes.
- perfil público e perfil operador produzem documentos OpenAPI distintos.

## Chat

`POST /api/v1/chat`

```json
{
  "collection": "manuals",
  "query": "Como configurar o produto?",
  "history": [],
  "allow_general_knowledge": true,
  "allow_web_search": false
}
```

```json
{
  "sections": [
    {
      "kind": "retrieval",
      "text": "...",
      "citations": [
        {
          "document_id": "...",
          "source": "manual.pdf",
          "page": 3,
          "chunk_id": "...",
          "score": 0.82
        }
      ]
    },
    {
      "kind": "general_knowledge",
      "text": "...",
      "citations": []
    }
  ],
  "request_id": "...",
  "retrieval_used": true,
  "web_search_used": false
}
```

Conhecimento geral não recebe fonte inventada. Uma seção `web_search` contém somente URLs e títulos realmente retornados pelo adapter de busca.

## Administração

Disponível somente no perfil `operator`:

- criar e listar coleções;
- ingerir PDF/TXT;
- listar documentos e versões;
- atualizar documento usando `document_id` explícito;
- excluir fisicamente documento com confirmação.

Resposta de ingestão síncrona:

```json
{
  "document_id": "...",
  "version_id": "...",
  "status": "completed",
  "chunks_indexed": 42,
  "request_id": "..."
}
```

## Erros

```json
{
  "error": {
    "code": "DOCUMENT_PROCESSING_FAILED",
    "message": "Não foi possível processar o documento.",
    "request_id": "..."
  }
}
```

Não retornar exceções, stack traces, URLs internas ou segredos.

## Status HTTP

- `200`: leitura ou operação síncrona.
- `201`: criação.
- `204`: exclusão concluída.
- `400`: regra de negócio inválida.
- `404`: recurso ausente.
- `409`: conflito ou idempotência incompatível.
- `413`: payload excedido.
- `422`: contrato inválido.
- `429`: limite de uso.
- `503`: dependência necessária indisponível.
