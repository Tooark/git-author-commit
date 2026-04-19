param(
    [string]$OldEmail = "usuario@email.com",
    [string]$NewEmail = "usuario@tooark.com",
    [string]$NewName  = "Usuario Tooark"
)

Write-Host "=== Git Rename Tool ===" -ForegroundColor Cyan
Write-Host "Old Email : $OldEmail"
Write-Host "New Email : $NewEmail"
Write-Host "New Name  : $NewName"
Write-Host ""

# Verifica se git-filter-repo está instalado
$gitFilterRepo = Get-Command git-filter-repo -ErrorAction SilentlyContinue

if (-not $gitFilterRepo) {
    Write-Host "ERRO: git-filter-repo não encontrado no PATH." -ForegroundColor Red
    Write-Host "Instale com: pip install git-filter-repo"
    exit 1
}

# Confirmação antes de executar
Write-Host "Deseja realmente reescrever TODO o histórico do repositório?" -ForegroundColor Yellow
Write-Host "Isso é irreversível e afeta todos os commits." -ForegroundColor Yellow
$confirm = Read-Host "Digite 'SIM' para continuar"

if ($confirm -ne "SIM") {
    Write-Host "Operação cancelada." -ForegroundColor Red
    exit 0
}

# Monta os callbacks Python
$emailCallback = @"
if email == b"$OldEmail":
    return b"$NewEmail"
return email
"@

$commitCallback = @"
commit.committer_email = b"$NewEmail"
commit.committer_name = b"$NewName"
"@

Write-Host "Preparando repositório..." -ForegroundColor Yellow

# Verifica se 'git' está disponível e se estamos dentro de um repositório
$gitAvailable = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitAvailable) {
    Write-Host "Aviso: 'git' não está disponível no PATH. Prosseguindo sem stash." -ForegroundColor Yellow
} else {
    git rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Aviso: não parece ser um repositório git. Prosseguindo sem stash." -ForegroundColor Yellow
    } else {
        # Verifica se há mudanças locais (inclui arquivos não rastreados)
        $changes = git status --porcelain
        if ($changes) {
            Write-Host "Mudanças locais detectadas. Criando stash 'Git-Author-Commit'..." -ForegroundColor Yellow
            git stash push -u -m "Git-Author-Commit"
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Stash criado com sucesso: 'Git-Author-Commit'." -ForegroundColor Green
            } else {
                Write-Host "Falha ao criar stash. Abortando." -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "Sem mudanças locais, prosseguindo." -ForegroundColor Yellow
        }
    }
}

Write-Host "Executando git-filter-repo..." -ForegroundColor Yellow

git-filter-repo --force `
    --email-callback "$emailCallback" `
    --commit-callback "$commitCallback"

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nProcesso concluído com sucesso!" -ForegroundColor Green
} else {
    Write-Host "`nOcorreu um erro durante o processo." -ForegroundColor Red
}
