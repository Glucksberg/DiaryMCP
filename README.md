# DiaryMCP - Sistema de Diário Automático "Software Vivo"

> Um sistema de diário inteligente para desenvolvedores que existe puramente como arquivos e é executado por qualquer IA moderna.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0-blue.svg)](https://github.com/Glucksberg/DiaryMCP)

## 🎯 O que é o DiaryMCP?

O DiaryMCP é um **"Software Vivo"** - um sistema de diário automático que:

- 📁 **Existe como arquivos**: Não é um programa tradicional, mas uma coleção de arquivos com regras e protocolos
- 🤖 **É executado por IA**: Qualquer IA moderna (GPT, Claude, Gemini) pode "executar" o software lendo os arquivos
- 🚀 **Zero configuração**: Copie a pasta para qualquer projeto e funciona instantaneamente
- 🔒 **Totalmente privado**: Seus dados nunca saem da sua máquina
- 🔄 **Auto-organizador**: Cria narrativas técnicas e pessoais, conecta sessões e detecta padrões

## ⚡ Início Rápido

### 1. Instalação (Uma vez por projeto)
```bash
# Clone os arquivos base do DiaryMCP
git clone https://github.com/Glucksberg/DiaryMCP.git

# No seu projeto, com uma IA:
"Instale o DiaryMCP neste projeto"
```

### 2. Uso Diário (Após instalado)
```bash
# Capturar sessão automaticamente
./.diary/scripts/capture.sh "Implementei autenticação JWT"

# Ou usar com IA:
"Ative o DiaryMCP"
"Capture a sessão: lutei com CORS por 2 horas mas resolvi"
```

### 3. Resultado
```
✅ Sessão processada com sucesso!

📊 Resumo:
- Tipo: feature (auth)
- Produtividade: 85/100
- Arquivos: 8 modificados
- Conexões: 3 detectadas

🎯 Próximos passos:
- [ ] Implementar refresh tokens
- [ ] Adicionar rate limiting
```

## 🏗️ Como Funciona

### Conceito: Software Vivo
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Arquivos      │    │       IA        │    │   Execução      │
│   + Regras      │ -> │   lê e segue    │ -> │   Software      │
│   + Protocolos  │    │   instruções    │    │   "Vivo"        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Dois Momentos Principais

#### 🔧 **Instalação** (uma vez por projeto)
- Comando: `"Instale o DiaryMCP"`
- IA lê: `DiaryMCP/instalar.md`
- Ação: Cria pasta `.diary/` personalizada no seu projeto
- Resultado: Sistema instalado e configurado

#### 🚀 **Ativação** (uso diário)
- Comando: `"Ative o DiaryMCP"`  
- IA lê: `.diary/ativar.md`
- Ação: IA se torna o motor do diário
- Resultado: Pode capturar sessões, gerar relatórios, etc.

## 📂 Estrutura do Projeto

### Arquivos Base (para distribuição)
```
DiaryMCP/
├── instalar.md                 # 🚪 PONTO DE ENTRADA para instalação
├── templates/
│   ├── ativar.md              # Template de ativação
│   ├── manifest.yaml          # Configurações do sistema
│   ├── engine/
│   │   ├── rules.md           # Regras de negócio
│   │   ├── contracts.yaml     # Schemas de dados
│   │   └── prompts/           # Prompts especializados
│   └── scripts/
│       └── capture.sh         # Script de captura
└── docs/
    └── protocol.md            # Documentação técnica
```

### Após Instalação (no seu projeto)
```
seu-projeto/
├── src/
├── package.json
└── .diary/                     # 📁 PASTA INSTALADA (oculta)
    ├── ativar.md              # 🚪 PONTO DE ENTRADA para uso diário
    ├── manifest.yaml          # Configurado para seu projeto
    ├── engine/                # Motor de execução
    ├── data/                  # Seus dados do diário
    │   ├── entries/           # Entradas organizadas por data
    │   ├── index.json         # Grafo de conexões
    │   └── tags.json          # Índice de tags
    └── scripts/
        └── capture.sh         # Script personalizado
```

## 🎨 Características Únicas

### 📖 Narrativas Duplas
Cada sessão gera duas versões complementares:

**📋 Resumo Técnico**
- Decisões arquiteturais
- Trade-offs considerados
- Riscos identificados
- Checklist de retomada
- Próximos passos concretos

**📚 Narrativa Pessoal**
- História fluida da sessão
- Estado mental e motivações
- Insights e descobertas
- Como retomar o trabalho
- Conexões com sessões anteriores

### 🕸️ Sistema de Conexões
- **Temporal**: Sessões sequenciais
- **Branch**: Mesmo feature/branch
- **Arquivos**: Arquivos em comum
- **Semântica**: Tags e tópicos similares
- **Threads**: Evolução de ideias

### 🏷️ Tags Inteligentes
```yaml
# Auto-detecta padrões em:
commit_messages: "feat:" → tag:feature
file_patterns: "*.test.*" → tag:testing
content_scan: "TODO" → tag:todo
user_notes: "insight:" → tag:insight
```

## 🚀 Comandos Disponíveis

### Captura
```bash
# Via script
./.diary/scripts/capture.sh "Nota da sessão"

# Via IA
"Capture a sessão"
"Diary: implementei cache Redis"
"Finalizando: bug do login resolvido"
```

### Análise
```bash
# Via IA após ativar
"status"                    # Estatísticas gerais
"last"                      # Última entrada
"search CORS"               # Buscar termo
"report semana"             # Relatório semanal
"connect"                   # Análise de conexões
```

## 🔧 Requisitos

### Essenciais
- **jq** (para processamento JSON)
- **git** (recomendado, mas funciona sem)
- **IA moderna** (GPT-4, Claude, Gemini, etc.)

### Instalação de Dependências
```bash
# Ubuntu/Debian
sudo apt install jq git

# macOS
brew install jq git

# Windows (via Chocolatey)
choco install jq git
```

## 📊 Exemplo de Uso Completo

### 1. Instalação Inicial
```bash
# Baixar arquivos base
git clone https://github.com/Glucksberg/DiaryMCP.git
cd meu-projeto

# Com IA (Claude, GPT, etc.)
User: "Instale o DiaryMCP neste projeto"
IA: "Detectando projeto 'MinhaAPI'...
     Criando .diary/...
     ✅ DiaryMCP instalado! Use 'Ative o DiaryMCP' para começar"
```

### 2. Primeira Captura
```bash
# Via script
./.diary/scripts/capture.sh "Primeira sessão - configurando projeto"

# Ou via IA
User: "Ative o DiaryMCP"
IA: "DiaryMCP ativo para MinhaAPI. O que deseja?"

User: "Capture a sessão. Contexto: configurei Docker e banco de dados"
IA: "Capturando... ✅ Sessão salva com 12 arquivos modificados"
```

### 3. Uso Contínuo
```bash
# Após algumas semanas...
User: "Ative o DiaryMCP"
User: "status"

IA: "📊 MinhaAPI Status:
     - 23 entradas este mês
     - Produtividade média: 78/100
     - 3 threads ativos (auth, cache, deploy)
     - Última captura: 2 horas atrás"

User: "report semana"
IA: "📅 Relatório Semanal:
     - 8 sessões, 45h estimadas
     - Foco: 60% features, 30% bugs, 10% docs
     - Insight da semana: Redis cache reduziu latência em 70%"
```

## 🎯 Benefícios

### Para o Desenvolvedor
- 🧠 **Memória externa**: Nunca esqueça contexto de projetos
- 🔄 **Retomada rápida**: Saiba exatamente onde parou
- 📈 **Melhoria contínua**: Veja padrões e otimize workflow
- 🎓 **Aprendizado acelerado**: Insights são capturados e conectados

### Para a Equipe
- 📋 **Handoffs eficientes**: Contexto completo para outros devs
- 🔍 **Debug colaborativo**: Histórico de decisões e problemas
- 📚 **Base de conhecimento**: Soluções ficam documentadas
- 🎯 **Onboarding rápido**: Novos membros entendem evolução

### Para o Projeto
- 📊 **Métricas reais**: Produtividade e padrões baseados em dados
- 🏗️ **Decisões documentadas**: Rastro de escolhas arquiteturais
- ⚠️ **Riscos mapeados**: Problemas identificados ficam registrados
- 🔄 **Evolução rastreada**: História completa do desenvolvimento

## 🤝 Compatibilidade

### IAs Testadas
- ✅ **GPT-4/GPT-4 Turbo** (OpenAI)
- ✅ **Claude 3 Opus/Sonnet** (Anthropic)
- ✅ **Gemini Pro** (Google)
- ✅ **Cursor AI** (integração nativa)

### Sistemas Operacionais
- ✅ **Linux** (Ubuntu, CentOS, etc.)
- ✅ **macOS**
- ✅ **Windows** (via WSL recomendado)

### Linguagens de Projeto
- ✅ **JavaScript/TypeScript** (Node.js, React, etc.)
- ✅ **Python** (Django, Flask, etc.)
- ✅ **Java** (Spring, Maven, etc.)
- ✅ **Go** (módulos Go)
- ✅ **Rust** (Cargo)
- ✅ **Qualquer linguagem** (modo genérico)

## 📚 Documentação Adicional

- [📖 Protocolo Técnico](docs/protocol.md) - Detalhes de implementação
- [🔧 Guia de Instalação](docs/installation.md) - Instalação detalhada
- [🎨 Personalização](docs/customization.md) - Como adaptar o sistema
- [🔍 Troubleshooting](docs/troubleshooting.md) - Soluções para problemas
- [🤝 Contribuindo](CONTRIBUTING.md) - Como contribuir

## 🚀 Roadmap

### v1.1 (Próxima)
- [ ] Templates de exportação (HTML, PDF)
- [ ] Integração com calendário
- [ ] Análise de sentiment automática
- [ ] Suporte a screenshots

### v1.2 (Futuro)
- [ ] Modo colaborativo (equipes)
- [ ] Integração com Slack/Discord
- [ ] Dashboard web opcional
- [ ] Plugins personalizados

### v2.0 (Visão)
- [ ] IA local (sem dependência de APIs)
- [ ] Análise de código automática
- [ ] Sugestões preditivas
- [ ] Métricas de bem-estar

## 🤝 Contribuindo

Contribuições são muito bem-vindas! Veja [CONTRIBUTING.md](CONTRIBUTING.md) para detalhes.

### Como Ajudar
- 🐛 **Reporte bugs** via Issues
- 💡 **Sugira features** via Discussions
- 📖 **Melhore documentação**
- 🧪 **Teste com diferentes IAs**
- 🔧 **Contribua com código**

## 📄 Licença

Este projeto está licenciado sob a licença MIT - veja [LICENSE](LICENSE) para detalhes.

## ❤️ Agradecimentos

- Comunidade de desenvolvedores que inspirou este projeto
- Pesquisadores de IA que tornaram possível "software vivo"
- Todos os beta testers que ajudaram a refinar o sistema

---

## 🎯 Por que DiaryMCP?

> *"O melhor momento para plantar uma árvore foi há 20 anos. O segundo melhor momento é agora."*

O DiaryMCP planta uma árvore de conhecimento que cresce com cada sessão de código. Em poucos meses, você terá uma base de conhecimento pessoal rica, conectada e acionável.

**Comece hoje. Seu eu futuro agradecerá.**

---

<div align="center">

### 🚀 [Instalar DiaryMCP](https://github.com/Glucksberg/DiaryMCP/releases) • 📖 [Documentação](docs/) • 💬 [Discussions](https://github.com/Glucksberg/DiaryMCP/discussions)

*Feito com ❤️ por desenvolvedores, para desenvolvedores*

</div>
