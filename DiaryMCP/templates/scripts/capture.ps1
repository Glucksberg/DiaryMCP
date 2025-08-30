Param(
  [Parameter(Position=0)][string]$Note = $null
)

$ErrorActionPreference = "Stop"

$Root = (Get-Location).Path
$Diary = Join-Path $Root ".diary"
$Entries = Join-Path $Diary "data/entries"
$IndexFile = Join-Path $Diary "data/index.json"
$StateFile = Join-Path $Diary "io/state.json"
$ManifestFile = Join-Path $Diary "manifest.yaml"

$Date = Get-Date -Format "yyyy-MM-dd"
$Time = Get-Date -Format "HH-mm-ss"
$EntryPath = Join-Path (Join-Path $Entries $Date) $Time
New-Item -ItemType Directory -Force -Path $EntryPath | Out-Null

$OSName = $PSVersionTable.OS
$ShellName = "powershell"

function Has-Git { (Get-Command git -ErrorAction SilentlyContinue) -ne $null }

$GitPresent = $false
$GitBranch = $null
$GitStatus = @()
$GitCommits = @()
$GitChanged = @()

if (Has-Git) {
  $GitPresent = $true
  try { $GitBranch = (git rev-parse --abbrev-ref HEAD) } catch { $GitBranch = $null }
  try { $GitStatus = (git status --porcelain=v1) } catch {}
  try { $GitCommits = (git log --oneline -n 10) } catch {}
  try { $GitChanged = (git diff --name-only --diff-filter=ACMRTUXB HEAD) } catch {}
}

# Recent files last 180 minutes
$threshold = (Get-Date).AddMinutes(-180)
$RecentFiles = Get-ChildItem -Path $Root -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch "\\\.git\\" -and $_.FullName -notmatch "\\\.diary\\" -and $_.LastWriteTime -ge $threshold } |
  Select-Object -First 500 |
  ForEach-Object { $_.FullName.Substring($Root.Length + 1) }

# TODO/FIXME scan (best-effort)
$TodoLines = @()
try {
  $TodoLines = git grep -n -e "TODO" -e "FIXME" HEAD 2>$null
} catch {}

# Project name (rough)
$ProjectName = Split-Path $Root -Leaf

$Context = [ordered]@{
  timestamp = (Get-Date).ToString("o")
  project = $ProjectName
  cwd = $Root
  os = $OSName
  shell = $ShellName
  git = [ordered]@{
    present = $GitPresent
    branch = $GitBranch
    status = @($GitStatus)
    recent_commits = @($GitCommits)
    changed_files = @($GitChanged)
  }
  files_recent = @($RecentFiles)
  todos = @(
    $TodoLines | Select-Object -First 200 | ForEach-Object {
      $parts = $_ -split ":",3
      [ordered]@{ file=$parts[0]; line=([int]$parts[1]); text=$parts[2] }
    }
  )
  note = $Note
}

$Context | ConvertTo-Json -Depth 6 | Out-File -FilePath (Join-Path $EntryPath "context.json") -Encoding UTF8

@(
  "# Entry - $Date $Time",
  "",
  "Projeto: $ProjectName",
  $(if ($GitPresent) { "Branch: $GitBranch" } else { "" }),
  "",
  "- Contexto: ver context.json",
  "- Técnico: ver tech.md",
  "- Narrativa: ver story.md"
) | Out-File -FilePath (Join-Path $EntryPath "entry.md") -Encoding UTF8

"# Resumo Técnico`n`n(gerado pela IA durante ativação)" | Out-File (Join-Path $EntryPath "tech.md") -Encoding UTF8
"# Narrativa Pessoal`n`n(gerado pela IA durante ativação)" | Out-File (Join-Path $EntryPath "story.md") -Encoding UTF8

Write-Host "Saved entry at $EntryPath"

