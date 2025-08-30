# Regras do Diário (Engine)

Estas regras guiam a execução do DiaryMCP pelo agente durante a ativação.

## 1) Captura de contexto
- Preferir script local (`scripts/capture.*`).
- Se não puder executar scripts, seguir o prompt `prompts/capture.md`.
- Conteúdo mínimo da captura:
  - Timestamp e timezone
  - Informações do git (se houver): branch, commits recentes (<= 10), `status --porcelain`, arquivos alterados
  - Arquivos modificados no filesystem nas últimas 3h (excluindo `.diary/` e padrões de `.diaryprivate`)
  - TODO/FIXME recém-detectados (até 200 linhas)
  - Nota do usuário, se fornecida
  - Ambiente: OS, shell, diretório atual, projeto
  - Resultados devem ir para `.diary/data/entries/YYYY-MM-DD/HH-MM-SS/`

## 2) Geração de narrativas (dupla)
- Resumo técnico (tech.md):
  - Decisões, trade-offs, riscos, próximos passos (<= 7 itens), referências
  - Estrutura clara, objetiva, com bullets
- Narrativa pessoal (story.md):
  - Linha do tempo breve, estado mental, insights
  - Fecho com como retomar a sessão
- Use `prompts/analyze.md` e `prompts/generate.md` e dados de `context.json` como insumo.

## 3) Interconexão (grafo)
- Ligue cada entrada à anterior (edge tipo `temporal`)
- Ligue por branch (edge `branch:<nome>`) para entradas na mesma branch
- Ligue por arquivos (edge `file:<path>`) quando houver interseções relevantes
- Tags semânticas: deduza `feature:`, `bug:`, `refactor:`, `risk:`, `insight:` do conteúdo
- Threads de pensamento: mantenha continuidade por tag `thread:<slug>` quando perceber evolução de uma ideia

## 4) Self-healing e migração
- Valide JSONs contra `contracts.yaml`
- Se índices corrompidos, mova para `quarantine` e reconstrua indexando as entradas existentes
- Migrações: se `protocol.version` aumentar, aplicar transformações definidas em `contracts.yaml:migrations`

## 5) Comandos
- `capture [nota]`: capturar contexto e gerar narrativas; atualizar índices; responder em outbox
- `status`: computar contagens e última entrada
- `last`: obter última entrada e sintetizar um resumo curto
- `search [termo]`: listar entradas com match (ranking simples por contagem de ocorrências)
- `connect`: propor edges faltantes com base em branch/arquivos/tags; aplicar se coerente
- `report [periodo]`: sumarizar produtividade e padrões do período

## 6) Privacidade e limites
- Respeitar `.diaryprivate` (globs)
- Não incluir segredos (chaves, tokens). Se detectar, ofuscar
- Tamanho máximo por arquivo de saída: 256 KB

## 7) Guide Mode (condução interativa)
- Postura: atue como copiloto humano, guiando por passos curtos.
- Sempre proponha as próximas 1–2 ações com clareza e objetivo.
- Sugira comandos prontos para copiar (não execute você mesmo, peça confirmação).
- Aguarde o usuário confirmar o que rodou e retornar a saída relevante.
- Ao final de cada micro‑passo, resuma o estado e proponha a próxima ação.
- Para capturar: sugira `./.diary/scripts/capture.sh "[nota opcional]"` quando fizer sentido.
- Para consultas: ofereça `status`, `last`, `search`, `report` como intents e traduza em passos concretos.
- Encerramento: ofereça “finalizar sessão” e registrar captura final; depois despeça‑se brevemente.
