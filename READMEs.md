# arkgit

Ferramenta de linha de comando para reescrita de histórico Git, **100% pura**: usa apenas comandos nativos do Git (`git filter-branch`), sem dependência de Python, `git-filter-repo` ou qualquer pacote externo. No Windows, os filtros rodam no `sh.exe` que já vem embutido no Git for Windows.

## Comandos

### `arkgit author` — alterar autor e committer

Substitui nome e e-mail de autor/committer em todo o histórico do repositório, preservando datas, mensagens e estrutura de branches e tags.

```bash
arkgit author old@email.com new@email.com "Novo Nome"
```

### `arkgit erase` — remover arquivos ou pastas do histórico

Remove completamente arquivos ou pastas de **todos os commits**, útil para eliminar chaves, senhas ou arquivos sensíveis commitados por engano. Commits que ficarem vazios após a remoção são descartados automaticamente (`--prune-empty`).

Aceita arquivos, pastas e globs misturados na mesma chamada — não é preciso indicar o que é pasta e o que é arquivo:

```bash
# arquivo, pasta e glob juntos
arkgit erase .env secrets/ "certs/*.pem"

# simular antes de executar: lista os commits afetados sem alterar nada
arkgit erase --dry-run .env secrets/
```

> Dica: globs devem ir entre aspas para não serem expandidos pelo shell local.

### `arkgit help`

Mostra a ajuda com todos os comandos e opções.

## Instalação

### Linux / macOS

```bash
git clone https://github.com/Tooark/arkgit.git
cd arkgit
./install.sh
```

O script copia o `arkgit` para `~/.local/bin`. Se essa pasta não estiver no seu `PATH`, o instalador avisa como adicionar.

### Windows (PowerShell)

```powershell
git clone https://github.com/Tooark/arkgit.git
cd arkgit
.\install.ps1
```

O script instala em `%LOCALAPPDATA%\arkgit`, cria um wrapper `arkgit.cmd` e adiciona a pasta ao `PATH` do usuário. Abra um novo terminal após a instalação.

## Como funciona

| Comando | Mecanismo Git |
| --- | --- |
| `author` | `git filter-branch --env-filter` reescreve as variáveis `GIT_AUTHOR_*` e `GIT_COMMITTER_*` de cada commit cujo e-mail bate com o antigo. |
| `erase` | `git filter-branch --index-filter` executa `git rm -r --cached --ignore-unmatch` em cada commit. O `-r` cobre pastas e não interfere em arquivos; o `--ignore-unmatch` evita erro em commits onde o caminho não existe. |

Em ambos os casos, ao final a ferramenta remove os backups em `refs/original/`, expira o reflog e roda `git gc --prune=now` para que o histórico antigo desapareça de fato do repositório local.

Antes de qualquer reescrita, o arkgit:

1. Valida que o diretório é um repositório Git;
2. Pede confirmação explícita (digitar `SIM`);
3. Cria um stash automático (incluindo arquivos não rastreados) se houver mudanças locais.

## Publicando o novo histórico

Após a reescrita, os hashes de todos os commits mudam. Para atualizar o remoto:

```bash
git push origin --force-with-lease --all
git push origin --force-with-lease --tags
```

Todos que possuem clones do repositório devem cloná-lo novamente (ou fazer `git fetch` + `git reset --hard origin/main`), pois o histórico antigo e o novo são incompatíveis.

## Avisos importantes

- **Segredos removidos continuam comprometidos.** Remover uma chave do histórico não desfaz o vazamento: qualquer pessoa que clonou ou viu o repositório pode tê-la copiado, e plataformas como o GitHub podem manter os objetos antigos acessíveis por hash em pull requests e caches por algum tempo. **Sempre revogue e rotacione a credencial.**
- **Assinaturas GPG são invalidadas.** Commits reescritos perdem assinaturas anteriores.
- **Faça backup.** Antes de rodar em um repositório importante, clone uma cópia de segurança: `git clone --mirror <repo> backup.git`.
- O Git exibe um aviso recomendando `git-filter-repo` no lugar do `filter-branch`; o arkgit suprime esse aviso (`FILTER_BRANCH_SQUELCH_WARNING`) justamente porque o objetivo do projeto é não ter dependências. Para repositórios gigantes (dezenas de milhares de commits), o `filter-repo` é mais rápido — mas exige Python.

## Licença

MIT
