#!/usr/bin/env bash
set -euo pipefail

# DiaryMCP Capture Script (Unix)
# Usage: ./.diary/scripts/capture.sh "optional note"

NOTE=${1-}
ROOT_DIR=$(pwd)
DIARY_DIR="$ROOT_DIR/.diary"
ENTRIES_DIR="$DIARY_DIR/data/entries"
INDEX_FILE="$DIARY_DIR/data/index.json"
STATE_FILE="$DIARY_DIR/io/state.json"
MANIFEST_FILE="$DIARY_DIR/manifest.yaml"

DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H-%M-%S")
ENTRY_PATH="$ENTRIES_DIR/$DATE/$TIME"

mkdir -p "$ENTRY_PATH"

OS_NAME=$(uname -s 2>/dev/null || echo "unknown")
SHELL_NAME=$(basename "${SHELL:-sh}")

has_git() { command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; }

GIT_PRESENT=false
GIT_BRANCH=null
GIT_STATUS=()
GIT_COMMITS=()
GIT_CHANGED=()

if has_git; then
  GIT_PRESENT=true
  GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "null")
  # status
  while IFS= read -r line; do GIT_STATUS+=("$line"); done < <(git status --porcelain=v1 || true)
  # recent commits
  while IFS= read -r line; do GIT_COMMITS+=("$line"); done < <(git log --oneline -n 10 || true)
  # changed files (staged/unstaged/renamed/etc)
  while IFS= read -r line; do GIT_CHANGED+=("$line"); done < <(git diff --name-only --diff-filter=ACMRTUXB HEAD || true)
fi

# Recent files by mtime (last 180 minutes)
mapfile -t RECENT_FILES < <(find "$ROOT_DIR" -type f \
  -not -path "*/.git/*" -not -path "*/.diary/*" \
  -mmin -180 2>/dev/null | sed "s|^$ROOT_DIR/||" | head -n 500)

# Respect .diaryprivate excludes (simple glob per line)
if [[ -f "$ROOT_DIR/.diaryprivate" ]]; then
  FILTERED=()
  while IFS= read -r f; do
    skip=false
    while IFS= read -r pat; do
      [[ -z "$pat" || "$pat" =~ ^# ]] && continue
      if [[ "$f" == $pat ]]; then skip=true; break; fi
    done < "$ROOT_DIR/.diaryprivate"
    $skip || FILTERED+=("$f")
  done < <(printf "%s\n" "${RECENT_FILES[@]}")
  RECENT_FILES=(${FILTERED[@]:-})
fi

# TODO/FIXME scan (limit ~200)
mapfile -t TODO_LINES < <(rg -n --no-heading -e "TODO|FIXME" \
  -g '!**/.git/**' -g '!**/.diary/**' . 2>/dev/null | head -n 200 || true)

# Project name from manifest if possible
PROJECT_NAME=$(awk -F': ' '/^project:\s*$/{p=1;next} p&&/name:/{print $2; exit}' "$MANIFEST_FILE" 2>/dev/null || echo "")
PROJECT_NAME=${PROJECT_NAME//"/}
[[ -z "$PROJECT_NAME" ]] && PROJECT_NAME=$(basename "$ROOT_DIR")

# Build context.json
{
  printf '{\n'
  printf '  "timestamp": "%s",\n' "$(date -Iseconds)"
  printf '  "project": "%s",\n' "${PROJECT_NAME}"
  printf '  "cwd": "%s",\n' "$ROOT_DIR"
  printf '  "os": "%s",\n' "$OS_NAME"
  printf '  "shell": "%s",\n' "$SHELL_NAME"
  printf '  "git": {\n'
  printf '    "present": %s,\n' "$GIT_PRESENT"
  if [[ "$GIT_BRANCH" == "null" ]]; then printf '    "branch": null,\n'; else printf '    "branch": "%s",\n' "$GIT_BRANCH"; fi
  printf '    "status": ['
  for i in "${!GIT_STATUS[@]}"; do s=${GIT_STATUS[$i]//"/\"}; [[ $i -gt 0 ]] && printf ','; printf '"%s"' "$s"; done
  printf '],\n'
  printf '    "recent_commits": ['
  for i in "${!GIT_COMMITS[@]}"; do s=${GIT_COMMITS[$i]//"/\"}; [[ $i -gt 0 ]] && printf ','; printf '"%s"' "$s"; done
  printf '],\n'
  printf '    "changed_files": ['
  for i in "${!GIT_CHANGED[@]}"; do s=${GIT_CHANGED[$i]//"/\"}; [[ $i -gt 0 ]] && printf ','; printf '"%s"' "$s"; done
  printf ']\n'
  printf '  },\n'
  printf '  "files_recent": ['
  for i in "${!RECENT_FILES[@]}"; do s=${RECENT_FILES[$i]//"/\"}; [[ $i -gt 0 ]] && printf ','; printf '"%s"' "$s"; done
  printf '],\n'
  printf '  "todos": ['
  count=0
  for line in "${TODO_LINES[@]}"; do
    file=$(printf "%s" "$line" | cut -d: -f1)
    lineno=$(printf "%s" "$line" | cut -d: -f2)
    text=$(printf "%s" "$line" | cut -d: -f3- | sed 's/"/\\"/g')
    [[ $count -gt 0 ]] && printf ','
    printf '{"file":"%s","line":%s,"text":"%s"}' "$file" "$lineno" "$text"
    count=$((count+1))
  done
  printf '],\n'
  if [[ -n "$NOTE" ]]; then
    printf '  "note": "%s"\n' "${NOTE//"/\"}"
  else
    printf '  "note": null\n'
  fi
  printf '}\n'
} > "$ENTRY_PATH/context.json"

# entry.md skeleton
{
  echo "# Entry - $DATE $TIME"
  echo
  echo "Projeto: $PROJECT_NAME"
  if [[ "$GIT_PRESENT" == true ]]; then echo "Branch: $GIT_BRANCH"; fi
  echo
  echo "- Contexto: ver context.json"
  echo "- Técnico: ver tech.md"
  echo "- Narrativa: ver story.md"
} > "$ENTRY_PATH/entry.md"

# Empty placeholders for narratives
printf "# Resumo Técnico\n\n(gerado pela IA durante ativação)\n" > "$ENTRY_PATH/tech.md"
printf "# Narrativa Pessoal\n\n(gerado pela IA durante ativação)\n" > "$ENTRY_PATH/story.md"

# Update index.json and state.json (best-effort)
rel_id="$DATE/$TIME"
jincrement() {
  local file="$1"
  if [[ -f "$file" ]]; then
    tmp=$(mktemp)
    entries=$(jq '.stats.entries' "$file" 2>/dev/null || echo 0)
    if [[ "$entries" == "" ]]; then entries=0; fi
    jq --arg id "$rel_id" '.last_entry=$id | .stats.entries=(.stats.entries+1)' "$file" 2>/dev/null > "$tmp" || echo "{\"version\":\"1.0\",\"last_entry\":\"$rel_id\",\"stats\":{\"entries\":1}}" > "$tmp"
    mv "$tmp" "$file"
  else
    printf '{"version":"1.0","last_entry":"%s","stats":{"entries":1}}' "$rel_id" > "$file"
  fi
}

# Use jq if available; else append minimally without breaking
if command -v jq >/dev/null 2>&1; then
  # index.json
  if [[ -f "$INDEX_FILE" ]]; then
    tmp=$(mktemp)
    jq --arg id "$rel_id" --arg date "$DATE" --arg time "$TIME" --arg path "$ENTRY_PATH" --arg branch "${GIT_BRANCH:-null}" \
      '.entries += [{id:$id,date:$date,time:$time,path:$path,branch:($branch|select(.!="")|.)}]' "$INDEX_FILE" > "$tmp" || true
    mv "$tmp" "$INDEX_FILE"
  fi
  jincrement "$STATE_FILE"
else
  # naive append
  if [[ -f "$INDEX_FILE" ]]; then echo "// add $rel_id at $ENTRY_PATH" >> "$INDEX_FILE"; fi
  # create state if missing
  [[ -f "$STATE_FILE" ]] || printf '{"version":"1.0","last_entry":null,"stats":{"entries":0}}' > "$STATE_FILE"
fi

echo "Saved entry at $ENTRY_PATH"

