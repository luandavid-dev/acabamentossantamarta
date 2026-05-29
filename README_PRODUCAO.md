# CONTROLE DE ESTOQUE — versão endurecida para produção

Esta versão foi revisada para remover credenciais hardcoded, reduzir riscos comuns de Flask em produção e padronizar a inicialização. O ambiente virtual antigo e caches Python foram removidos do pacote; instale as dependências com `pip install -r requirements.txt` em um ambiente virtual novo.

## Como iniciar

Crie e ative um ambiente virtual, instale as dependências e copie `.env.example` para `.env`. Ajuste `SECRET_KEY`, `SESSION_COOKIE_SECURE`, credenciais do ERP e demais variáveis. Em seguida, execute `./run_production.sh`.

## Principais correções aplicadas

| Área | Correção |
|---|---|
| Credenciais | Removidas senha administrativa padrão e credenciais ERP hardcoded do código. |
| Sessão | Chave secreta passa a vir do ambiente ou de arquivo local persistente fora do código. |
| CSRF | Formulários e requisições `fetch` POST agora possuem token CSRF. |
| Login | Incluído limite de tentativas por usuário/IP e limpeza de sessão no login. |
| Uploads | Validação de extensão e nomes únicos com token aleatório para reduzir sobrescrita. |
| Execução | `debug=False` por padrão e execução produtiva via Gunicorn. |
| Banco | Incluído backup do banco original em `backups/` e migrações idempotentes. |
| Cabeçalhos | Adicionados cabeçalhos de segurança HTTP básicos. |
| Manutenção | Removidos `venv`, `__pycache__`, `.pyc` e arquivo antigo de templates do pacote final. |

## Observações importantes

O arquivo `banco.db` foi mantido porque o pacote original continha dados de produção. O backup anterior às correções está em `backups/banco_original_pre_hardening.db`. Caso vá hospedar em HTTPS, mantenha `SESSION_COOKIE_SECURE=1`. Para ambiente local sem HTTPS, use temporariamente `SESSION_COOKIE_SECURE=0`.
