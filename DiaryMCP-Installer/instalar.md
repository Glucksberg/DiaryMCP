# 📦 INSTALAÇÃO DO DIARYMCP

Você foi solicitado a instalar o DiaryMCP neste projeto.

## PASSOS DE INSTALAÇÃO

### 1. Criar pasta `.diary/` na raiz do projeto atual
- Use pasta oculta para não poluir o projeto
- Se já existir, pergunte se deve sobrescrever

### 2. Detectar informações do projeto
- Nome do projeto (baseado na pasta ou package.json/pom.xml/etc)
- Tipo de projeto (detectar linguagem principal)
- Tem git? Qual branch padrão?
- Estrutura de pastas

### 3. Copiar templates para `.diary/`
- Copie todos os arquivos de `DiaryMCP/templates/` para `.diary/`
- Ajuste caminhos e configurações no `manifest.yaml`
- Personalize `ativar.md` com o nome do projeto

### 4. Criar estrutura de dados inicial
```
.diary/
├── io/           (criar vazio)
├── data/
│   ├── index.json    {"project": "[NOME]", "entries": [], "edges": []}
│   ├── tags.json     {"tags": {}}
│   └── entries/      (criar vazio)
```

### 5. Configurar .gitignore do projeto
Adicionar (se não existir):
```
# DiaryMCP
.diary/io/
.diary/data/entries/
.diary/scripts/capture.sh
```

### 6. Criar script de captura
- Gerar `.diary/scripts/capture.sh` específico para o OS detectado
- Tornar executável se possível

### 7. Confirmar instalação e limpeza
```
✅ DiaryMCP instalado com sucesso em .diary/

📁 A pasta original DiaryMCP/ não é mais necessária.
   Todos os arquivos foram copiados e personalizados para este projeto.

🗑️ Posso remover a pasta DiaryMCP/ para você agora?
   (Digite 'sim' para remover ou 'não' para manter)

📋 COMANDOS DISPONÍVEIS APÓS ATIVAR:

🚀 Comandos Básicos:
   • "Ative o DiaryMCP" - Inicia o sistema (sempre primeiro)
   • "capture [nota]" - Captura contexto atual da sessão
   • "status" - Mostra estatísticas do projeto
   • "last" - Exibe última entrada registrada

🔍 Comandos de Busca:
   • "search [termo]" - Busca termo nas entradas
   • "connect" - Analisa conexões entre sessões
   • "report [período]" - Relatório (hoje/semana/mês)

🛠️ Comandos de Manutenção:
   • "rebuild" - Reconstrói índices dos dados
   • "cleanup" - Remove arquivos temporários
   • "export [formato]" - Exporta dados (json/md/html)

📝 Comandos Rápidos:
   • "Diary: [nota]" - Atalho para capturar sessão
   • "Finalizando: [nota]" - Marca fim de sessão

⚡ INÍCIO RÁPIDO:
1. "Ative o DiaryMCP"
2. "capture Primeira sessão de teste"
3. "status" (para ver se funcionou)

Para capturar via terminal: .diary/scripts/capture.sh "[nota]"
```

**IMPORTANTE**: Após resposta do usuário sobre remoção da pasta:
- Se 'sim': execute `rm -rf DiaryMCP/` ou comando equivalente do OS
- Se 'não': mantenha pasta e informe que pode ser removida manualmente depois

## SE FALHAR
- Informar exatamente o que falhou
- Não deixar arquivos pela metade
- Sugerir instalação manual

## INSTRUÇÕES DETALHADAS PARA A IA

### Detecção do Projeto
1. **Nome do projeto**: 
   - Verificar `package.json` (campo `name`)
   - Verificar `pom.xml` (campo `artifactId`)
   - Verificar `Cargo.toml` (campo `name`)
   - Usar nome da pasta como fallback

2. **Tipo de projeto**:
   - JavaScript/TypeScript: `package.json` presente
   - Python: `requirements.txt` ou `setup.py` presente
   - Java: `pom.xml` ou `build.gradle` presente
   - Rust: `Cargo.toml` presente
   - Go: `go.mod` presente
   - Genérico: se nenhum dos acima

3. **Informações Git**:
   - Verificar se `.git/` existe
   - Obter branch atual: `git branch --show-current`
   - Verificar se há commits: `git log --oneline -n 1`

### Personalização dos Templates
1. **manifest.yaml**: Substituir placeholders:
   - `[PROJECT_NAME]` → nome detectado
   - `[PROJECT_TYPE]` → tipo detectado
   - `[GIT_BRANCH]` → branch padrão
   - `[INSTALL_DATE]` → data atual

2. **ativar.md**: Substituir:
   - `[NOME DO PROJETO]` → nome detectado
   - `[DATA]` → data de instalação
   - `[LINGUAGEM]` → linguagem principal

### Estrutura de Dados Inicial
Criar arquivos JSON com estrutura mínima válida:

**index.json**:
```json
{
  "project": "[PROJECT_NAME]",
  "installed_at": "[ISO_DATE]",
  "version": "1.0",
  "entries": [],
  "edges": [],
  "stats": {
    "total_entries": 0,
    "total_sessions": 0,
    "last_capture": null
  }
}
```

**tags.json**:
```json
{
  "tags": {},
  "categories": {
    "feature": [],
    "bug": [],
    "refactor": [],
    "risk": [],
    "insight": []
  }
}
```

### Tratamento de Erros
- Se não conseguir criar `.diary/`: sugerir criação manual
- Se não conseguir detectar tipo de projeto: usar "genérico"
- Se git não estiver disponível: configurar modo sem git
- Se não conseguir tornar script executável: informar ao usuário

### Validação Final
Verificar se foram criados:
- [ ] `.diary/ativar.md`
- [ ] `.diary/manifest.yaml`
- [ ] `.diary/engine/rules.md`
- [ ] `.diary/data/index.json`
- [ ] `.diary/data/tags.json`
- [ ] `.diary/scripts/capture.sh`

Se algum arquivo estiver faltando, informar claramente o erro.
