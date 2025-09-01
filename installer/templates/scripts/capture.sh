#!/bin/bash

# DiaryMCP - Script de Captura Automática
# Gerado durante a instalação do DiaryMCP
# Versão: 1.0

# =============================================================================
# CONFIGURAÇÕES
# =============================================================================

DIARY_ROOT=".diary"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
TIMESTAMP=$(date +"%Y-%m-%dT%H-%M-%S")
ISO_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# FUNÇÕES AUXILIARES
# =============================================================================

log() {
    echo -e "${BLUE}[DiaryMCP]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Verificar se comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Criar diretório se não existir
ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
    fi
}

# =============================================================================
# CAPTURA DE CONTEXTO
# =============================================================================

capture_git_context() {
    local git_data="{}"
    
    if command_exists git && [ -d ".git" ]; then
        log "Capturando contexto Git..."
        
        local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        local status_output=$(git status --porcelain 2>/dev/null || echo "")
        
        # Arquivos modificados
        local modified=$(echo "$status_output" | grep "^ M" | cut -c4- | jq -R . | jq -s .)
        local added=$(echo "$status_output" | grep "^A " | cut -c4- | jq -R . | jq -s .)
        local deleted=$(echo "$status_output" | grep "^ D" | cut -c4- | jq -R . | jq -s .)
        local untracked=$(echo "$status_output" | grep "^??" | cut -c4- | jq -R . | jq -s .)
        
        # Commits recentes (últimas 24h)
        local commits_json="[]"
        if git log --oneline --since="24 hours ago" >/dev/null 2>&1; then
            commits_json=$(git log --since="24 hours ago" --pretty=format:'{"hash":"%H","short_hash":"%h","message":"%s","timestamp":"%cI","author":"%an"}' | jq -s .)
        fi
        
        # Stash list
        local stash_list=$(git stash list --pretty=format:'%gd: %gs' 2>/dev/null | jq -R . | jq -s .)
        
        git_data=$(jq -n \
            --arg branch "$branch" \
            --argjson modified "$modified" \
            --argjson added "$added" \
            --argjson deleted "$deleted" \
            --argjson untracked "$untracked" \
            --argjson commits "$commits_json" \
            --argjson stash "$stash_list" \
            '{
                available: true,
                branch: $branch,
                status: {
                    modified: $modified,
                    added: $added,
                    deleted: $deleted,
                    untracked: $untracked
                },
                commits_since_last: $commits,
                stash: $stash
            }')
        
        success "Contexto Git capturado (branch: $branch)"
    else
        warning "Git não disponível, usando fallback"
        git_data='{"available": false, "fallback": "filesystem_timestamps"}'
    fi
    
    echo "$git_data"
}

capture_file_context() {
    log "Capturando contexto de arquivos..."
    
    local recent_files="[]"
    local todos="[]"
    local fixmes="[]"
    
    # Arquivos modificados nas últimas 2 horas
    if command_exists find; then
        local file_list=$(find . -type f -mmin -120 \
            -not -path "./.git/*" \
            -not -path "./.diary/*" \
            -not -path "./node_modules/*" \
            -not -path "./.next/*" \
            -not -path "./dist/*" \
            -not -path "./build/*" \
            2>/dev/null | head -50)
        
        if [ ! -z "$file_list" ]; then
            recent_files=$(echo "$file_list" | while read file; do
                if [ -f "$file" ]; then
                    local size=$(stat -c%s "$file" 2>/dev/null || echo "0")
                    local mtime=$(stat -c%Y "$file" 2>/dev/null || echo "0")
                    local iso_mtime=$(date -d "@$mtime" -u +"%Y-%m-%dT%H:%M:%S.%3NZ" 2>/dev/null || echo "$ISO_TIMESTAMP")
                    
                    # Detectar tipo de arquivo
                    local file_type="other"
                    case "$file" in
                        *.js|*.ts|*.jsx|*.tsx|*.py|*.java|*.go|*.rs|*.cpp|*.c|*.cs) file_type="source" ;;
                        *.test.*|*.spec.*|*test*|*spec*) file_type="test" ;;
                        *.json|*.yaml|*.yml|*.toml|*.ini|*.conf) file_type="config" ;;
                        *.md|*.txt|*.rst|*.adoc) file_type="doc" ;;
                    esac
                    
                    jq -n \
                        --arg path "${file#./}" \
                        --arg modified_at "$iso_mtime" \
                        --argjson size "$size" \
                        --arg type "$file_type" \
                        '{
                            path: $path,
                            modified_at: $modified_at,
                            size: $size,
                            type: $type
                        }'
                fi
            done | jq -s .)
        fi
    fi
    
    # Buscar TODOs e FIXMEs
    if command_exists grep; then
        # TODOs
        local todo_matches=$(grep -r -n "TODO\|@todo" . \
            --exclude-dir=.git \
            --exclude-dir=.diary \
            --exclude-dir=node_modules \
            --exclude-dir=.next \
            --exclude-dir=dist \
            --exclude-dir=build \
            2>/dev/null | head -20 || echo "")
        
        if [ ! -z "$todo_matches" ]; then
            todos=$(echo "$todo_matches" | while read line; do
                local file=$(echo "$line" | cut -d: -f1 | sed 's|^\./||')
                local line_num=$(echo "$line" | cut -d: -f2)
                local text=$(echo "$line" | cut -d: -f3- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
                
                # Detectar prioridade
                local priority="medium"
                case "$text" in
                    *URGENT*|*CRITICAL*|*ASAP*) priority="urgent" ;;
                    *IMPORTANT*|*HIGH*) priority="high" ;;
                    *MINOR*|*LOW*) priority="low" ;;
                esac
                
                jq -n \
                    --arg file "$file" \
                    --argjson line "$line_num" \
                    --arg text "$text" \
                    --arg priority "$priority" \
                    '{
                        file: $file,
                        line: $line,
                        text: $text,
                        priority: $priority
                    }'
            done | jq -s .)
        fi
        
        # FIXMEs
        local fixme_matches=$(grep -r -n "FIXME\|@fixme\|XXX\|HACK" . \
            --exclude-dir=.git \
            --exclude-dir=.diary \
            --exclude-dir=node_modules \
            --exclude-dir=.next \
            --exclude-dir=dist \
            --exclude-dir=build \
            2>/dev/null | head -20 || echo "")
        
        if [ ! -z "$fixme_matches" ]; then
            fixmes=$(echo "$fixme_matches" | while read line; do
                local file=$(echo "$line" | cut -d: -f1 | sed 's|^\./||')
                local line_num=$(echo "$line" | cut -d: -f2)
                local text=$(echo "$line" | cut -d: -f3- | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
                
                # Detectar severidade
                local severity="medium"
                case "$text" in
                    *CRITICAL*|*URGENT*|*DANGER*) severity="critical" ;;
                    *IMPORTANT*|*HIGH*) severity="high" ;;
                    *MINOR*|*LOW*) severity="low" ;;
                esac
                
                jq -n \
                    --arg file "$file" \
                    --argjson line "$line_num" \
                    --arg text "$text" \
                    --arg severity "$severity" \
                    '{
                        file: $file,
                        line: $line,
                        text: $text,
                        severity: $severity
                    }'
            done | jq -s .)
        fi
    fi
    
    local file_context=$(jq -n \
        --argjson recent_modifications "$recent_files" \
        --argjson todos_found "$todos" \
        --argjson fixmes_found "$fixmes" \
        '{
            recent_modifications: $recent_modifications,
            todos_found: $todos_found,
            fixmes_found: $fixmes_found
        }')
    
    success "Contexto de arquivos capturado ($(echo "$recent_files" | jq length) arquivos recentes)"
    echo "$file_context"
}

capture_environment_context() {
    log "Capturando contexto do ambiente..."
    
    local working_dir=$(pwd)
    local project_root="$PROJECT_ROOT"
    local os=$(uname -s 2>/dev/null || echo "unknown")
    local shell=$(basename "$SHELL" 2>/dev/null || echo "unknown")
    local editor="unknown"
    
    # Tentar detectar editor
    if [ ! -z "$EDITOR" ]; then
        editor=$(basename "$EDITOR")
    elif command_exists code; then
        editor="vscode"
    elif command_exists vim; then
        editor="vim"
    elif command_exists nano; then
        editor="nano"
    fi
    
    local env_context=$(jq -n \
        --arg working_directory "$working_dir" \
        --arg project_root "$project_root" \
        --arg os "$os" \
        --arg shell "$shell" \
        --arg editor "$editor" \
        '{
            working_directory: $working_directory,
            project_root: $project_root,
            os: $os,
            shell: $shell,
            editor: $editor
        }')
    
    success "Contexto do ambiente capturado"
    echo "$env_context"
}

capture_temporal_context() {
    local now=$(date +"%H")
    local time_of_day="morning"
    
    if [ "$now" -ge 12 ] && [ "$now" -lt 18 ]; then
        time_of_day="afternoon"
    elif [ "$now" -ge 18 ] && [ "$now" -lt 22 ]; then
        time_of_day="evening"
    elif [ "$now" -ge 22 ] || [ "$now" -lt 6 ]; then
        time_of_day="night"
    fi
    
    local day_of_week=$(date +"%A" | tr '[:upper:]' '[:lower:]')
    
    # Estimar início da sessão (baseado em modificações recentes)
    local session_start="$ISO_TIMESTAMP"
    if command_exists find; then
        local oldest_recent=$(find . -type f -mmin -120 -not -path "./.git/*" -not -path "./.diary/*" -printf "%T@\n" 2>/dev/null | sort -n | head -1)
        if [ ! -z "$oldest_recent" ]; then
            session_start=$(date -d "@$oldest_recent" -u +"%Y-%m-%dT%H:%M:%S.%3NZ" 2>/dev/null || echo "$ISO_TIMESTAMP")
        fi
    fi
    
    local temporal_context=$(jq -n \
        --arg session_start "$session_start" \
        --arg time_of_day "$time_of_day" \
        --arg day_of_week "$day_of_week" \
        '{
            session_start: $session_start,
            time_of_day: $time_of_day,
            day_of_week: $day_of_week
        }')
    
    success "Contexto temporal capturado"
    echo "$temporal_context"
}

# =============================================================================
# FUNÇÃO PRINCIPAL
# =============================================================================

main() {
    local user_note="$*"
    
    log "Iniciando captura DiaryMCP..."
    log "Timestamp: $TIMESTAMP"
    
    # Verificar se estamos na raiz do projeto
    if [ ! -d "$DIARY_ROOT" ]; then
        error "Diretório .diary não encontrado!"
        error "Execute este script na raiz do projeto ou instale o DiaryMCP primeiro."
        exit 1
    fi
    
    # Criar estrutura de diretórios
    local entry_dir="$DIARY_ROOT/data/entries/$(date +"%Y-%m-%d")/$TIMESTAMP"
    ensure_dir "$entry_dir"
    ensure_dir "$DIARY_ROOT/io"
    
    # Capturar contextos
    log "Coletando contexto..."
    
    local git_context=$(capture_git_context)
    local file_context=$(capture_file_context)
    local env_context=$(capture_environment_context)
    local temporal_context=$(capture_temporal_context)
    
    # Montar contexto completo
    local full_context=$(jq -n \
        --argjson git "$git_context" \
        --argjson files "$file_context" \
        --argjson environment "$env_context" \
        --argjson temporal "$temporal_context" \
        '{
            git: $git,
            files: $files,
            environment: $environment,
            temporal: $temporal
        }')
    
    # Criar entrada base
    local entry_data=$(jq -n \
        --arg id "$TIMESTAMP" \
        --arg timestamp "$ISO_TIMESTAMP" \
        --argjson context "$full_context" \
        --arg user_note "$user_note" \
        --arg summary "Sessão capturada automaticamente" \
        '{
            id: $id,
            timestamp: $timestamp,
            context: $context,
            user_note: $user_note,
            summary: $summary,
            tags: [],
            files: [],
            metrics: {},
            connections: []
        }')
    
    # Salvar arquivos
    echo "$entry_data" > "$entry_dir/context.json"
    echo "$full_context" | jq . > "$entry_dir/raw_context.json"
    
    # Criar entrada em markdown
    cat > "$entry_dir/entry.md" << EOF
# Sessão de Desenvolvimento - $(date +"%d/%m/%Y %H:%M")

## Contexto Fornecido
$user_note

## Resumo Automático
Sessão capturada em $(date +"%d/%m/%Y às %H:%M:%S")

### Arquivos Modificados
$(echo "$file_context" | jq -r '.recent_modifications[] | "- \(.path) (\(.type))"' 2>/dev/null || echo "Nenhum arquivo recente detectado")

### Estado Git
$(if echo "$git_context" | jq -e '.available' >/dev/null 2>&1; then
    echo "- Branch: $(echo "$git_context" | jq -r '.branch')"
    echo "- Arquivos modificados: $(echo "$git_context" | jq -r '.status.modified | length')"
    echo "- Commits recentes: $(echo "$git_context" | jq -r '.commits_since_last | length')"
else
    echo "- Git não disponível (usando fallback)"
fi)

### TODOs Encontrados
$(echo "$file_context" | jq -r '.todos_found[] | "- \(.file):\(.line) - \(.text)"' 2>/dev/null | head -5 || echo "Nenhum TODO encontrado")

---

*Captura automática realizada pelo DiaryMCP*
*Para processar esta entrada, use: "Ative o DiaryMCP"*
EOF
    
    # Adicionar ao inbox para processamento pela IA
    local command=$(jq -n \
        --arg id "capture-$TIMESTAMP" \
        --arg type "capture" \
        --arg timestamp "$ISO_TIMESTAMP" \
        --arg entry_id "$TIMESTAMP" \
        --arg user_note "$user_note" \
        '{
            id: $id,
            type: $type,
            timestamp: $timestamp,
            payload: {
                entry_id: $entry_id,
                user_note: $user_note,
                auto_captured: true
            }
        }')
    
    echo "$command" >> "$DIARY_ROOT/io/inbox.ndjson"
    
    # Atualizar estado
    local state=$(jq -n \
        --arg current_session "$TIMESTAMP" \
        --arg last_capture "$ISO_TIMESTAMP" \
        --arg system_health "healthy" \
        --arg last_updated "$ISO_TIMESTAMP" \
        '{
            current_session: $current_session,
            last_capture: $last_capture,
            system_health: $system_health,
            last_updated: $last_updated
        }')
    
    echo "$state" > "$DIARY_ROOT/io/state.json"
    
    success "Captura realizada com sucesso!"
    success "Entrada salva em: $entry_dir"
    
    log "Para processar com IA, execute: 'Ative o DiaryMCP'"
    
    if [ ! -z "$user_note" ]; then
        log "Nota capturada: \"$user_note\""
    fi
    
    # Mostrar estatísticas rápidas
    local total_entries=$(find "$DIARY_ROOT/data/entries" -name "context.json" 2>/dev/null | wc -l)
    log "Total de entradas no diário: $total_entries"
}

# =============================================================================
# EXECUÇÃO
# =============================================================================

# Verificar dependências essenciais
if ! command_exists jq; then
    error "jq não está instalado!"
    error "No Ubuntu/Debian: sudo apt install jq"
    error "No macOS: brew install jq"
    exit 1
fi

# Executar função principal
main "$@"
