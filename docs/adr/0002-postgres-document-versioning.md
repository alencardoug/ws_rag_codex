# ADR 0002 — PostgreSQL como catálogo de versões

- Status: aceito
- Data: 2026-07-22

## Contexto

Ativar uma versão alterando payloads de muitos pontos no Qdrant não oferece a atomicidade necessária. `document_id` derivado do conteúdo também impede representar atualizações lógicas.

## Decisão

PostgreSQL mantém documentos, versões, estados e o ponteiro ativo. `document_id` é lógico e estável; `content_sha256` identifica conteúdo; `version_id` identifica a versão. Qdrant armazena chunks filtrados pela versão resolvida no catálogo.

## Consequências

A ativação é transacional no catálogo. Pontos órfãos podem existir após falha, mas ficam invisíveis e são reconciliados. A exclusão física precisa coordenar dois stores sem transação distribuída.
