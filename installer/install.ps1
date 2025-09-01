# DiaryMCP Auto-Installer v1.1 - PowerShell
# Instala automaticamente o DiaryMCP sem usar tokens de IA

param(
    [switch]$Force = $false
)

# Configurações
$ErrorActionPreference = "Stop"
$script:ProjectName = ""
$script:ProjectType = ""  
$script:ProjectLanguage = ""

# Cores para output
function Write-ColoredText {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    Write-Host $Text -ForegroundColor $Color
}

function Write-Logo {
    Write-ColoredText "╔═══════════════════════════════════════╗" "Blue"
    Write-ColoredText "║        DiaryMCP Auto-Installer        ║" "Blue"
    Write-ColoredText "║              v1.1 - 2024              ║" "Blue" 
    Write-ColoredText "║                                       ║" "Blue"
    Write-ColoredText "║     🚀 Zero Tokens Installation       ║" "Blue"
    Write-ColoredText "╚═══════════════════════════════════════╝" "Blue"
    Write-Host
}

function Detect-ProjectName {
    # Tentar package.json primeiro
    if (Test-Path "package.json") {
        try {
            $packageJson = Get-Content "package.json" | ConvertFrom-Json
            if ($packageJson.name -and $packageJson.name -ne "") {
                return $packageJson.name
            }
        }
        catch {
            # Fallback para regex
            $content = Get-Content "package.json" -Raw
            if ($content -match '"name"\s*:\s*"([^"]*)"') {
                return $Matches[1]
            }
        }
    }
    
    # Tentar outros arquivos de configuração
    if (Test-Path "pom.xml") {
        $content = Get-Content "pom.xml" -Raw
        if ($content -match '<artifactId>([^<]*)</artifactId>') {
            return $Matches[1]
        }
    }
    
    if (Test-Path "Cargo.toml") {
        $content = Get-Content "Cargo.toml"
        $nameLine = $content | Where-Object { $_ -match '^name\s*=\s*"([^"]*)"' }
        if ($nameLine) {
            if ($nameLine -match '^name\s*=\s*"([^"]*)"') {
                return $Matches[1]
            }
        }
    }
    
    if (Test-Path "go.mod") {
        $firstLine = Get-Content "go.mod" | Select-Object -First 1
        if ($firstLine -match '^module\s+(.+)$') {
            return Split-Path $Matches[1] -Leaf
        }
    }
    
    # Fallback: nome da pasta atual
    return (Get-Item .).Name
}

function Detect-ProjectType {
    if (Test-Path "package.json") { return "javascript" }
    elseif (Test-Path "pom.xml" -or (Get-ChildItem "*.gradle" -ErrorAction SilentlyContinue)) { return "java" }
    elseif (Test-Path "Cargo.toml") { return "rust" }
    elseif (Test-Path "requirements.txt" -or Test-Path "setup.py" -or Test-Path "pyproject.toml") { return "python" }
    elseif (Test-Path "go.mod") { return "go" }
    elseif (Test-Path "composer.json") { return "php" }
    elseif (Test-Path "Gemfile") { return "ruby" }
    elseif (Get-ChildItem "*.csproj" -ErrorAction SilentlyContinue -or Get-ChildItem "*.sln" -ErrorAction SilentlyContinue) { return "dotnet" }
    else { return "generic" }
}

function Detect-Language {
    $extensions = @{
        "*.js|*.ts|*.jsx|*.tsx" = "JavaScript/TypeScript"
        "*.py" = "Python"  
        "*.java" = "Java"
        "*.rs" = "Rust"
        "*.go" = "Go"
        "*.php" = "PHP"
        "*.rb" = "Ruby"
        "*.cs" = "C#"
    }
    
    foreach ($ext in $extensions.Keys) {
        $files = Get-ChildItem -Recurse -Include ($ext -split '\|') -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($files) {
            return $extensions[$ext]
        }
    }
    
    return "Mixed/Generic"
}

function Detect-GitBranch {
    try {
        if (Test-Path ".git" -and (Get-Command git -ErrorAction SilentlyContinue)) {
            $branch = & git branch --show-current 2>$null
            if ($branch) { return $branch }
        }
    }
    catch {
        # Ignore git errors
    }
    return "main"
}

function Create-DirectoryStructure {
    Write-ColoredText "   📁 Criando estrutura .diary/..." "Cyan"
    
    $directories = @(
        ".diary",
        ".diary/data", 
        ".diary/data/entries",
        ".diary/io",
        ".diary/engine",
        ".diary/engine/prompts", 
        ".diary/scripts"
    )
    
    foreach ($dir in $directories) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    # Verificar se templates existem junto com o script
    $scriptDir = Split-Path -Parent $MyInvocation.ScriptName
    $templatesPath = Join-Path $scriptDir "templates"
    
    if (Test-Path $templatesPath) {
        Write-ColoredText "   📋 Copiando templates..." "Cyan"
        Copy-Item -Path "$templatesPath/*" -Destination ".diary/" -Recurse -Force
    }
    else {
        Write-ColoredText "   📋 Criando templates inline..." "Cyan"
        Create-TemplatesInline
    }
}

function Create-TemplatesInline {
    # ativar.md
    $ativarContent = @'
# 🚀 ATIVAÇÃO DO DIARYMCP - [PROJECT_NAME]

Você agora é o motor de execução do DiaryMCP para o projeto **[PROJECT_NAME]**.

## VERIFICAÇÃO RÁPIDA
- **Projeto**: [PROJECT_NAME]
- **Tipo**: [PROJECT_TYPE]
- **Instalado em**: [INSTALL_DATE]
- **Linguagem**: [PRIMARY_LANGUAGE]

## COMANDOS DISPONÍVEIS

### Captura Rápida
- **User**: "Capture a sessão"
- **User**: "Diary: [qualquer nota rápida]"  
- **User**: "Finalizando: [descrição]"

### Comandos Completos
- `capture [nota]` - Captura contexto atual com nota opcional
- `status` - Mostra estatísticas do diário
- `last` - Mostra última entrada
- `search [termo]` - Busca nas entradas
- `connect` - Sugere conexões entre entradas
- `report [período]` - Relatório do período (hoje, semana, mês)

### Comandos de Manutenção
- `rebuild` - Reconstrói índices a partir das entradas
- `cleanup` - Remove arquivos temporários
- `export [formato]` - Exporta dados (json, md, html)

## PROTOCOLO DE CAPTURA

### Sempre gerar **summary.json** (OBRIGATÓRIO!):
Cada captura DEVE criar um resumo compacto em summary.json com:
- Máximo 1000 tokens
- Resumo ultra-conciso
- Decisões principais
- Insights importantes
- Contexto para futuras sessões
- Próximos passos

### Próxima Ação
Responda: **"DiaryMCP ativo para [PROJECT_NAME]. O que deseja fazer?"**

---
*Sistema DiaryMCP v1.1 - Auto-instalado com sucesso*
'@
    Set-Content -Path ".diary/ativar.md" -Value $ativarContent
    
    # manifest.yaml
    $manifestContent = @'
# DiaryMCP Manifest - [PROJECT_NAME]
version: "1.1"
project:
  name: "[PROJECT_NAME]"
  type: "[PROJECT_TYPE]"
  language: "[PRIMARY_LANGUAGE]"
  installed_at: "[INSTALL_DATE]"

system:
  summary_optimization: true
  token_limit_per_summary: 1000
  retention_days: 30

paths:
  data: "data/"
  entries: "data/entries/"
  engine: "engine/"
  scripts: "scripts/"
  io: "io/"
'@
    Set-Content -Path ".diary/manifest.yaml" -Value $manifestContent
    
    # engine/rules.md básico
    $rulesContent = @'
# DiaryMCP - Regras de Negócio

## REGRAS DE OTIMIZAÇÃO DE TOKENS (CRÍTICO!)

### Para CAPTURA de nova sessão:
- Carregar APENAS summary.json das últimas 5 sessões
- Carregar index.json para metadados  
- NUNCA carregar entry.md, tech.md, story.md de sessões antigas

### Para COMANDOS de consulta:
- status: load apenas index.json + tags.json
- search: buscar primeiro em index.json, depois summary.json
- report: usar summary.json do período

### Regra de Ouro dos 30 Dias:
- Sessões > 30 dias: IA lê APENAS summary.json
- summary.json é OBRIGATÓRIO em toda captura
- summary.json MAX 1000 tokens sempre

## SEMPRE criar summary.json com:
- Resumo ultra-conciso (300 chars)
- 3 decisões principais max
- 3 insights importantes max
- 5 arquivos principais max
- Contexto para futuras sessões (250 chars)
- 3 próximos passos max
'@
    Set-Content -Path ".diary/engine/rules.md" -Value $rulesContent
    
    # Script de captura básico (PowerShell)
    $captureContent = @'
# DiaryMCP Capture Script - PowerShell

param(
    [Parameter(Mandatory=$true)]
    [string]$Note
)

if (-not $Note) {
    Write-Host "Usage: .\capture.ps1 -Note 'your session note'"
    Write-Host "Example: .\capture.ps1 -Note 'Implemented JWT authentication'"
    exit 1
}

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
$entryId = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH-mm-ss")
$dateFolder = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd")

Write-Host "📝 Capturing session with note: $Note" -ForegroundColor Green
Write-Host "🕒 Timestamp: $timestamp" -ForegroundColor Blue

$entryPath = ".diary/data/entries/$dateFolder/$entryId"
New-Item -ItemType Directory -Path $entryPath -Force | Out-Null

$entryContent = @"
# Session - $timestamp

## User Note
$Note

## Captured by Script
This entry was created by the capture script.
To process it fully, use: "Ative o DiaryMCP" and then "capture $Note"
"@

Set-Content -Path "$entryPath/entry.md" -Value $entryContent

Write-Host "✅ Basic entry created. Use DiaryMCP with IA for full processing." -ForegroundColor Green
'@
    Set-Content -Path ".diary/scripts/capture.ps1" -Value $captureContent
}

function Personalize-Files {
    param(
        [string]$ProjectName,
        [string]$ProjectType,
        [string]$ProjectLanguage
    )
    
    $installDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $gitBranch = Detect-GitBranch
    
    Write-ColoredText "   ⚙️  Personalizando para: $ProjectName" "Cyan"
    
    # Personalizar ativar.md
    if (Test-Path ".diary/ativar.md") {
        $content = Get-Content ".diary/ativar.md" -Raw
        $content = $content -replace '\[PROJECT_NAME\]', $ProjectName
        $content = $content -replace '\[PROJECT_TYPE\]', $ProjectType  
        $content = $content -replace '\[INSTALL_DATE\]', $installDate
        $content = $content -replace '\[PRIMARY_LANGUAGE\]', $ProjectLanguage
        Set-Content -Path ".diary/ativar.md" -Value $content
    }
    
    # Personalizar manifest.yaml
    if (Test-Path ".diary/manifest.yaml") {
        $content = Get-Content ".diary/manifest.yaml" -Raw
        $content = $content -replace '\[PROJECT_NAME\]', $ProjectName
        $content = $content -replace '\[PROJECT_TYPE\]', $ProjectType
        $content = $content -replace '\[PRIMARY_LANGUAGE\]', $ProjectLanguage
        $content = $content -replace '\[INSTALL_DATE\]', $installDate
        Set-Content -Path ".diary/manifest.yaml" -Value $content
    }
    
    # Criar index.json personalizado
    $indexJson = @{
        project = $ProjectName
        installed_at = $installDate
        version = "1.1"
        project_type = $ProjectType
        language = $ProjectLanguage
        git_branch = $gitBranch
        entries = @()
        edges = @()
        stats = @{
            total_entries = 0
            total_sessions = 0
            last_capture = $null
        }
        optimization = @{
            summary_system = "enabled"
            token_limit_per_summary = 1000
            summary_retention_days = 30
        }
    }
    
    $indexJson | ConvertTo-Json -Depth 10 | Set-Content ".diary/data/index.json"
    
    # Criar tags.json inicial
    $tagsJson = @{
        tags = @{}
        categories = @{
            feature = @()
            bug = @()
            refactor = @()
            risk = @()  
            insight = @()
        }
        last_updated = $installDate
    }
    
    $tagsJson | ConvertTo-Json -Depth 10 | Set-Content ".diary/data/tags.json"
}

function Setup-GitIgnore {
    $gitignoreEntries = @"

# DiaryMCP
.diary/io/
.diary/data/entries/
.diary/scripts/capture.ps1.log
"@
    
    if (Test-Path ".gitignore") {
        $content = Get-Content ".gitignore" -Raw
        if ($content -notlike "*diary/io/*") {
            Write-ColoredText "   📝 Adicionando entradas ao .gitignore..." "Cyan"
            Add-Content ".gitignore" -Value $gitignoreEntries
        }
        else {
            Write-ColoredText "   ✅ .gitignore já configurado" "Cyan"  
        }
    }
    else {
        Write-ColoredText "   📝 Criando .gitignore..." "Cyan"
        Set-Content ".gitignore" -Value $gitignoreEntries
    }
}

function Validate-Installation {
    $errors = 0
    
    Write-ColoredText "   🔍 Verificando arquivos essenciais..." "Cyan"
    
    $requiredFiles = @(
        ".diary/ativar.md",
        ".diary/manifest.yaml", 
        ".diary/data/index.json",
        ".diary/data/tags.json"
    )
    
    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-ColoredText "   ✅ $file" "Green"
        }
        else {
            Write-ColoredText "   ❌ $file" "Red"
            $errors++
        }
    }
    
    $requiredDirs = @(
        ".diary/data/entries",
        ".diary/engine",
        ".diary/scripts"
    )
    
    foreach ($dir in $requiredDirs) {
        if (Test-Path $dir -PathType Container) {
            Write-ColoredText "   ✅ $dir/" "Green"
        }
        else {
            Write-ColoredText "   ❌ $dir/" "Red"
            $errors++
        }
    }
    
    if ($errors -gt 0) {
        Write-ColoredText "❌ Instalação incompleta ($errors erros)" "Red"
        exit 1
    }
}

function Show-NextSteps {
    Write-Host
    Write-ColoredText "🎯 PRÓXIMOS PASSOS:" "Green"
    Write-ColoredText "   1. Teste a instalação: ""Ative o DiaryMCP""" "Yellow"
    Write-ColoredText "   2. Primeira captura:   ""capture Primeira sessão de teste""" "Yellow"
    Write-ColoredText "   3. Ver status:         ""status""" "Yellow"
    Write-Host
    Write-ColoredText "📊 ECONOMIA DE TOKENS:" "Magenta"
    Write-ColoredText "   • Esta instalação: 0 tokens usados" "Green"
    Write-ColoredText "   • Futuras sessões: 90%+ economia com resumos" "Green"
    Write-Host
    Write-ColoredText "🗑️ LIMPEZA:" "Cyan"
    Write-ColoredText "   A pasta de instalação pode ser removida:" "White"
    Write-ColoredText "   Remove-Item -Recurse -Force .\DiaryMCP-AutoInstaller\" "Yellow"
    Write-Host
    Write-ColoredText "✨ DiaryMCP v1.1 instalado e otimizado!" "Green"
}

# ============================================================================
# SCRIPT PRINCIPAL
# ============================================================================

Write-Logo

# 1. Verificar se já existe .diary/
Write-ColoredText "🔍 Verificando instalação existente..." "Blue"
if (Test-Path ".diary" -PathType Container) {
    if (-not $Force) {
        Write-ColoredText "⚠️  .diary/ já existe neste projeto." "Yellow"
        $response = Read-Host "   Sobrescrever instalação? (y/N)"
        if ($response -notmatch '^[Yy]$') {
            Write-ColoredText "❌ Instalação cancelada pelo usuário" "Red"
            exit 1
        }
    }
    Write-ColoredText "🗑️  Removendo instalação anterior..." "Yellow"
    Remove-Item ".diary" -Recurse -Force
}

# 2. Detectar projeto  
Write-ColoredText "🔍 Detectando projeto..." "Blue"
$script:ProjectName = Detect-ProjectName
$script:ProjectType = Detect-ProjectType
$script:ProjectLanguage = Detect-Language
$osInfo = if ($IsWindows -or $env:OS -eq "Windows_NT") { "Windows" } else { $PSVersionTable.Platform }

Write-ColoredText "   📁 Nome: $script:ProjectName" "Green"
Write-ColoredText "   🏷️  Tipo: $script:ProjectType" "Green"
Write-ColoredText "   💻 Linguagem: $script:ProjectLanguage" "Green"  
Write-ColoredText "   🖥️  Sistema: $osInfo" "Green"

# 3. Criar estrutura
Write-ColoredText "🏗️  Criando estrutura .diary/..." "Blue"
Create-DirectoryStructure

# 4. Personalizar arquivos
Write-ColoredText "⚙️  Personalizando configurações..." "Blue"  
Personalize-Files -ProjectName $script:ProjectName -ProjectType $script:ProjectType -ProjectLanguage $script:ProjectLanguage

# 5. Configurar .gitignore
Write-ColoredText "📝 Configurando .gitignore..." "Blue"
Setup-GitIgnore

# 6. Validar instalação
Write-ColoredText "✅ Validando instalação..." "Blue"
Validate-Installation

# 7. Sucesso!
Write-Host
Write-ColoredText "╔══════════════════════════════════════╗" "Green"
Write-ColoredText "║      🎉 INSTALAÇÃO CONCLUÍDA!        ║" "Green"
Write-ColoredText "╚══════════════════════════════════════╝" "Green"

Show-NextSteps