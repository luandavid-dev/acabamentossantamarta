# Relatório de auditoria, hardening e padronização do projeto CONTROLE_DE_ESTOQUE

**Autor:** Manus AI  
**Data:** 27/05/2026  
**Projeto analisado:** Aplicação Flask de controle de estoque, chamados, furos de estoque, conferência e acompanhamento de compras.  
**Versão entregue:** `CONTROLE_DE_ESTOQUE_SEGURO`

## Sumário executivo

A aplicação foi revisada como um projeto de produção e recebeu correções de segurança, organização e padronização sem alterar a proposta funcional original. O trabalho priorizou riscos de alto impacto: credenciais e chave secreta hardcoded, execução em modo de desenvolvimento, ausência de proteção CSRF, upload/download de arquivos sem controles suficientes, inconsistências de schema SQLite, falta de instruções reprodutíveis de produção e presença de ambiente virtual empacotado no projeto original.

> A documentação oficial do Flask recomenda não usar o servidor de desenvolvimento em produção, pois ele é destinado ao desenvolvimento local e não foi projetado para ser seguro, estável ou eficiente em produção.[^flask-deploy]

O pacote final inclui código corrigido, banco SQLite migrado, backup do banco original antes do hardening, arquivo de exemplo de variáveis de ambiente, script de migração idempotente, script de execução com Gunicorn, `requirements.txt`, documentação de produção e arquivo de credenciais temporárias para contas cuja senha padrão/fraca foi rotacionada.

## Principais achados e correções aplicadas

| Área | Achado inicial | Risco | Correção aplicada | Status |
|---|---|---:|---|---|
| Configuração Flask | `SECRET_KEY` hardcoded no código | Alto | Chave passou a ser carregada de variável de ambiente ou gerada em arquivo local fora do código versionado | Corrigido |
| Execução | Aplicação preparada para `debug=True`/servidor embutido | Alto | Adicionado `wsgi.py`, `run_production.sh` e dependência `gunicorn`; bloco principal desativado para produção | Corrigido |
| Senhas | Contas com senha padrão/fraca conhecida no banco original | Alto | Senhas fracas detectadas foram rotacionadas e documentadas em `CREDENCIAIS_ROTACIONADAS.txt` | Corrigido |
| CSRF | Formulários e endpoints POST sem token anti-CSRF | Alto | Implementado token por sessão, injeção automática em templates e validação para POST/PUT/PATCH/DELETE | Corrigido |
| Uploads | Validação permissiva e nomes de arquivo previsíveis | Alto | Allowlist de extensões, limite de tamanho, geração de nome seguro e exclusivo, validação com `secure_filename` | Corrigido |
| Downloads/anexos | Rotas aceitavam caminhos em `<path:filename>` sem bloqueio explícito de subdiretórios | Médio | Bloqueio de `..` e nomes com separadores antes de servir arquivo | Corrigido |
| Cabeçalhos HTTP | Ausência de cabeçalhos de hardening | Médio | Adicionados `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy` e política de cache para respostas sensíveis | Corrigido |
| Sessão | Cookies sem política explícita de segurança | Médio | Definidos `HttpOnly`, `SameSite=Lax`, tempo de sessão e opção `SESSION_COOKIE_SECURE` por ambiente | Corrigido |
| Banco | Colunas usadas pelo código podiam não existir em instalações antigas | Médio | Criado `migrate_secure.py` idempotente para criar tabelas/colunas necessárias | Corrigido |
| Estrutura | Ambiente virtual e artefatos locais no pacote original | Médio | Entrega limpa, com `requirements.txt` e sem `venv`, `__pycache__` ou cache Python | Corrigido |
| Caminhos locais | Caminho Windows fixo para importação de planilha no startup | Baixo | Importação automática ficou opcional via `IMPORT_XLSX_PATH` e desativada por padrão | Corrigido |
| Documentação | Ausência de guia de produção | Médio | Criado `README_PRODUCAO.md` com instalação, configuração, migração e execução | Corrigido |

## Controles de segurança implementados

A aplicação agora usa uma abordagem mais defensiva para operações que modificam estado. O token CSRF é criado por sessão e validado em requisições `POST`, `PUT`, `PATCH` e `DELETE`, cobrindo formulários tradicionais e chamadas JSON via cabeçalho `X-CSRFToken`. A recomendação de uso de tokens imprevisíveis para operações sensíveis é uma mitigação clássica contra CSRF, conforme descrito pela OWASP.[^owasp-csrf]

A parte de arquivos foi endurecida com limite de tamanho e lista de extensões permitidas. O guia da OWASP para upload de arquivos recomenda allowlist de extensões, validação de entrada, alteração do nome do arquivo pela aplicação, limite de tamanho, autenticação/autorização para upload e proteção contra CSRF.[^owasp-upload] Esses controles foram aplicados no escopo do projeto para reduzir risco de path traversal, sobrescrita de arquivos, upload de conteúdo executável e abuso de armazenamento.

A configuração de sessão passou a explicitar parâmetros seguros, incluindo `HttpOnly`, `SameSite=Lax` e duração limitada. A documentação do Flask ressalta que a `SECRET_KEY` deve ser longa, aleatória e não deve ser revelada nem commitada no código.[^flask-config]

## Validações realizadas

| Validação | Resultado |
|---|---|
| Compilação Python de `app.py`, `migrate_secure.py` e `wsgi.py` | Aprovada |
| Importação da aplicação Flask sem iniciar servidor público | Aprovada |
| Listagem de rotas registradas | 38 rotas |
| Página de login via cliente de teste | HTTP 200 |
| Bloqueio de POST sem CSRF | HTTP 400, conforme esperado |
| Varredura final por `admin123`, chave antiga, debug ativo e IP/senha ERP hardcoded sensíveis | Sem ocorrências críticas no código entregue |
| Verificação de formulários POST sem `_csrf_token` nos templates | 0 formulários pendentes |
| Limpeza de artefatos de teste | `__pycache__`, `.pyc` e chave local gerada removidos |

## Arquivos importantes da entrega

| Arquivo | Finalidade |
|---|---|
| `app.py` | Aplicação principal corrigida e endurecida |
| `banco.db` | Banco SQLite migrado e com senhas padrão/fracas rotacionadas |
| `backups/banco_original_pre_hardening.db` | Backup do banco recebido antes das alterações de segurança |
| `migrate_secure.py` | Migração idempotente para preparar schema em outros ambientes |
| `wsgi.py` | Entrada WSGI para execução em produção |
| `run_production.sh` | Script de execução com Gunicorn |
| `requirements.txt` | Dependências Python necessárias |
| `.env.example` | Modelo de variáveis de ambiente para produção |
| `README_PRODUCAO.md` | Guia de instalação, configuração e execução |
| `CREDENCIAIS_ROTACIONADAS.txt` | Senhas temporárias das contas corrigidas por segurança |

## Recomendações antes de publicar em produção

Antes de subir o sistema, configure uma `SECRET_KEY` forte no ambiente e não reutilize a chave gerada localmente em testes. Execute a aplicação atrás de HTTPS e proxy reverso, habilitando `SESSION_COOKIE_SECURE=true` quando o acesso estiver em HTTPS. Revise o arquivo `CREDENCIAIS_ROTACIONADAS.txt`, faça login com as credenciais temporárias, troque as senhas imediatamente e remova esse arquivo do servidor após a troca.

Também é recomendável manter backup regular do `banco.db` e da pasta `uploads`, restringir permissões de escrita do usuário do sistema, e migrar futuramente para PostgreSQL ou MySQL caso a aplicação tenha múltiplos usuários simultâneos ou cresça em volume transacional. O SQLite foi preservado por compatibilidade com o projeto recebido.

## Referências

[^owasp-csrf]: [OWASP Cheat Sheet Series — Cross-Site Request Forgery Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)
[^owasp-upload]: [OWASP Cheat Sheet Series — File Upload Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html)
[^flask-config]: [Flask Documentation — Configuration Handling](https://flask.palletsprojects.com/en/stable/config/)
[^flask-deploy]: [Flask Documentation — Deploying to Production](https://flask.palletsprojects.com/en/stable/deploying/)
