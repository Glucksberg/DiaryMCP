# DiaryMCP Auto-Installer v1.1

> 🚀 **Zero Tokens Installation** - Instala DiaryMCP sem consumir tokens de IA

## 📋 O que é isto?

Este é um **instalador automático** que substitui o processo manual de instalação via IA. Em vez de consumir ~4000 tokens por instalação, agora você usa **0 tokens**.

### 💰 Economia Gigantesca
```
❌ Instalação via IA:
   • Ler instalar.md: ~2000 tokens
   • Processar templates: ~1500 tokens  
   • Gerar personalizações: ~500 tokens
   TOTAL: ~4000 tokens por instalação

✅ Auto-instalação:
   • Execução do script: 0 tokens
   • Apenas confirmar resultado: ~50 tokens
   TOTAL: ~50 tokens por instalação
   
💡 ECONOMIA: 98.7% menos tokens!
```

## 🚀 Como Usar

### **Opção 1: Bash (Linux/Mac)**
```bash
chmod +x install.sh
./install.sh
```

### **Opção 2: PowerShell (Windows)**
```powershell
./install.ps1
```

### **Opção 3: Python (Multiplataforma)**
```bash
python3 install.py
# ou
./install.py
```

### **Opção 4: Download Direto**
```bash
# Linux/Mac
curl -L https://raw.githubusercontent.com/user/DiaryMCP/main/installer/install.sh | bash

# Windows PowerShell
iwr https://raw.githubusercontent.com/user/DiaryMCP/main/installer/install.ps1 | iex
```

## ⚡ O que o Script Faz

1. **🔍 Detecta automaticamente**:
   - Nome do projeto (package.json, pom.xml, Cargo.toml, etc.)
   - Tipo de projeto (javascript, python, rust, java, etc.)
   - Linguagem principal
   - Sistema operacional

2. **🏗️ Cria estrutura completa**:
   ```
   .diary/
   ├── ativar.md              # Personalizado para seu projeto
   ├── manifest.yaml          # Configurado automaticamente
   ├── data/
   │   ├── index.json         # Com informações do seu projeto
   │   ├── tags.json          # Estrutura inicial
   │   └── entries/           # Pasta para sessões
   ├── engine/
   │   ├── rules.md           # Regras de otimização
   │   └── prompts/           # Templates de IA
   └── scripts/
       └── capture.*          # Script de captura para seu OS
   ```

3. **⚙️ Personaliza automaticamente**:
   - Substitui placeholders com dados reais
   - Configura otimizações de tokens
   - Adiciona entradas no .gitignore
   - Cria arquivos de configuração

4. **✅ Valida instalação**:
   - Verifica se todos arquivos foram criados
   - Testa integridade da estrutura
   - Confirma que está tudo pronto

## 📊 Funcionalidades Incluídas

### 🆕 **Sistema de Otimização v1.1**
- **Resumos compactos**: Cada sessão gera summary.json (1000 tokens max)
- **Carregamento seletivo**: Próximas sessões leem apenas resumos
- **Economia massiva**: 90%+ menos tokens em projetos grandes

### 🎯 **Detecção Inteligente**
- **15+ tipos de projeto** suportados
- **8+ linguagens** detectadas automaticamente
- **Git integration** automática
- **OS-specific scripts** gerados

### 🔧 **Configuração Zero**
- **Sem perguntas** desnecessárias
- **Detecção automática** de tudo
- **Fallbacks inteligentes** se algo não for detectado
- **Validação completa** antes de finalizar

## 📁 Estrutura do Pacote

```
DiaryMCP-AutoInstaller/
├── install.sh              # Script Bash (Linux/Mac)
├── install.ps1             # Script PowerShell (Windows)
├── install.py              # Script Python (Multiplataforma)  
├── README.md               # Este arquivo
└── templates/              # Templates originais (opcional)
    ├── ativar.md
    ├── manifest.yaml
    └── engine/...
```

## 🎯 Após Instalação

O script automaticamente:

1. **Mostra próximos passos**:
   - Como ativar: `"Ative o DiaryMCP"`
   - Primeira captura: `"capture Primeira sessão de teste"`
   - Ver status: `"status"`

2. **Informa economia**:
   - 0 tokens usados na instalação
   - 90%+ economia nas próximas sessões

3. **Sugere limpeza**:
   - Como remover pasta de instalação
   - Confirma que .diary/ é independente

## 🔧 Opções Avançadas

### **Forçar Reinstalação**
```bash
./install.sh               # Pergunta se quer sobrescrever
./install.py --force       # Sobrescreve automaticamente
./install.ps1 -Force       # PowerShell com flag
```

### **Instalação Silenciosa**
```bash
echo "y" | ./install.sh    # Responde "y" automaticamente
```

### **Debug/Verbose**
Os scripts mostram cada passo com cores e emojis para fácil acompanhamento.

## 🚨 Requisitos

### **Mínimos**
- **Bash**: Linux/Mac/WSL com bash
- **PowerShell**: Windows com PowerShell 5.0+
- **Python**: Python 3.6+ (multiplataforma)

### **Opcionais**
- **jq**: Para parsing avançado de JSON (bash fallback incluído)
- **git**: Para detecção de branch (fallback: "main")

### **Recomendados**
- Sistema com cores ANSI (para output bonito)
- Permissões de escrita na pasta do projeto

## ❓ Troubleshooting

### **"Permissão negada"**
```bash
chmod +x install.sh
./install.sh
```

### **"comando não encontrado"**
```bash
# Use Python em vez de bash
python3 install.py
```

### **".diary já existe"**
- Script pergunta se quer sobrescrever
- Use `--force` para sobrescrever automaticamente

### **"Instalação incompleta"**
- Script valida tudo no final
- Se falhar, mostra exatamente o que não foi criado
- Pode tentar novamente ou instalar manualmente

## 🎉 Resultado Final

Após execução bem-sucedida:

```
✅ DiaryMCP v1.1 instalado e otimizado!

📊 Economia de tokens: 98.7%
🏗️ Estrutura completa criada
⚙️ Personalização automática concluída
🔧 Configurações otimizadas aplicadas

Próximo passo: "Ative o DiaryMCP"
```

---

## 🔥 **Por que Auto-Installer?**

1. **💰 Economia Massiva**: 98.7% menos tokens por instalação
2. **⚡ Super Rápido**: Segundos vs minutos
3. **🎯 100% Confiável**: Sem interpretação de IA, sem erros
4. **🔧 Zero Config**: Detecta tudo automaticamente
5. **🚀 Offline**: Funciona sem conexão com APIs
6. **📦 Portátil**: Um arquivo, qualquer sistema

**Use este instalador e economize milhares de tokens!** 🚀

*DiaryMCP Auto-Installer v1.1 - Zero Tokens, Maximum Efficiency*