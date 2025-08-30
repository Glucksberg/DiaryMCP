# Resumo Técnico

- Decisão: priorizar arquitetura “Software Vivo” (IA como runtime) com Guide Mode padrão.
- Alternativa: runtime tradicional de código, deixando a IA resolver as partes difíceis.
- Trade-offs:
  - Software Vivo: + portabilidade, + zero dependências, - depende da IA e do agente seguir as regras.
  - Código clássico: + determinismo/offline, + automação direta, - mais manutenção/complexidade.
- Riscos identificados: execução de scripts sob sandbox; ausência de `jq` em ambientes mínimos.
- Mitigações: `capture.sh` reformulado (ASCII, sem `jq`), fallback por prompts; Guide Mode para condução humana.
- Ações desta sessão: Guide Mode adicionado (prompts/regras/ativar/manifest), captura validada, repo inicializado, branch `codex` criada e publicada.

Checklist de retomada (<= 7):
- [ ] Sincronizar template `capture.sh` para ambientes Windows/macOS (PowerShell e .bat)
- [ ] Adicionar `scripts/rebuild-index.sh` (reconstrução do grafo sem jq)
- [ ] Implementar intents práticos: `status`, `search`, `report` com guias claros
- [ ] Validar privacidade `.diaryprivate` com casos reais
- [ ] Abrir PR `codex` → `main` e revisar

Próximos passos (comandos sugeridos):
- Captura rápida: `./.diary/scripts/capture.sh "[nota]"`
- Buscar termo nas entradas: `rg -n "termo" .diary/data/entries -g '!**/context.json'`
