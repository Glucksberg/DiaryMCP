# Prompt: Captura de Contexto

Objetivo: coletar contexto mínimo e salvar na estrutura definida.

Entrada:
- `manifest.yaml`
- `contracts.yaml`
- `note` opcional do usuário

Passos:
1) Timestamp local e timezone. Projetar `YYYY-MM-DD` e `HH-MM-SS` para paths.
2) Detectar git:
   - Se presente: branch atual, `git status --porcelain`, `git log --oneline -n 10`, `git diff --name-only --diff-filter=ACMRTUXB`.
   - Se ausente: marcar `present=false`.
3) Arquivos recentes: listar modificados nas últimas 3h com `find` (excluir `.diary/`, excluir globs de `.diaryprivate`).
4) TODO/FIXME: buscar em arquivos texto até 200 resultados, coletando `file`, `line`, `text`.
5) Ambiente: `cwd`, `OS`, `SHELL`.
6) Persistir em `.diary/data/entries/<date>/<time>/`:
   - `context.json` conforme `contracts.context`.
   - `entry.md` com sumário da sessão (inclua link para `tech.md` e `story.md`).
   - placeholders para `tech.md` e `story.md`.

Observações:
- Não incluir conteúdos sensíveis; se detectar padrões de segredo, ofuscar.
- Limitar listagens extensas; priorizar arquivos do projeto (conforme `paths.important`).

