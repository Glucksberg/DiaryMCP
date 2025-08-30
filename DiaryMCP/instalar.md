# 📦 INSTALAÇÃO DO DIARYMCP

Você (IA) foi solicitado a instalar o DiaryMCP neste projeto. Siga exatamente os passos abaixo. Em caso de falha, informe com precisão, não deixe arquivos pela metade e proponha correções.

Estado alvo após concluir:

```
.diary/
  ativar.md
  manifest.yaml
  engine/
    rules.md
    contracts.yaml
    prompts/
      capture.md
      analyze.md
      generate.md
  io/
    inbox.ndjson
    outbox.ndjson
    state.json
  data/
    index.json
    tags.json
    entries/
  scripts/
    capture.sh (Linux/macOS)
    capture.ps1 (Windows PowerShell)
    capture.bat (Windows cmd)
```

## Passos de instalação (determinísticos)

1) Detectar informações do projeto
- Raiz do projeto: diretório atual.
- Nome do projeto: preferir, na ordem: `package.json:name`, `pyproject.toml:tool.poetry.name`, `Cargo.toml:package.name`, nome da pasta.
- Linguagem principal: heurística por arquivos encontrados (js/ts, py, rb, go, rs, java/kotlin, cs, php, sh), registrando a primeira mais frequente.
- Git: se existir `.git/`, branch atual via `git rev-parse --abbrev-ref HEAD`. Caso não exista, ativar modo `fallback_modes.no_git`.
- Pastas importantes: detectar `src`, `app`, `lib`, `tests`/`test`, `docs`, se existirem.

2) Criar pasta `.diary/`
- Se já existir: perguntar se deve sobrescrever. Se sim, preserve `.diary/data/entries/` e `.diary/io/state.json` quando possível e refaça o restante; se não, aborte educadamente.

3) Copiar templates
- Copie tudo de `DiaryMCP/templates/` para `.diary/`, preservando a estrutura de pastas.
- Personalize placeholders nos arquivos copiados:
  - `[NOME_DO_PROJETO]` → nome detectado.
  - `[DATA_INSTALACAO_ISO]` → data/hora atual ISO 8601.
  - `[LINGUAGEM_PRINCIPAL]` → linguagem detectada.
  - `[BRANCH_PADRAO]` → branch atual ou `main` se não houver git.
  - Seções em `manifest.yaml` devem refletir as pastas importantes detectadas.

4) Criar estrutura de dados inicial
```
.diary/
  io/
    inbox.ndjson        # criar vazio
    outbox.ndjson       # criar vazio
    state.json          # {"version":"1.0","last_entry":null,"stats":{"entries":0}}
  data/
    index.json          # {"version":"1.0","project":"[NOME]","entries":[],"edges":[]}
    tags.json           # {"version":"1.0","tags":{}}
    entries/            # pasta vazia
```

5) Configurar .gitignore do projeto (adicionar, sem duplicar)
```
# DiaryMCP
.diary/io/
.diary/data/entries/
.diary/scripts/capture.sh
.diary/scripts/capture.ps1
.diary/scripts/capture.bat
```

6) Configurar script de captura
- Detecte o OS do usuário:
  - Linux/macOS: tornar `.diary/scripts/capture.sh` executável (chmod +x) e indicar uso `./.diary/scripts/capture.sh "[nota opcional]"`.
  - Windows: preferir `.diary/scripts/capture.ps1` (assinar execução se necessário) e oferecer `.diary\scripts\capture.bat` como wrapper.

7) Confirmar instalação
- Imprima o resumo:
  - Projeto, linguagem, branch padrão, data de instalação.
  - Caminho da pasta `.diary/`.
  - Como ativar: “Ative o DiaryMCP”.
  - Como capturar: caminho do script adequado.

8) Em caso de falha
- Informe exatamente o passo que falhou, o erro e o arquivo atingido.
- Restaure estado anterior sempre que possível; se não, deixe instruções manuais claras.

---

## Personalização a aplicar durante a cópia

Alvos e substituições (procure e substitua, literal):
- `.diary/ativar.md`:
  - `[NOME_DO_PROJETO]`, `[DATA_INSTALACAO_ISO]`, `[BRANCH_PADRAO]`
- `.diary/manifest.yaml`:
  - `project.name`, `project.install_date`, `project.default_branch`, `project.language`
  - `project.paths.important`

---

## Verificação pós-instalação (checklist)
- `.diary/ativar.md` existe e tem placeholders preenchidos.
- `.diary/manifest.yaml` válido (chaves principais presentes).
- `.diary/io/*` criados; `state.json` coerente.
- `.diary/data/index.json` e `tags.json` criados.
- Script de captura apropriado acessível.

---

## Notas sobre degradação graciosa
- Sem git: use timestamps do filesystem, liste arquivos modificados por `find` nas últimas 3 horas.
- Dados corrompidos: mova para `.diary/.quarantine/` e reconstrua `index.json` re-varrendo `.diary/data/entries/`.
- Privacidade: respeite `.diaryprivate` (globs de exclusão) se existir, ao capturar ou indexar.

---

## Exemplo de saída de confirmação

```
✅ DiaryMCP instalado em .diary/
Projeto: CloudFarmAPI | Linguagem: TypeScript | Branch: main
Instalado em: 2025-01-01T12:34:56Z

Ativar: "Ative o DiaryMCP"
Capturar (Unix): ./.diary/scripts/capture.sh "[nota opcional]"
Capturar (Windows): .\.diary\scripts\capture.bat "[nota opcional]"
```

