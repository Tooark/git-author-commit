# =============================================================
# arkgit - Ferramenta de reescrita de histórico Git
# 100% puro: usa apenas comandos nativos do Git (filter-branch).
# Os filtros rodam no sh.exe embutido no Git for Windows,
# então não há dependência externa alguma.
#
# Comandos:
#   arkgit author <old-email> <new-email> "<new-name>"
#   arkgit erase [--dry-run] <path> [path...]
#   arkgit help
# =============================================================
param(
    [Parameter(Position = 0)]
    [string]$Command = "help",

    [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
    [string[]]$Args = @()
)

$ErrorActionPreference = "Stop"
$VERSION = "2.0.0"

# ---------------------------------------------------------- utils

function Show-Usage {
    Write-Host @"
arkgit v$VERSION - Reescrita de histórico Git sem dependências

Uso:
  arkgit author <old-email> <new-email> "<new-name>"
      Substitui autor e committer em todo o histórico.

  arkgit erase [--dry-run] <path> [path...]
      Remove arquivos ou pastas de TODO o histórico.
      Aceita arquivos, pastas e globs (entre aspas), misturados:
        arkgit erase .env secrets/ "certs/*.pem"

  arkgit help
      Mostra esta ajuda.

Opções do erase:
  --dry-run   Apenas lista os commits que tocam nos caminhos,
              sem reescrever nada.
"@
}

function Fail([string]$Message) {
    Write-Host "Erro: $Message" -ForegroundColor Red
    exit 1
}

function Require-Repo {
    git rev-parse --is-inside-work-tree 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail "este diretório não é um repositório Git." }
}

function Confirm-Rewrite {
    Write-Host ""
    Write-Host "ATENÇÃO: esta operação reescreve TODO o histórico do repositório." -ForegroundColor Yellow
    Write-Host "Todos os hashes de commit vão mudar e será necessário force push." -ForegroundColor Yellow
    $confirm = Read-Host "Digite 'SIM' para continuar"
    if ($confirm -ne "SIM") { Write-Host "Operação cancelada."; exit 0 }
}

function Stash-IfDirty {
    $script:Stashed = $false
    if (git status --porcelain) {
        Write-Host "Mudanças locais detectadas. Criando stash 'arkgit'..."
        git stash push -u -m "arkgit"
        if ($LASTEXITCODE -ne 0) { Fail "falha ao criar stash." }
        $script:Stashed = $true
    }
}

function Stash-Reminder {
    if ($script:Stashed) {
        Write-Host ""
        Write-Host "Lembrete: suas mudanças locais estão no stash. Recupere com: git stash pop" -ForegroundColor Yellow
    }
}

function Cleanup-Refs {
    Write-Host "Limpando refs de backup e histórico antigo..."
    $backupRefs = git for-each-ref --format="%(refname)" refs/original/
    foreach ($ref in $backupRefs) {
        if ($ref) { git update-ref -d $ref }
    }
    git reflog expire --expire=now --all
    git gc --prune=now --aggressive
}

function Push-Hint {
    Write-Host ""
    Write-Host "Processo concluído com sucesso!" -ForegroundColor Green
    Write-Host "Para publicar o novo histórico:"
    Write-Host "  git push origin --force-with-lease --all"
    Write-Host "  git push origin --force-with-lease --tags"
}

# Escapa um valor para uso seguro dentro de aspas simples no sh
function Sh-Quote([string]$Value) {
    return "'" + ($Value -replace "'", "'\''") + "'"
}

# ---------------------------------------------------------- author

function Invoke-Author([string[]]$A) {
    if ($A.Count -lt 3) {
        Fail 'uso: arkgit author <old-email> <new-email> "<new-name>"'
    }
    $OldEmail = $A[0]; $NewEmail = $A[1]; $NewName = $A[2]

    Require-Repo

    Write-Host "=== arkgit author ===" -ForegroundColor Cyan
    Write-Host "Old Email : $OldEmail"
    Write-Host "New Email : $NewEmail"
    Write-Host "New Name  : $NewName"

    Confirm-Rewrite
    Stash-IfDirty

    Write-Host "Executando git filter-branch (env-filter)..."
    $envFilter = @"
if [ "`$GIT_COMMITTER_EMAIL" = "$OldEmail" ]; then
  export GIT_COMMITTER_NAME="$NewName"
  export GIT_COMMITTER_EMAIL="$NewEmail"
fi
if [ "`$GIT_AUTHOR_EMAIL" = "$OldEmail" ]; then
  export GIT_AUTHOR_NAME="$NewName"
  export GIT_AUTHOR_EMAIL="$NewEmail"
fi
"@

    $env:FILTER_BRANCH_SQUELCH_WARNING = "1"
    git filter-branch -f --env-filter $envFilter --tag-name-filter cat -- --branches --tags
    if ($LASTEXITCODE -ne 0) { Fail "falha ao executar git filter-branch." }

    Cleanup-Refs
    Stash-Reminder
    Push-Hint
    Write-Host 'Verifique com: git log -5 --format="%h %an <%ae> | committer: %cn <%ce>"'
}

# ---------------------------------------------------------- erase

function Invoke-Erase([string[]]$A) {
    $dryRun = $false
    $paths = @()

    foreach ($arg in $A) {
        switch ($arg) {
            "--dry-run" { $dryRun = $true }
            default {
                if ($arg -like "-*") { Fail "opção desconhecida: $arg" }
                $paths += $arg
            }
        }
    }

    if ($paths.Count -eq 0) {
        Fail "uso: arkgit erase [--dry-run] <path> [path...]"
    }

    Require-Repo

    Write-Host "=== arkgit erase ===" -ForegroundColor Cyan
    Write-Host "Caminhos a remover do histórico:"
    foreach ($p in $paths) { Write-Host "  - $p" }

    if ($dryRun) {
        Write-Host ""
        Write-Host "[dry-run] Commits que tocam nesses caminhos:" -ForegroundColor Yellow
        git log --all --oneline -- @paths
        Write-Host ""
        Write-Host "[dry-run] Nada foi alterado. Remova --dry-run para executar."
        return
    }

    Confirm-Rewrite
    Stash-IfDirty

    # Monta a lista de caminhos com quoting seguro para o sh do filtro
    $quoted = ($paths | ForEach-Object { Sh-Quote $_ }) -join " "

    Write-Host "Executando git filter-branch (index-filter)..."
    $env:FILTER_BRANCH_SQUELCH_WARNING = "1"
    git filter-branch -f `
        --index-filter "git rm -r --cached --ignore-unmatch -- $quoted" `
        --prune-empty --tag-name-filter cat -- --branches --tags
    if ($LASTEXITCODE -ne 0) { Fail "falha ao executar git filter-branch." }

    Cleanup-Refs
    Stash-Reminder
    Push-Hint
    Write-Host ""
    Write-Host "IMPORTANTE: se o conteúdo removido era uma chave/segredo," -ForegroundColor Yellow
    Write-Host "considere-o COMPROMETIDO e revogue/rotacione mesmo assim." -ForegroundColor Yellow
}

# ---------------------------------------------------------- main

switch ($Command.ToLower()) {
    "author"    { Invoke-Author $Args }
    "erase"     { Invoke-Erase $Args }
    "help"      { Show-Usage }
    "-h"        { Show-Usage }
    "--help"    { Show-Usage }
    "--version" { Write-Host "arkgit v$VERSION" }
    "-v"        { Write-Host "arkgit v$VERSION" }
    default     { Fail "comando desconhecido: $Command (use 'arkgit help')" }
}
