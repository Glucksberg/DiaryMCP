# DiaryMCP - Regras de Negócio
## Motor de Execução do Sistema

---

## 🎯 OBJETIVO PRINCIPAL

Capturar o contexto completo de sessões de programação e gerar narrativas técnicas e pessoais que facilitam a retomada do trabalho e o aprendizado contínuo.

## 📋 REGRAS DE CAPTURA

### 1. Contexto Git (Prioridade Alta)
```yaml
git_context:
  required:
    - current_branch
    - status_working_directory
    - commits_since_last_capture
    - modified_files_list
  
  optional:
    - diff_summary (se < 500 linhas)
    - stash_list
    - remote_status
    
  fallback:
    - usar filesystem timestamps se git não disponível
    - informar limitações ao usuário
```

### 2. Arquivos Recentes (Prioridade Alta)
```yaml
file_tracking:
  timeframe: "2 horas"
  
  include:
    - arquivos modificados
    - arquivos criados
    - arquivos deletados
    
  metadata:
    - timestamp modificação
    - tamanho do arquivo
    - tipo/extensão
    - caminho relativo
    
  scan_content:
    - TODOs encontrados
    - FIXMEs encontrados  
    - Comentários recentes
    - Imports/dependencies novos
```

### 3. Contexto Temporal (Prioridade Média)
```yaml
temporal_context:
  session_start: "detectar automaticamente ou usar timestamp comando"
  session_duration: "calcular baseado em modificações de arquivo"
  productivity_indicators:
    - número de commits
    - número de arquivos tocados
    - tipos de mudanças (feature/bug/refactor)
```

### 4. Estado Mental (Prioridade Baixa)
```yaml
mental_context:
  user_provided:
    - nota livre do usuário
    - contexto emocional
    - bloqueios enfrentados
    - insights obtidos
    
  auto_detected:
    - padrões de commit messages
    - frequência de mudanças
    - tipos de erros/fixes
```

## 🔄 REGRAS DE PROCESSAMENTO

### 1. Análise de Contexto
```markdown
Para cada captura:

1. **Coletar dados brutos**:
   - Git status, file modifications, timestamps
   - User notes, context clues
   
2. **Processar e enriquecer**:
   - Detectar padrões (feature/bug/refactor)
   - Identificar arquivos principais vs auxiliares  
   - Calcular métricas de produtividade
   
3. **Conectar com histórico**:
   - Encontrar sessões relacionadas
   - Identificar threads de pensamento
   - Mapear evolução de features/bugs
```

### 2. Geração de Narrativas

#### Resumo Técnico (tech.md)
```markdown
Estrutura obrigatória:

## Decisões Arquiteturais
- [Lista de decisões técnicas tomadas]

## Trade-offs Considerados  
- [Análise de prós/contras das escolhas]

## Riscos Identificados
- [Pontos de atenção para o futuro]

## Checklist de Retomada
- [ ] [Máximo 7 itens práticos]
- [ ] [Ações específicas e testáveis]

## Próximos Passos
- [Sequência lógica de ações]

## Referências
- [Links, docs, tickets relacionados]
```

#### Narrativa Pessoal (story.md)
```markdown
Estrutura sugerida:

## O que aconteceu
[História fluida da sessão]

## Estado mental
[Como estava se sentindo, motivações]

## Insights e descobertas  
[O que aprendeu, momentos "aha"]

## Como retomar
[Contexto mental para próxima sessão]

## Conexões
[Links com sessões/aprendizados anteriores]
```

### 3. Sistema de Tags Automáticas
```yaml
auto_tagging:
  commit_patterns:
    - "feat|feature" → tag:feature
    - "fix|bug" → tag:bug  
    - "refactor|cleanup" → tag:refactor
    - "test" → tag:testing
    - "docs" → tag:documentation
    
  file_patterns:
    - "*.test.*" → tag:testing
    - "README.md" → tag:documentation
    - "package.json" → tag:dependencies
    
  content_patterns:
    - "TODO" → tag:todo
    - "FIXME" → tag:fixme
    - "HACK" → tag:technical-debt
    - "XXX" → tag:warning
    
  user_patterns:
    - "risk:" → tag:risk
    - "insight:" → tag:insight  
    - "blocker:" → tag:blocker
    - "success:" → tag:success
```

## 🔗 REGRAS DE CONEXÃO

### 1. Links Temporais
```yaml
temporal_links:
  previous_session: "sempre criar link com entrada anterior"
  same_day: "agrupar sessões do mesmo dia"
  weekly_summary: "conectar com resumo semanal se existir"
```

### 2. Links por Branch/Feature
```yaml
branch_links:
  same_branch: "conectar todas as sessões do mesmo branch"
  feature_thread: "rastrear evolução de features específicas"  
  merge_points: "marcar quando branches são merged"
```

### 3. Links por Arquivos
```yaml
file_links:
  threshold: "30% de arquivos em comum"
  weight: "mais peso para arquivos principais vs auxiliares"
  recency: "sessões mais recentes têm prioridade"
```

### 4. Links Semânticos
```yaml
semantic_links:
  tag_overlap: "40% de tags em comum"
  keyword_matching: "palavras-chave nas narrativas"
  problem_solution: "conectar problemas com suas soluções"
```

## 📊 REGRAS DE ÍNDICES

### 1. Atualização do Grafo Principal
```json
// .diary/data/index.json
{
  "project": "nome-projeto",
  "entries": [
    {
      "id": "2024-01-15T14-30-00",
      "timestamp": "2024-01-15T14:30:00Z",
      "branch": "feature/auth",
      "files": ["src/auth.js", "test/auth.test.js"],
      "tags": ["feature", "auth", "testing"],
      "summary": "Implementação de autenticação JWT"
    }
  ],
  "edges": [
    {
      "from": "2024-01-15T14-30-00",
      "to": "2024-01-15T16-45-00", 
      "type": "temporal",
      "weight": 1.0
    }
  ]
}
```

### 2. Índice de Tags
```json
// .diary/data/tags.json
{
  "tags": {
    "feature": {
      "count": 15,
      "entries": ["2024-01-15T14-30-00", "..."],
      "related": ["implementation", "development"]
    }
  },
  "categories": {
    "feature": ["auth", "payments", "notifications"],
    "bug": ["cors", "validation", "performance"]
  }
}
```

## 🛡️ REGRAS DE VALIDAÇÃO

### 1. Validação de Entrada
```yaml
required_fields:
  - timestamp
  - context.git_status OR context.file_modifications
  - user_note OR auto_summary
  
optional_fields:
  - user_emotion
  - session_duration
  - productivity_metrics
  
validation_rules:
  - timestamp deve ser ISO-8601
  - paths devem ser relativos ao projeto
  - tags devem seguir padrão [a-z0-9-]
```

### 2. Integridade do Sistema
```yaml
health_checks:
  - todos os entries têm arquivos correspondentes
  - índices estão sincronizados com entries
  - não há links para entries inexistentes
  - estrutura de pastas está completa
  
auto_repair:
  - recriar índices corrompidos
  - remover links órfãos
  - restaurar arquivos de template faltantes
```

## ⚠️ REGRAS DE ERRO E FALLBACK

### 1. Git Não Disponível
```yaml
fallback_git:
  use: "filesystem timestamps"
  track: "file modifications only"
  inform: "limitações ao usuário"
  maintain: "funcionalidade básica"
```

### 2. Dados Corrompidos
```yaml
corruption_handling:
  detect: "validar JSON schemas"
  backup: "criar .corrupted backup"
  rebuild: "recriar a partir de entries válidas"
  preserve: "notas do usuário sempre"
```

### 3. Falhas de Performance
```yaml
performance_limits:
  max_files_scan: 1000
  max_diff_lines: 500
  max_entries_memory: 1000
  timeout_git_operations: 30
```

## 🎛️ REGRAS DE CONFIGURAÇÃO

### 1. Personalização por Projeto
```yaml
project_overrides:
  - manifest.yaml pode sobrescrever qualquer regra
  - custom_commands podem adicionar funcionalidades
  - privacy.exclude_patterns protege dados sensíveis
```

### 2. Modo Debug
```yaml
debug_mode:
  enabled: false
  verbose_logging: true
  preserve_temp_files: true
  detailed_timing: true
```

---

## 📝 RESUMO DE EXECUÇÃO

### Para cada comando "capture":
1. **Validar** estado do sistema
2. **Coletar** contexto (git + files + user)
3. **Processar** dados e detectar padrões  
4. **Gerar** narrativas (tech + story)
5. **Conectar** com entradas existentes
6. **Atualizar** índices e estado
7. **Confirmar** sucesso ao usuário

### Para outros comandos:
- **status**: ler índices e mostrar estatísticas
- **search**: buscar em narrativas e contextos
- **connect**: sugerir novas conexões
- **rebuild**: reprocessar todas as entradas

*Estas regras garantem consistência e qualidade na captura e organização do conhecimento do desenvolvedor.*
