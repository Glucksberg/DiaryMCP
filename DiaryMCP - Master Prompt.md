# DiaryMCP - Sistema de Diário Automático "Software Vivo"
## Prompt Mestre para Desenvolvimento

---

## 🎯 VISÃO GERAL DO PROJETO

Quero criar um **"Software Vivo"** - um sistema de diário automático para sessões de programação que existe puramente como arquivos em uma pasta, sem servidores ou dependências externas. O sistema é "ativado" quando uma IA lê seus arquivos e segue suas regras, tornando-se temporariamente o motor de execução do software.

### Conceito Central: Software Vivo
- **Não é um programa tradicional**: É uma coleção de arquivos com regras e protocolos
- **A IA é o runtime**: Qualquer IA moderna pode "executar" o software apenas lendo os arquivos
- **Portabilidade total**: Copie a pasta `DiaryMCP/` para qualquer projeto e funciona instantaneamente
- **Zero configuração**: Não precisa instalar nada, apenas ter acesso a uma IA

### ⚠️ FLUXO DE USO ESCLARECIDO

#### PRIMEIRA VEZ (Instalação):
1. Você tem os arquivos "base" do DiaryMCP em algum lugar (download, repo, etc)
2. Você pede para a IA: **"Instale o DiaryMCP neste projeto"**
3. A IA lê `DiaryMCP/instalar.md` dos arquivos base
4. A IA cria uma nova pasta `.diary/` no seu projeto com tudo configurado
5. A instalação personaliza os arquivos para seu projeto específico

#### USO DIÁRIO (Após instalado):
1. Você pede para a IA: **"Ative o DiaryMCP"** 
2. A IA lê `.diary/ativar.md` (que foi instalado no seu projeto)
3. A IA se torna o motor e executa as funções do diário

#### Estrutura Final:
```
seu-projeto/
├── src/
├── docs/
├── .diary/              # Pasta instalada do DiaryMCP
│   ├── ativar.md       # Arquivo para ativar (uso diário)
│   ├── manifest.yaml   # Configurações do seu projeto
│   └── ...            # Resto do sistema
└── DiaryMCP/           # (Opcional) Arquivos base, pode deletar após instalar
    ├── instalar.md     # Arquivo para instalação inicial
    └── ...            # Templates base
```

---

## 📋 REQUISITOS FUNCIONAIS

### 1. Captura Automática de Contexto
Ao finalizar uma sessão de coding, o sistema deve capturar automaticamente:
- Estado do git (branch, commits, diffs dos últimos arquivos modificados)
- Arquivos tocados nas últimas horas
- TODOs e FIXMEs detectados no código
- Notas temporárias deixadas pelo desenvolvedor
- Contexto do ambiente (diretório, projeto, horário)
- Estado mental/emocional (se fornecido via prompt rápido)
- Problemas não resolvidos e decisões tomadas

### 2. Geração de Narrativas Duplas
Para cada sessão, gerar duas versões complementares:

**Resumo Técnico (Dev Mode)**
- Decisões arquiteturais tomadas
- Trade-offs considerados
- Riscos identificados
- Checklist de retomada (máximo 7 itens)
- Próximos passos concretos
- Referências a documentação/tickets

**Narrativa Pessoal (Story Mode)**
- História fluida do que aconteceu
- Estado mental e motivações
- Insights e descobertas
- Como retomar o trabalho
- Conexões com sessões anteriores

### 3. Sistema de Interconexão
- **Grafo temporal**: Cada entrada se conecta com a anterior
- **Links por branch**: Sessões na mesma feature se conectam
- **Links por arquivos**: Sessões que tocaram arquivos similares
- **Tags semânticas**: `feature:`, `bug:`, `refactor:`, `risk:`, `insight:`
- **Threads de pensamento**: Ideias que evoluem entre sessões

### 4. Protocolo de Ativação
```
Usuário: "Ative o DiaryMCP. Leia o arquivo DiaryMCP/ativar.md"
IA: [Lê o arquivo e se torna o motor do software]
```

---

## 🏗️ ARQUITETURA DO SISTEMA

### Estrutura de Pastas

#### ARQUIVOS BASE (para distribuição):
```
DiaryMCP/
├── instalar.md              # PONTO DE ENTRADA PARA INSTALAÇÃO
├── templates/
│   ├── manifest.yaml       # Template do protocolo
│   ├── ativar.md          # Template de ativação  
│   ├── engine/
│   │   ├── rules.md       # Regras de negócio
│   │   ├── contracts.yaml # Schemas de dados
│   │   └── prompts/
│   │       ├── capture.md # Como capturar contexto
│   │       ├── analyze.md # Como analisar sessão
│   │       └── generate.md # Como gerar narrativas
│   └── scripts/
│       └── capture.sh     # Script de captura
└── docs/
    └── protocol.md        # Documentação do protocolo
```

#### APÓS INSTALAÇÃO (no projeto do usuário):
```
meu-projeto/
├── src/
├── package.json
└── .diary/                  # PASTA INSTALADA (oculta)
    ├── ativar.md           # PONTO DE ENTRADA PARA USO DIÁRIO
    ├── manifest.yaml       # Configurado para este projeto
    ├── engine/
    │   ├── rules.md
    │   ├── contracts.yaml
    │   └── prompts/
    ├── io/
    │   ├── inbox.ndjson   # Fila de comandos
    │   ├── outbox.ndjson  # Fila de respostas
    │   └── state.json     # Estado atual
    ├── data/
    │   ├── index.json     # Grafo de entradas
    │   ├── tags.json      # Índice de tags
    │   └── entries/       # Diário propriamente dito
    │       └── 2024-01-15/
    │           └── 14-30-00/
    │               ├── entry.md
    │               ├── context.json
    │               ├── tech.md
    │               └── story.md
    └── scripts/
        └── capture.sh     # Script configurado
```

### Arquivo de Instalação: `DiaryMCP/instalar.md`

```markdown
# 📦 INSTALAÇÃO DO DIARYMCP

Você foi solicitado a instalar o DiaryMCP neste projeto.

## PASSOS DE INSTALAÇÃO

1. **Criar pasta `.diary/` na raiz do projeto atual**
   - Use pasta oculta para não poluir o projeto
   - Se já existir, pergunte se deve sobrescrever

2. **Detectar informações do projeto**
   - Nome do projeto (baseado na pasta ou package.json/pom.xml/etc)
   - Tipo de projeto (detectar linguagem principal)
   - Tem git? Qual branch padrão?
   - Estrutura de pastas

3. **Copiar templates para `.diary/`**
   - Copie todos os arquivos de `DiaryMCP/templates/` para `.diary/`
   - Ajuste caminhos e configurações no `manifest.yaml`
   - Personalize `ativar.md` com o nome do projeto

4. **Criar estrutura de dados inicial**
   ```
   .diary/
   ├── io/           (criar vazio)
   ├── data/
   │   ├── index.json    {"project": "[NOME]", "entries": [], "edges": []}
   │   ├── tags.json     {"tags": {}}
   │   └── entries/      (criar vazio)
   ```

5. **Configurar .gitignore do projeto**
   Adicionar (se não existir):
   ```
   # DiaryMCP
   .diary/io/
   .diary/data/entries/
   .diary/scripts/capture.sh
   ```

6. **Criar script de captura**
   - Gerar `.diary/scripts/capture.sh` específico para o OS detectado
   - Tornar executável se possível

7. **Confirmar instalação**
   ```
   ✅ DiaryMCP instalado com sucesso em .diary/
   
   Para ativar: "Ative o DiaryMCP"
   Para capturar sessão: ".diary/scripts/capture.sh"
   
   Primeira captura recomendada para testar o sistema.
   ```

## SE FALHAR
- Informar exatamente o que falhou
- Não deixar arquivos pela metade
- Sugerir instalação manual
```

### Arquivo Principal de Uso: `.diary/ativar.md` (após instalação)

```markdown
# 🚀 ATIVAÇÃO DO DIARYMCP - [NOME DO PROJETO]

Você agora é o motor de execução do DiaryMCP para o projeto [NOME DO PROJETO].
Este arquivo foi personalizado durante a instalação.

## VERIFICAÇÃO RÁPIDA
- Projeto: [NOME DO PROJETO]
- Instalado em: [DATA]
- Total de entradas: [N]
- Última captura: [DATA/HORA]

## MODO DE OPERAÇÃO

1. **Checar estado**: Leia `.diary/io/state.json`
2. **Processar comandos**: Verifique `.diary/io/inbox.ndjson`
3. **Executar regras**: Siga `.diary/engine/rules.md`
4. **Persistir**: Grave em `.diary/data/entries/` e `.diary/io/outbox.ndjson`

## COMANDOS DISPONÍVEIS

### Captura Rápida
User: "Capture a sessão"
User: "Diary: [qualquer nota rápida]"
User: "Finalizando: [descrição]"

### Comandos Completos
- `capture [nota]` - Captura contexto atual com nota opcional
- `status` - Mostra estatísticas do diário
- `last` - Mostra última entrada
- `search [termo]` - Busca nas entradas
- `connect` - Sugere conexões entre entradas
- `report [período]` - Relatório do período

## CONTEXTO DO PROJETO
[Informações específicas detectadas durante instalação]
- Linguagem principal: [detectada]
- Branch padrão: [main/master/develop]
- Pastas importantes: [src/, tests/, etc]

## PRÓXIMA AÇÃO
Pergunte: "DiaryMCP ativo para [PROJETO]. O que deseja fazer?"
```

---

## 🔧 MELHORIAS SOBRE A VERSÃO ORIGINAL

### 1. Sistema de Self-Healing
- **Verificação de integridade**: O sistema detecta e corrige links quebrados
- **Reconstrução de índice**: Pode reconstruir o grafo a partir das entradas
- **Migração automática**: Atualiza estruturas antigas quando encontra nova versão

### 2. Memória Contextual Expandida
```yaml
context_layers:
  immediate: # Últimos 30 minutos
    - comandos_terminal
    - arquivos_salvos
    - tabs_abertas
  session: # Desde o início da sessão
    - branches_visitadas
    - testes_rodados
    - builds_executados
  historical: # Contexto de longo prazo
    - padrões_detectados
    - horários_produtivos
    - ferramentas_preferidas
```

### 3. Sistema de Plugins via Arquivos
```
DiaryMCP/plugins/
├── slack_mentions.md      # Detecta menções relevantes no Slack
├── calendar_context.md    # Conecta com eventos do calendário
└── music_mood.md         # Registra playlist/mood da sessão
```

### 4. Protocolo de Mensagens Aprimorado
```json
{
  "version": "1.0",
  "type": "capture.request",
  "id": "uuid-here",
  "timestamp": "ISO-8601",
  "payload": {
    "trigger": "manual|auto|schedule",
    "context": {},
    "options": {
      "depth": "shallow|normal|deep",
      "include_screenshots": false,
      "sentiment_analysis": true
    }
  },
  "metadata": {
    "agent": "vscode|terminal|web",
    "user_note": "optional quick note"
  }
}
```

### 5. Análise de Produtividade
- **Velocity tracking**: Compara produtividade entre sessões
- **Pattern detection**: Identifica quando você é mais produtivo
- **Blocker analysis**: Detecta o que frequentemente te trava
- **Success patterns**: Aprende o que leva a sessões bem-sucedidas

---

## 🎨 FEATURES AVANÇADAS

### 1. Modo Retrospectiva
```
"Mostre minha evolução trabalhando na feature X"
"Quanto tempo gastei com bugs vs features este mês?"
"Quais foram meus principais insights técnicos?"
```

### 2. Modo Mentor
```
"Baseado nas minhas sessões, onde posso melhorar?"
"Detecte anti-patterns no meu workflow"
"Sugira otimizações baseadas no meu histórico"
```

### 3. Modo Equipe (Futuro)
```
DiaryMCP/team/
├── shared_insights.md
├── knowledge_base.md
└── handoff_templates.md
```

---

## 💡 CORREÇÕES DE FALHAS LÓGICAS

### Problemas Identificados na Versão Original:

1. **Falta de tratamento de erro**: Adicionar modo degradado quando git não existe
2. **Sem versionamento de protocolo**: Adicionar migração entre versões
3. **Index pode crescer demais**: Implementar arquivamento automático
4. **Falta de privacidade**: Adicionar `.diaryprivate` para excluir arquivos/pastas
5. **Sem modo offline**: Permitir funcionamento sem IA via templates

### Soluções Implementadas:

```yaml
# manifest.yaml
fallback_modes:
  no_git:
    use: filesystem_timestamps
    track: file_modifications_only
  corrupted_data:
    action: quarantine_and_rebuild
    preserve: user_notes_always
```

---

## 🚀 COMANDO DE DESENVOLVIMENTO

### Para IAs Desenvolvedoras:

```markdown
TAREFA: Desenvolver o sistema DiaryMCP completo

IMPORTANTE - DOIS ARQUIVOS PRINCIPAIS:
1. DiaryMCP/instalar.md - Para instalação inicial (primeira vez)
2. .diary/ativar.md - Para uso diário (após instalado)

ENTREGÁVEIS:
1. Arquivo DiaryMCP/instalar.md com lógica de instalação
2. Todos os templates em DiaryMCP/templates/
3. Scripts de captura para Linux/Mac/Windows  
4. Exemplos de entries processadas
5. Documentação clara da diferença entre instalação e ativação

PRINCÍPIOS:
- Zero dependências externas (apenas git, shell básico)
- Funcionamento agnóstico de IA (qualquer LLM moderna)
- Degradação graciosa (funciona mesmo com falhas)
- Separação clara entre arquivos base e arquivos instalados
- A pasta .diary/ é sagrada - tudo do usuário fica lá

FLUXO CORRETO:
Instalação (uma vez):
  User: "Instale o DiaryMCP"
  IA: Lê DiaryMCP/instalar.md → Cria .diary/ → Personaliza arquivos

Uso (diariamente):
  User: "Ative o DiaryMCP"  
  IA: Lê .diary/ativar.md → Executa funções do diário

QUALIDADE:
- Cada arquivo deve ser autoexplicativo
- Usar exemplos concretos em toda documentação
- Incluir tratamento de erros em todos os pontos
- Deixar claro qual arquivo usar quando

INÍCIO:
Comece criando DiaryMCP/instalar.md com a lógica completa de 
instalação. Depois crie DiaryMCP/templates/ativar.md que será
copiado para .diary/ativar.md durante a instalação.

VALIDAÇÃO:
O sistema está pronto quando:
1. "Instale o DiaryMCP" cria corretamente .diary/ no projeto
2. "Ative o DiaryMCP" funciona após instalação
3. Os arquivos base podem ser deletados após instalar
4. O comando de captura gera entradas válidas
5. Usuário nunca precisa editar arquivos manualmente
```

---

## 📝 EXEMPLO DE USO FINAL

### Instalação (primeira vez):
```bash
# Usuario baixa ou clona os arquivos base do DiaryMCP
$ git clone github.com/user/DiaryMCP

# Com a IA:
User: "Instale o DiaryMCP neste projeto"
IA: "Lendo DiaryMCP/instalar.md... 
    Detectando projeto: 'CloudFarmAPI'
    Criando .diary/...
    Configurando para seu ambiente...
    ✅ DiaryMCP instalado! Use 'Ative o DiaryMCP' para começar"

# Pode deletar os arquivos base agora
$ rm -rf DiaryMCP/
```

### Uso diário (após instalado):
```bash
# No terminal, ao final da sessão:
$ ./.diary/scripts/capture.sh "Implementei o sistema de autenticação"

# Ou direto com a IA:
User: "Ative o DiaryMCP"
IA: "DiaryMCP ativo para CloudFarmAPI. O que deseja?"

User: "Capture a sessão. Contexto: lutei com CORS por 2 horas mas resolvi"

# IA responde:
"Capturando sessão...
✓ Git: 12 commits em feature/auth
✓ Arquivos: 8 modificados (maioria em api/auth/)
✓ Tempo: 3h 45min
✓ TODOs novos: 2 detectados

Narrativa gerada:
[Tech] Implementação de auth com JWT. Bloqueio principal foi CORS 
em requisições preflight. Solução: middleware customizado.
Próximos passos: 
- [ ] Adicionar refresh tokens
- [ ] Implementar rate limiting

[Story] Mais uma batalha vencida contra CORS. Depois de 2 horas 
debugando headers, descobri que o problema era a ordem dos 
middlewares. Clássico. Próxima sessão: fazer os testes E2E 
antes que eu esqueça os edge cases.

Entrada salva: .diary/data/entries/2024-01-15/14-30-00/
Conectada com: 3 sessões anteriores em feature/auth"
```

### Comandos rápidos após ativação:
```
User: "Status"
IA: "23 entradas este mês, 5 esta semana. Última: há 2 horas"

User: "Última entrada"
IA: [Mostra resumo da última sessão]

User: "Busque CORS"
IA: "3 entradas mencionam CORS: [lista com datas e contextos]"
```

---

## 🎁 BENEFÍCIOS ÚNICOS DESTA ARQUITETURA

1. **Versionamento natural**: Cada pasta é um snapshot, use git para versionar
2. **Busca poderosa**: grep/ripgrep funcionam nativamente
3. **Integração fácil**: Qualquer IDE pode ler/mostrar os arquivos
4. **Backup simples**: É só copiar a pasta
5. **Privacidade total**: Seus dados nunca saem da máquina
6. **Evolução orgânica**: Adicione arquivos para novas features
7. **Debug transparente**: Todos os dados são legíveis
8. **IA-agnóstico**: Funciona com GPT, Claude, Gemini, ou qualquer LLM futura

---

## ⚡ INÍCIO RÁPIDO PARA DESENVOLVIMENTO

```markdown
Você é uma IA desenvolvedora. Sua missão é criar o DiaryMCP completo.

ESTRUTURA DE ARQUIVOS A CRIAR:

1. DiaryMCP/instalar.md 
   - Instruções para IA instalar o sistema no projeto
   - Deve criar pasta .diary/ com tudo configurado
   
2. DiaryMCP/templates/ativar.md
   - Template que será copiado para .diary/ativar.md
   - Instruções para ativar o sistema após instalado
   
3. DiaryMCP/templates/manifest.yaml
   - Protocolo e configurações base
   
4. DiaryMCP/templates/engine/rules.md
   - Regras de captura e geração de narrativas
   
5. DiaryMCP/templates/scripts/capture.sh
   - Script para capturar contexto

LEMBRE-SE:
- instalar.md é usado UMA vez para instalar
- ativar.md é usado TODA vez para ativar o diário
- Arquivos base ficam em DiaryMCP/
- Arquivos do usuário ficam em .diary/
- Usuário pode deletar DiaryMCP/ após instalar

O sistema deve funcionar imediatamente após instalação.
A mágica está na simplicidade e clareza dos arquivos.
```

---

## 🔑 RESUMO DA ARQUITETURA FINAL

### Dois momentos, dois arquivos:

1. **INSTALAÇÃO** (uma única vez):
   - Comando: `"Instale o DiaryMCP"`
   - IA lê: `DiaryMCP/instalar.md`
   - Ação: Cria `.diary/` personalizada no projeto
   - Resultado: Sistema instalado e configurado

2. **ATIVAÇÃO** (uso diário):
   - Comando: `"Ative o DiaryMCP"`
   - IA lê: `.diary/ativar.md` 
   - Ação: IA vira o motor do diário
   - Resultado: Pode capturar sessões, gerar relatórios, etc

### Por que essa separação?
- **Instalação** personaliza para cada projeto (nome, estrutura, git)
- **Ativação** é rápida e direta, já sabe tudo do projeto
- Arquivos base podem ser deletados após instalar
- Cada projeto tem seu `.diary/` independente

---

*Este documento é o prompt mestre definitivo para criar o DiaryMCP. Use-o com qualquer IA para desenvolver o sistema completo.*