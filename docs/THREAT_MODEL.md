# Modelo de ameaças

## Ativos

- documentos e consultas;
- credenciais de providers e banco;
- disponibilidade e orçamento de APIs;
- integridade de citações e versões;
- dados enviados à observabilidade.

## Fronteiras

- internet → proxy/API pública;
- operador → perfil administrativo;
- API → providers externos;
- aplicação → PostgreSQL/Qdrant;
- aplicação → Langfuse opcional.

## Ameaças e controles

| Ameaça | Controles mínimos |
|---|---|
| prompt injection em documento | conteúdo como dado não confiável, tool allowlist, orçamento e testes adversariais |
| XSS | `textContent`, DOM explícito, validação de links, sem HTML do modelo |
| abuso de custo | rate limit, quotas, limites de tokens/arquivos/tools e timeouts |
| administração pública | rotas ausentes no perfil público, operador via loopback/túnel |
| vazamento de segredo | Secret Manager/`*_FILE`, redaction, nenhum segredo no browser |
| citação inventada | montagem determinística sobre evidência recuperada |
| arquivo malicioso | tipo detectado, limites, PDF criptografado rejeitado e parsing isolável |
| atualização destrutiva | versão preparada antes da ativação transacional |
| enumeração | erros genéricos e escopo de coleção validado |
| SSRF por link | web search controlada; backend não busca URL arbitrária do modelo |

## Administração

O MVP não usa chave administrativa compartilhada. A operação acontece dentro da fronteira da VM por SSH/IAP ou listener loopback. Uma UI administrativa pública exigirá OIDC/IAP antes de ser habilitada.

## Risco residual

Prompt injection não é eliminada. O desenho reduz capacidades e impacto, mas documentos maliciosos ainda podem influenciar texto gerado. Evals e monitoramento devem medir regressões.
