# Plugin: Slack Mentions (concept)

Objetivo: enriquecer `context.json` com menções relevantes do Slack durante a sessão.

Entrada: credenciais locais ou exportações manuais (não automatizado por padrão, para privacidade).
Saída: bloco `context.slack_mentions` com mensagens resumidas e links.

Este plugin é opcional e não instalado por padrão. Deve ser habilitado em `manifest.yaml > plugins.enabled` quando apropriado.

