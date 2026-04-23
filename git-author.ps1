param(
    [string]$OldEmail = "old@email.com",
    [string]$NewEmail = "user@tooark.com",
    [string]$NewName  = "Tooark User"
)

Write-Host "=== Git Author Tool ===" -ForegroundColor Cyan
Write-Host "Old Email : $OldEmail"
Write-Host "New Email : $NewEmail"
Write-Host "New Name  : $NewName"
Write-Host ""

# Check if git-filter-repo is installed
$gitFilterRepo = Get-Command git-filter-repo -ErrorAction SilentlyContinue

if (-not $gitFilterRepo) {
    Write-Host "ERROR: git-filter-repo not found in PATH." -ForegroundColor Red
    Write-Host "Install with: pip install git-filter-repo"
    exit 1
}

# Confirmation before execution
Write-Host "Do you really want to rewrite the ENTIRE repository history?" -ForegroundColor Yellow
Write-Host "This is irreversible and affects all commits." -ForegroundColor Yellow
$confirm = Read-Host "Type 'YES' to continue"

if ($confirm -ne "YES") {
    Write-Host "Operation cancelled." -ForegroundColor Red
    exit 0
}

# Create Python callback
$commitCallback = @"
if commit.author_email == b"$OldEmail":
    commit.author_email = b"$NewEmail"
    commit.author_name = b"$NewName"
    commit.committer_email = b"$NewEmail"
    commit.committer_name = b"$NewName"
"@

Write-Host "Preparing repository..." -ForegroundColor Yellow

# Check if 'git' is available and we're inside a git repository
$gitAvailable = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitAvailable) {
    Write-Host "Warning: 'git' not available in PATH. Proceeding without stash." -ForegroundColor Yellow
} else {
    git rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Warning: Does not appear to be a git repository. Proceeding without stash." -ForegroundColor Yellow
    } else {
        # Check if there are local changes (including untracked files)
        $changes = git status --porcelain
        if ($changes) {
            Write-Host "Local changes detected. Creating stash 'Git-Author-Commit'..." -ForegroundColor Yellow
            git stash push -u -m "Git-Author-Commit"
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Stash created successfully: 'Git-Author-Commit'." -ForegroundColor Green
            } else {
                Write-Host "Failed to create stash. Aborting." -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "No local changes, proceeding." -ForegroundColor Yellow
        }
    }
}

Write-Host "Running git-filter-repo..." -ForegroundColor Yellow

git-filter-repo --force `
    --commit-callback "$commitCallback"

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nProcess completed successfully!" -ForegroundColor Green
} else {
    Write-Host "`nAn error occurred during the process." -ForegroundColor Red
}
