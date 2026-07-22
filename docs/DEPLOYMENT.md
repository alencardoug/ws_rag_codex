# Deployment

## Topologia inicial na GCP

Uma VM do Compute Engine executa `compose.prod.yaml`:

```text
Internet → HTTPS proxy → FastAPI
                         ├─ PostgreSQL (rede interna + volume)
                         └─ Qdrant (rede interna + volume)
```

Somente portas 80/443 ficam públicas. Administração usa IAP/SSH e listener loopback. PostgreSQL e Qdrant não publicam portas no host público.

## Por que Compute Engine primeiro

O produto precisa de dois serviços stateful e volumes persistentes. Uma VM mantém a implantação compreensível e próxima do Compose local. Cloud Run + Cloud SQL ou Qdrant gerenciado é uma evolução válida, mas adiciona serviços e operação antes de haver necessidade comprovada.

## Segredos

- service account da VM com acesso somente aos secrets necessários;
- nenhuma chave JSON de service account;
- versões de secrets fixadas no deployment;
- containers leem arquivos via `*_FILE`;
- `.env` de produção não é persistido com segredos.

## Persistência e backup

- persistent disk separado dos containers;
- backup lógico do PostgreSQL e snapshot/backup compatível do Qdrant;
- retenção e criptografia definidas;
- restore ensaiado, não apenas backup criado;
- espaço em disco e idade do último backup monitorados.

## Publicação guiada

A Entrega B deve documentar, com comandos verificáveis:

1. criar conta de faturamento e projeto;
2. habilitar APIs estritamente necessárias;
3. escolher região e criar service account;
4. criar secrets;
5. criar VM, persistent disk e regras de firewall;
6. instalar Docker/Compose e iniciar o stack;
7. configurar domínio e HTTPS;
8. executar migrations e smoke test;
9. configurar backup e monitoramento;
10. remover VM, disco, IP, snapshots e secrets para interromper cobranças.

## Evolução opcional

- API/frontend em Cloud Run;
- catálogo em Cloud SQL PostgreSQL;
- Qdrant gerenciado ou VM dedicada;
- IAP/OIDC para administração web;
- Artifact Registry e deploy automatizado.

Essas mudanças não devem exigir alterações no domínio ou nos contratos de serviços.
