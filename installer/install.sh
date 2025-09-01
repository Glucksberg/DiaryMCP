#!/bin/bash
# DiaryMCP Auto-Installer v1.1
# Instala automaticamente o DiaryMCP sem usar tokens de IA

set -e  # Exit on any error

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logo ASCII
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════╗
║        DiaryMCP Auto-Installer        ║
║              v1.1 - 2024              ║
║                                       ║
║     🚀 Zero Tokens Installation       ║
╚═══════════════════════════════════════╝
EOF
echo -e "${NC}"

# Funções de detecção
detect_project_name() {
    # Ordem de prioridade para detectar nome
    if [ -f "package.json" ] && command -v jq >/dev/null 2>&1; then
        local name=$(jq -r '.name // empty' package.json 2>/dev/null)
        if [ "$name" != "null" ] && [ -n "$name" ]; then
            echo "$name"
            return
        fi
    fi
    
    if [ -f "package.json" ]; then
        local name=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' package.json | cut -d'"' -f4)
        if [ -n "$name" ]; then
            echo "$name"
            return
        fi
    fi
    
    if [ -f "pom.xml" ]; then
        local name=$(grep -o '<artifactId>[^<]*</artifactId>' pom.xml | sed 's/<[^>]*>//g' | head -1)
        if [ -n "$name" ]; then
            echo "$name"
            return
        fi
    fi
    
    if [ -f "Cargo.toml" ]; then
        local name=$(grep -o '^name[[:space:]]*=[[:space:]]*"[^"]*"' Cargo.toml | cut -d'"' -f2 | head -1)
        if [ -n "$name" ]; then
            echo "$name"
            return
        fi
    fi
    
    if [ -f "go.mod" ]; then
        local name=$(head -1 go.mod | awk '{print $2}' | xargs basename)
        if [ -n "$name" ]; then
            echo "$name"
            return
        fi
    fi
    
    # Fallback: nome da pasta
    basename "$PWD"
}

detect_project_type() {
    if [ -f "package.json" ]; then echo "javascript"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then echo "java"  
    elif [ -f "Cargo.toml" ]; then echo "rust"
    elif [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then echo "python"
    elif [ -f "go.mod" ]; then echo "go"
    elif [ -f "composer.json" ]; then echo "php"
    elif [ -f "Gemfile" ]; then echo "ruby"
    elif [ -f "*.csproj" ] || [ -f "*.sln" ]; then echo "dotnet"
    else echo "generic"; fi
}

detect_language() {
    # Detectar linguagem principal por arquivos (mais comum primeiro)
    if find . -maxdepth 3 -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" 2>/dev/null | head -1 | grep -q .; then 
        echo "JavaScript/TypeScript"
    elif find . -maxdepth 3 -name "*.py" 2>/dev/null | head -1 | grep -q .; then 
        echo "Python"
    elif find . -maxdepth 3 -name "*.java" 2>/dev/null | head -1 | grep -q .; then 
        echo "Java"
    elif find . -maxdepth 3 -name "*.rs" 2>/dev/null | head -1 | grep -q .; then 
        echo "Rust"
    elif find . -maxdepth 3 -name "*.go" 2>/dev/null | head -1 | grep -q .; then 
        echo "Go"
    elif find . -maxdepth 3 -name "*.php" 2>/dev/null | head -1 | grep -q .; then 
        echo "PHP"
    elif find . -maxdepth 3 -name "*.rb" 2>/dev/null | head -1 | grep -q .; then 
        echo "Ruby"
    elif find . -maxdepth 3 -name "*.cs" 2>/dev/null | head -1 | grep -q .; then 
        echo "C#"
    else 
        echo "Mixed/Generic"
    fi
}

detect_git_info() {
    if command -v git >/dev/null 2>&1 && [ -d ".git" ]; then
        local branch=$(git branch --show-current 2>/dev/null || echo "main")
        echo "$branch"
    else
        echo "main"
    fi
}

get_os_info() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS"  
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
        echo "Windows"
    else
        echo "Unix"
    fi
}

create_directory_structure() {
    echo -e "${CYAN}   📁 Criando .diary/...${NC}"
    mkdir -p .diary/{data/entries,io,engine/prompts,scripts}
    
    # Copiar templates se existirem na pasta do installer
    if [ -d "$(dirname "$0")/templates" ]; then
        echo -e "${CYAN}   📋 Copiando templates...${NC}"
        cp -r "$(dirname "$0")/templates"/* .diary/
    else
        echo -e "${CYAN}   📋 Criando templates inline...${NC}"
        create_templates_inline
    fi
}

create_templates_inline() {
    # ativar.md
    cat > .diary/ativar.md << 'EOF'
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
EOF

    # manifest.yaml
    cat > .diary/manifest.yaml << 'EOF'
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
EOF

    # engine/rules.md básico
    mkdir -p .diary/engine
    cat > .diary/engine/rules.md << 'EOF'
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
EOF

    # script de captura básico
    cat > .diary/scripts/capture.sh << 'EOF'
#!/bin/bash
# DiaryMCP Capture Script

if [ $# -eq 0 ]; then
    echo "Usage: $0 \"your session note\""
    echo "Example: $0 \"Implemented JWT authentication\""
    exit 1
fi

NOTE="$1"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
ENTRY_ID=$(date -u +"%Y-%m-%dT%H-%M-%S")

echo "📝 Capturing session with note: $NOTE"
echo "🕒 Timestamp: $TIMESTAMP"

# Aqui seria o local para chamar a IA ou processar contexto
# Por enquanto, apenas cria uma entrada básica

mkdir -p ".diary/data/entries/$(date -u +%Y-%m-%d)/$ENTRY_ID"

cat > ".diary/data/entries/$(date -u +%Y-%m-%d)/$ENTRY_ID/entry.md" << ENTRY_EOF
# Session - $TIMESTAMP

## User Note
$NOTE

## Captured by Script
This entry was created by the capture script.
To process it fully, use: "Ative o DiaryMCP" and then "capture $NOTE"

ENTRY_EOF

echo "✅ Basic entry created. Use DiaryMCP with IA for full processing."
EOF
    chmod +x .diary/scripts/capture.sh 2>/dev/null || true
}

personalize_files() {
    local project_name="$1"
    local project_type="$2"
    local project_language="$3"
    local install_date=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    local git_branch=$(detect_git_info)
    
    echo -e "${CYAN}   ⚙️  Personalizando para: ${GREEN}$project_name${NC}"
    
    # Personalizar ativar.md
    if [ -f ".diary/ativar.md" ]; then
        sed -i.bak "s/\[PROJECT_NAME\]/$project_name/g" .diary/ativar.md
        sed -i.bak "s/\[PROJECT_TYPE\]/$project_type/g" .diary/ativar.md  
        sed -i.bak "s/\[INSTALL_DATE\]/$install_date/g" .diary/ativar.md
        sed -i.bak "s/\[PRIMARY_LANGUAGE\]/$project_language/g" .diary/ativar.md
        rm -f .diary/ativar.md.bak
    fi
    
    # Personalizar manifest.yaml
    if [ -f ".diary/manifest.yaml" ]; then
        sed -i.bak "s/\[PROJECT_NAME\]/$project_name/g" .diary/manifest.yaml
        sed -i.bak "s/\[PROJECT_TYPE\]/$project_type/g" .diary/manifest.yaml
        sed -i.bak "s/\[PRIMARY_LANGUAGE\]/$project_language/g" .diary/manifest.yaml
        sed -i.bak "s/\[INSTALL_DATE\]/$install_date/g" .diary/manifest.yaml
        rm -f .diary/manifest.yaml.bak
    fi
    
    # Criar index.json personalizado
    cat > .diary/data/index.json << INDEX_EOF
{
  "project": "$project_name",
  "installed_at": "$install_date",
  "version": "1.1",
  "project_type": "$project_type",
  "language": "$project_language",
  "git_branch": "$git_branch",
  "entries": [],
  "edges": [],
  "stats": {
    "total_entries": 0,
    "total_sessions": 0,
    "last_capture": null
  },
  "optimization": {
    "summary_system": "enabled",
    "token_limit_per_summary": 1000,
    "summary_retention_days": 30
  }
}
INDEX_EOF

    # Criar tags.json inicial
    cat > .diary/data/tags.json << TAGS_EOF
{
  "tags": {},
  "categories": {
    "feature": [],
    "bug": [],
    "refactor": [],
    "risk": [],
    "insight": []
  },
  "last_updated": "$install_date"
}
TAGS_EOF
}

setup_gitignore() {
    local gitignore_entries="
# DiaryMCP
.diary/io/
.diary/data/entries/
.diary/scripts/capture.sh.log
"
    
    if [ -f ".gitignore" ]; then
        if ! grep -q ".diary/io/" .gitignore; then
            echo -e "${CYAN}   📝 Adicionando entradas ao .gitignore...${NC}"
            echo "$gitignore_entries" >> .gitignore
        else
            echo -e "${CYAN}   ✅ .gitignore já configurado${NC}"
        fi
    else
        echo -e "${CYAN}   📝 Criando .gitignore...${NC}"
        echo "$gitignore_entries" > .gitignore
    fi
}

validate_installation() {
    local errors=0
    
    echo -e "${CYAN}   🔍 Verificando arquivos essenciais...${NC}"
    
    for file in ".diary/ativar.md" ".diary/manifest.yaml" ".diary/data/index.json" ".diary/data/tags.json"; do
        if [ -f "$file" ]; then
            echo -e "   ${GREEN}✅ $file${NC}"
        else
            echo -e "   ${RED}❌ $file${NC}"
            errors=$((errors + 1))
        fi
    done
    
    for dir in ".diary/data/entries" ".diary/engine" ".diary/scripts"; do
        if [ -d "$dir" ]; then
            echo -e "   ${GREEN}✅ $dir/${NC}"
        else
            echo -e "   ${RED}❌ $dir/${NC}" 
            errors=$((errors + 1))
        fi
    done
    
    if [ $errors -gt 0 ]; then
        echo -e "${RED}❌ Instalação incompleta ($errors erros)${NC}"
        exit 1
    fi
}

show_next_steps() {
    echo
    echo -e "${GREEN}🎯 PRÓXIMOS PASSOS:${NC}"
    echo -e "   ${YELLOW}1.${NC} Teste a instalação: ${BLUE}\"Ative o DiaryMCP\"${NC}"
    echo -e "   ${YELLOW}2.${NC} Primeira captura:   ${BLUE}\"capture Primeira sessão de teste\"${NC}"
    echo -e "   ${YELLOW}3.${NC} Ver status:         ${BLUE}\"status\"${NC}"
    echo
    echo -e "${PURPLE}📊 ECONOMIA DE TOKENS:${NC}"
    echo -e "   ${GREEN}• Esta instalação: 0 tokens usados${NC}"
    echo -e "   ${GREEN}• Futuras sessões: 90%+ economia com resumos${NC}"
    echo
    echo -e "${CYAN}🗑️  LIMPEZA:${NC}"
    echo -e "   A pasta de instalação pode ser removida:"
    echo -e "   ${YELLOW}rm -rf $(dirname "$0")${NC} (se baixou temporariamente)"
    echo
    echo -e "${GREEN}✨ DiaryMCP v1.1 instalado e otimizado!${NC}"
}

# ============================================================================
# SCRIPT PRINCIPAL
# ============================================================================

# 1. Verificar se já existe .diary/
echo -e "${BLUE}🔍 Verificando instalação existente...${NC}"
if [ -d ".diary" ]; then
    echo -e "${YELLOW}⚠️  .diary/ já existe neste projeto.${NC}"
    echo -e "${YELLOW}   Sobrescrever instalação? (y/N)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${RED}❌ Instalação cancelada pelo usuário${NC}"
        exit 1
    fi
    echo -e "${YELLOW}🗑️  Removendo instalação anterior...${NC}"
    rm -rf .diary
fi

# 2. Detectar projeto
echo -e "${BLUE}🔍 Detectando projeto...${NC}"
PROJECT_NAME=$(detect_project_name)
PROJECT_TYPE=$(detect_project_type)
PROJECT_LANGUAGE=$(detect_language)
OS_INFO=$(get_os_info)

echo -e "   ${GREEN}📁 Nome: $PROJECT_NAME${NC}"
echo -e "   ${GREEN}🏷️  Tipo: $PROJECT_TYPE${NC}"  
echo -e "   ${GREEN}💻 Linguagem: $PROJECT_LANGUAGE${NC}"
echo -e "   ${GREEN}🖥️  Sistema: $OS_INFO${NC}"

# 3. Criar estrutura
echo -e "${BLUE}🏗️  Criando estrutura .diary/...${NC}"
create_directory_structure

# 4. Personalizar arquivos  
echo -e "${BLUE}⚙️  Personalizando configurações...${NC}"
personalize_files "$PROJECT_NAME" "$PROJECT_TYPE" "$PROJECT_LANGUAGE"

# 5. Configurar .gitignore
echo -e "${BLUE}📝 Configurando .gitignore...${NC}"
setup_gitignore

# 6. Validar instalação
echo -e "${BLUE}✅ Validando instalação...${NC}"
validate_installation

# 7. Sucesso!
echo
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      🎉 INSTALAÇÃO CONCLUÍDA!        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"

show_next_steps