# DiaryMCP Protocol

Two phases, two entry points:

- Installation (once): read `DiaryMCP/instalar.md` and create a project-local `.diary/` fully customized.
- Activation (daily): read `.diary/ativar.md` and act as the runtime, processing commands and persisting entries.

Message format (NDJSON per line):

```
{ "version":"1.0","type":"capture.request","id":"uuid","timestamp":"ISO-8601",
  "payload":{"trigger":"manual","context":{},"options":{"depth":"normal","sentiment_analysis":true}},
  "metadata":{"agent":"terminal","user_note":"optional"} }
```

Artifacts:
- `context.json`: snapshot of the session context.
- `entry.md`, `tech.md`, `story.md`: human-readable daily notes.
- `index.json`, `tags.json`: graph and tags indices.
- `io/inbox.ndjson`, `io/outbox.ndjson`, `io/state.json`: message queues and state.

Degradation:
- No git → use filesystem timestamps.
- Corruption → quarantine and rebuild indices.
- Respect `.diaryprivate` for excludes.

