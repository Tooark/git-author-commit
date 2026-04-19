# Git Author - Ferramenta de Alteração de Autor no Histórico Git

Uma ferramenta poderosa para alterar informações de autor (email e nome) em todo o histórico de um repositório Git, sem perder commits ou histórico.

## 📋 Descrição do Projeto

O **Git Author** utiliza `git-filter-repo` para reescrever o histórico de commits, permitindo que você altere o email e nome do autor de todos os commits de uma vez. Isso é especialmente útil quando:

- Você começou commits com um email corporativo e agora usa um pessoal
- Você precisou corrigir o nome ou email em commits passados
- Você está consolidando contas de git
- Você precisar de consistência de autoria no repositório

**Aviso Importante**: Esta operação é **irreversível** e modifica todos os commits do repositório. Sempre faça um backup antes!

## ⚙️ Pré-requisitos

### Sistema Operacional Independente

1. **Git** instalado e configurado (versão 2.0 ou superior)
2. **Python 3** instalado (versão 3.6 ou superior)
3. **git-filter-repo** instalado via pip

### Instalando Pré-requisitos

#### Windows

```powershell
# Instalar Python (se não tiver)
# Download em https://www.python.org/downloads/
# Ou via Chocolatey:
choco install python

# Instalar git-filter-repo
pip install git-filter-repo

# Verificar instalação
git-filter-repo --version
```

#### Linux (Ubuntu/Debian)

```bash
# Instalar Python (geralmente já vem instalado)
sudo apt-get update
sudo apt-get install python3 python3-pip

# Instalar git-filter-repo
sudo pip3 install git-filter-repo

# Verificar instalação
git-filter-repo --version
```

#### macOS

```bash
# Instalar Python (via Homebrew)
brew install python3

# Instalar git-filter-repo
pip3 install git-filter-repo

# Verificar instalação
git-filter-repo --version
```

## 🚀 Instalação e Configuração do PATH

### Windows

#### Opção 1: Adicionar ao PATH (Permanente)

1. **Encontre a pasta do script Git Author**:

   ```powershell
   # Exemplo de caminho onde o script está localizado
   C:\Repositorio\Programas\Git-Author
   ```

2. **Abra o Editor de Variáveis de Ambiente**:
   - Pressione `Windows + X` e selecione **"Sistema"**
   - Clique em **"Configurações avançadas do sistema"**
   - Clique em **"Variáveis de Ambiente"** (botão no canto inferior direito)
   - Sob "Variáveis do usuário", clique em **"Novo..."**

3. **Crie a variável**:
   - Nome da variável: `GIT_AUTHOR_SCRIPTS`
   - Valor da variável: `C:\Repositorio\Programas\Git-Author`

4. **Adicione ao PATH**:
   - Em "Variáveis do sistema", encontre `Path` e clique em **"Editar..."**
   - Clique em **"Novo"** e adicione: `%GIT_AUTHOR_SCRIPTS%`
   - Clique em **"OK"** em todas as caixas de diálogo

5. **Reinicie o PowerShell** ou o CMD e teste:

   ```powershell
   git-author -OldEmail old@email.com -NewEmail user@tooark.com -NewName "Tooark User"
   ```

#### Opção 2: Criar Alias no PowerShell (Rápido)

1. **Abra o PowerShell como Administrador**

2. **Edite o perfil do PowerShell**:

   ```powershell
   # Crie ou edite o arquivo de perfil
   if (!(Test-Path -Path $PROFILE)) {
       New-Item -ItemType File -Path $PROFILE -Force
   }
   notepad $PROFILE
   ```

3. **Adicione o alias ao arquivo**:

   ```powershell
   # Git Author Script Alias
   Set-Alias -Name git-author -Value "C:\Repositorio\Programas\Git-Author\git-author.ps1"
   ```

4. **Salve e feche o editor**

5. **Reinicie o PowerShell** e teste:

   ```powershell
   git-author -OldEmail old@email.com -NewEmail user@tooark.com -NewName "Tooark User"
   ```

### Linux e macOS

#### Opção 1: Adicionar ao PATH (Permanente)

1. **Copie ou crie link simbólico para um diretório no PATH**:

   ```bash
   # Opção A: Copiar para ~/.local/bin
   mkdir -p ~/.local/bin
   cp ~/Repositorio/Programas/Git-Author/git-author.sh ~/.local/bin/git-author
   chmod +x ~/.local/bin/git-author

   # Opção B: Criar link simbólico
   ln -s ~/Repositorio/Programas/Git-Author/git-author.sh ~/.local/bin/git-author
   chmod +x ~/.local/bin/git-author
   ```

2. **Adicione ao PATH se necessário**:
   - Abra o arquivo `~/.bashrc`, `~/.zshrc` ou `~/.profile` (dependendo do seu shell)

   ```bash
   # Adicione esta linha ao final do arquivo
   export PATH="$HOME/.local/bin:$PATH"
   ```

3. **Recarregue o shell**:

   ```bash
   source ~/.bashrc  # ou ~/.zshrc ou ~/.profile
   ```

4. **Teste**:

   ```bash
   git-author old@email.com user@tooark.com "Tooark User"
   ```

#### Opção 2: Criar um Alias no Shell

1. **Edite seu arquivo de configuração do shell**:

   ```bash
   # Para Bash
   nano ~/.bashrc

   # Para Zsh
   nano ~/.zshrc
   ```

2. **Adicione o alias**:

   ```bash
   alias git-author="~/Repositorio/Programas/Git-Author/git-author.sh"
   ```

3. **Recarregue o shell**:

   ```bash
   source ~/.bashrc  # ou ~/.zshrc
   ```

4. **Teste**:

   ```bash
   git-author old@email.com user@tooark.com "Tooark User"
   ```

## 📖 Como Usar

### Uso Básico

#### Windows (PowerShell)

```powershell
git-author -OldEmail "old@email.com" -NewEmail "user@tooark.com" -NewName "Tooark User"
```

#### Linux/macOS (Bash)

```bash
git-author old@email.com user@tooark.com "Tooark User"
```

### Usando Valores Padrão

Se você não fornecer argumentos, o script usará os valores padrão:

- **Old Email**: `old@email.com`
- **New Email**: `user@tooark.com`
- **New Name**: `Tooark User`

#### Windows

```powershell
git-author
```

#### Linux/macOS

```bash
git-author
```

### Passo a Passo para Usar

1. **Navegue até seu repositório Git**:

   ```bash
   cd /caminho/para/seu/repositorio
   ```

2. **Execute o script** (após configurar no PATH):

   ```powershell
   # Windows
   git-author -OldEmail "old@email.com" -NewEmail "user@tooark.com" -NewName "Tooark User"

   # Linux/macOS
   git-author old@email.com user@tooark.com "Tooark User"
   ```

3. **Confirme quando solicitado**:
   - O script pedirá para confirmar a operação
   - **Digite 'SIM'** (Windows) ou **'YES'** (Linux/macOS) para continuar

4. **Aguarde a conclusão**:
   - O script criará um stash se houver mudanças locais
   - Executará `git-filter-repo` para reescrever o histórico
   - Mostrará "Processo concluído com sucesso!" ao final

### Exemplo Completo

```powershell
# Windows
PS C:\projetos\meu-repo> git-author -OldEmail "old@email.com" -NewEmail "user@tooark.com" -NewName "Tooark User"
=== Git Rename Tool ===
Old Email : old@email.com
New Email : user@tooark.com
New Name  : Tooark User

Do you really want to rewrite the ENTIRE repository history? (Y/n)
Type 'SIM' to continue: SIM
Preparing repository...
Local changes detected. Creating stash 'Git-Author-Commit'...
Stash created successfully: 'Git-Author-Commit'.
Running git-filter-repo...
[Processamento...]
Process completed successfully!
```

## ⚠️ Importante: Antes de Usar

### Backup Essencial

```bash
# Crie uma cópia completa do repositório
git clone --mirror seu-repositorio seu-repositorio.backup
```

### Remotes Afetados

Se você faz push para remotes (GitHub, GitLab, Bitbucket, etc.), após executar o script:

1. **O histórico local será reescrito**
2. **Você precisará fazer force push**:

   ```bash
   git push origin --force-with-lease  # Mais seguro que --force
   ```

3. **Todos os colaboradores precisarão fazer rebase**:

   ```bash
   # Cada colaborador deve executar no repositório local
   git rebase origin/main  # ou sua branch padrão
   ```

## 🔄 Recuperação de Stash

Se o script criou um stash antes de executar, você pode recuperá-lo após a conclusão:

```bash
git stash pop
```

## 🐛 Troubleshooting

### Erro: "git-filter-repo not found"

```powershell
# Reinstale git-filter-repo
pip install --upgrade git-filter-repo

# Ou em alguns sistemas
pip3 install --upgrade git-filter-repo
```

### Erro: "not a git repository"

```bash
# Certifique-se de estar dentro de um repositório git
git rev-parse --is-inside-work-tree

# Inicialize o repositório se necessário
git init
```

### Erro: "Stash failed"

- Verifique se você tem permissão de escrita no diretório
- Tente abrir a ferramenta como Administrador (Windows)

### Erro ao fazer push após executar

```bash
# Use force-with-lease para ser mais seguro
git push origin main --force-with-lease

# Se ainda não funcionar, sincronize seu remote
git remote update
git merge -s ours origin/main
git push origin main
```

## 📝 Exemplos de Uso

### Exemplo 1: Consolidar Emails

```powershell
# Você começou com um email pessoal, agora usa corporativo
git-author -OldEmail "old@email.com" -NewEmail "user@tooark.com" -NewName "Tooark User"
```

### Exemplo 2: Corrigir Nome

```bash
# Seus commits tinham um apelido, agora quer o nome completo
git-author user@tooark.com user@tooark.com "Tooark User Full Name"
```

### Exemplo 3: Usar de Múltiplos Repositórios

```powershell
# Após configurar no PATH, use em qualquer repositório
cd C:\projetos\projeto1
git-author -OldEmail "old@email.com" -NewEmail "new@email.com" -NewName "Nome"

cd C:\projetos\projeto2
git-author -OldEmail "old@email.com" -NewEmail "new@email.com" -NewName "Nome"
```

## 🔒 Segurança e Boas Práticas

1. **Sempre faça backup** antes de usar
2. **Teste em um repositório clone** se possível
3. **Notifique seus colaboradores** antes de fazer force push
4. **Use `--force-with-lease`** ao fazer push, é mais seguro
5. **Verifique o resultado** em alguns commits:
   
   ```bash
   git log --oneline -10
   git log -1 --format="%an <%ae>"
   ```

## 📄 Arquivos do Projeto

```plaintext
Git-Author/
├── git-author.ps1      # Script PowerShell (Windows)
├── git-author.sh       # Script Bash (Linux/macOS)
├── README.md           # Este arquivo
└── LICENSE             # Licença do projeto
```

## 📜 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

## 📧 Suporte

Para questões ou problemas, execute o script com `--help` ou consulte a seção de Troubleshooting acima.

---

**Última atualização**: Abril de 2026
**Versão**: 1.0 (Multi-plataforma)
