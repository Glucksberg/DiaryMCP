#!/usr/bin/env python3
"""
DiaryMCP Auto-Installer v1.1 - Python
Instala automaticamente o DiaryMCP sem usar tokens de IA
"""

import os
import sys
import json
import shutil
import subprocess
from datetime import datetime, timezone
from pathlib import Path
import argparse

# Cores ANSI para output colorido
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    BLUE = '\033[0;34m'
    YELLOW = '\033[1;33m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # No Color

def print_colored(text, color=Colors.NC):
    """Imprime texto colorido"""
    print(f"{color}{text}{Colors.NC}")

def print_logo():
    """Imprime o logo ASCII"""
    print_colored("╔═══════════════════════════════════════╗", Colors.BLUE)
    print_colored("║        DiaryMCP Auto-Installer        ║", Colors.BLUE)
    print_colored("║              v1.1 - 2024              ║", Colors.BLUE)
    print_colored("║                                       ║", Colors.BLUE)
    print_colored("║     🚀 Zero Tokens Installation       ║", Colors.BLUE)
    print_colored("╚═══════════════════════════════════════╝", Colors.BLUE)
    print()

def detect_project_name():
    """Detecta o nome do projeto"""
    # Tentar package.json primeiro
    if os.path.exists("package.json"):
        try:
            with open("package.json", 'r') as f:
                data = json.load(f)
                if 'name' in data and data['name']:
                    return data['name']
        except (json.JSONDecodeError, IOError):
            pass
    
    # Tentar pom.xml
    if os.path.exists("pom.xml"):
        try:
            with open("pom.xml", 'r') as f:
                content = f.read()
                import re
                match = re.search(r'<artifactId>([^<]+)</artifactId>', content)
                if match:
                    return match.group(1)
        except IOError:
            pass
    
    # Tentar Cargo.toml
    if os.path.exists("Cargo.toml"):
        try:
            with open("Cargo.toml", 'r') as f:
                for line in f:
                    if line.startswith('name = '):
                        import re
                        match = re.search(r'name\s*=\s*"([^"]*)"', line)
                        if match:
                            return match.group(1)
        except IOError:
            pass
    
    # Tentar go.mod
    if os.path.exists("go.mod"):
        try:
            with open("go.mod", 'r') as f:
                first_line = f.readline().strip()
                if first_line.startswith('module '):
                    module_name = first_line.replace('module ', '')
                    return os.path.basename(module_name)
        except IOError:
            pass
    
    # Fallback: nome da pasta atual
    return os.path.basename(os.getcwd())

def detect_project_type():
    """Detecta o tipo do projeto"""
    if os.path.exists("package.json"):
        return "javascript"
    elif os.path.exists("pom.xml") or any(Path('.').glob("*.gradle")):
        return "java"
    elif os.path.exists("Cargo.toml"):
        return "rust"
    elif any([os.path.exists(f) for f in ["requirements.txt", "setup.py", "pyproject.toml"]]):
        return "python"
    elif os.path.exists("go.mod"):
        return "go"
    elif os.path.exists("composer.json"):
        return "php"
    elif os.path.exists("Gemfile"):
        return "ruby"
    elif any(Path('.').glob("*.csproj")) or any(Path('.').glob("*.sln")):
        return "dotnet"
    else:
        return "generic"

def detect_language():
    """Detecta a linguagem principal"""
    extensions = {
        ("js", "ts", "jsx", "tsx"): "JavaScript/TypeScript",
        ("py",): "Python",
        ("java",): "Java", 
        ("rs",): "Rust",
        ("go",): "Go",
        ("php",): "PHP",
        ("rb",): "Ruby",
        ("cs",): "C#"
    }
    
    for ext_tuple, language in extensions.items():
        for ext in ext_tuple:
            if any(Path('.').rglob(f"*.{ext}")):
                return language
    
    return "Mixed/Generic"

def detect_git_branch():
    """Detecta o branch Git atual"""
    try:
        if os.path.exists(".git") and shutil.which("git"):
            result = subprocess.run(
                ["git", "branch", "--show-current"], 
                capture_output=True, 
                text=True, 
                check=True
            )
            branch = result.stdout.strip()
            if branch:
                return branch
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    return "main"

def get_os_info():
    """Detecta informações do sistema operacional"""
    if sys.platform.startswith('linux'):
        return "Linux"
    elif sys.platform.startswith('darwin'):
        return "macOS"
    elif sys.platform.startswith('win'):
        return "Windows"
    else:
        return "Unix"

def create_directory_structure():
    """Cria a estrutura de diretórios"""
    print_colored("   📁 Criando estrutura .diary/...", Colors.CYAN)
    
    directories = [
        ".diary",
        ".diary/data",
        ".diary/data/entries", 
        ".diary/io",
        ".diary/engine",
        ".diary/engine/prompts",
        ".diary/scripts"
    ]
    
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
    
    # Verificar se templates existem junto com o script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    templates_path = os.path.join(script_dir, "templates")
    
    if os.path.exists(templates_path):
        print_colored("   📋 Copiando templates...", Colors.CYAN)
        shutil.copytree(templates_path, ".diary", dirs_exist_ok=True)
    else:
        print_colored("   📋 Criando templates inline...", Colors.CYAN)
        create_templates_inline()

def create_templates_inline():
    """Cria os templates inline quando não estão disponíveis"""
    
    # ativar.md
    ativar_content = '''# 🚀 ATIVAÇÃO DO DIARYMCP - [PROJECT_NAME]

Você agora é o motor de execução do DiaryMCP para o projeto **[PROJECT_NAME]**.

## VERIFICAÇÃO RÁPIDA
- **Projeto**: [PROJECT_NAME]
- **Tipo**: [PROJECT_TYPE]
- **Instalado em**: [INSTALL_DATE]
- **Linguagem**: [PRIMARY_LANGUAGE]

## COMANDOS DISPONÍVEIS

### Captura Rápida
- **User**: "Capture a sessão"
- **User**: "Diary: [qualquer nota rápida]"
- **User**: "Finalizando: [descrição]"

### Comandos Completos
- `capture [nota]` - Captura contexto atual com nota opcional
- `status` - Mostra estatísticas do diário
- `last` - Mostra última entrada
- `search [termo]` - Busca nas entradas
- `connect` - Sugere conexões entre entradas
- `report [período]` - Relatório do período (hoje, semana, mês)

### Comandos de Manutenção
- `rebuild` - Reconstrói índices a partir das entradas
- `cleanup` - Remove arquivos temporários
- `export [formato]` - Exporta dados (json, md, html)

## PROTOCOLO DE CAPTURA

### Sempre gerar **summary.json** (OBRIGATÓRIO!):
Cada captura DEVE criar um resumo compacto em summary.json com:
- Máximo 1000 tokens
- Resumo ultra-conciso
- Decisões principais
- Insights importantes
- Contexto para futuras sessões
- Próximos passos

### Próxima Ação
Responda: **"DiaryMCP ativo para [PROJECT_NAME]. O que deseja fazer?"**

---
*Sistema DiaryMCP v1.1 - Auto-instalado com sucesso*
'''
    
    with open(".diary/ativar.md", 'w') as f:
        f.write(ativar_content)
    
    # manifest.yaml
    manifest_content = '''# DiaryMCP Manifest - [PROJECT_NAME]
version: "1.1"
project:
  name: "[PROJECT_NAME]"
  type: "[PROJECT_TYPE]"
  language: "[PRIMARY_LANGUAGE]"
  installed_at: "[INSTALL_DATE]"

system:
  summary_optimization: true
  token_limit_per_summary: 1000
  retention_days: 30

paths:
  data: "data/"
  entries: "data/entries/"
  engine: "engine/"
  scripts: "scripts/"
  io: "io/"
'''
    
    with open(".diary/manifest.yaml", 'w') as f:
        f.write(manifest_content)
    
    # engine/rules.md básico
    rules_content = '''# DiaryMCP - Regras de Negócio

## REGRAS DE OTIMIZAÇÃO DE TOKENS (CRÍTICO!)

### Para CAPTURA de nova sessão:
- Carregar APENAS summary.json das últimas 5 sessões
- Carregar index.json para metadados
- NUNCA carregar entry.md, tech.md, story.md de sessões antigas

### Para COMANDOS de consulta:
- status: load apenas index.json + tags.json
- search: buscar primeiro em index.json, depois summary.json
- report: usar summary.json do período

### Regra de Ouro dos 30 Dias:
- Sessões > 30 dias: IA lê APENAS summary.json
- summary.json é OBRIGATÓRIO em toda captura
- summary.json MAX 1000 tokens sempre

## SEMPRE criar summary.json com:
- Resumo ultra-conciso (300 chars)
- 3 decisões principais max
- 3 insights importantes max
- 5 arquivos principais max
- Contexto para futuras sessões (250 chars)
- 3 próximos passos max
'''
    
    with open(".diary/engine/rules.md", 'w') as f:
        f.write(rules_content)
    
    # Script de captura Python
    capture_content = '''#!/usr/bin/env python3
"""DiaryMCP Capture Script - Python"""

import sys
import os
from datetime import datetime, timezone
from pathlib import Path

def main():
    if len(sys.argv) < 2:
        print("Usage: python capture.py \"your session note\"")
        print("Example: python capture.py \"Implemented JWT authentication\"")
        sys.exit(1)
    
    note = " ".join(sys.argv[1:])
    timestamp = datetime.now(timezone.utc).isoformat()
    entry_id = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H-%M-%S")
    date_folder = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    
    print(f"📝 Capturing session with note: {note}")
    print(f"🕒 Timestamp: {timestamp}")
    
    entry_path = Path(f".diary/data/entries/{date_folder}/{entry_id}")
    entry_path.mkdir(parents=True, exist_ok=True)
    
    entry_content = f"""# Session - {timestamp}

## User Note
{note}

## Captured by Script
This entry was created by the capture script.
To process it fully, use: "Ative o DiaryMCP" and then "capture {note}"
"""
    
    with open(entry_path / "entry.md", 'w') as f:
        f.write(entry_content)
    
    print("✅ Basic entry created. Use DiaryMCP with IA for full processing.")

if __name__ == "__main__":
    main()
'''
    
    with open(".diary/scripts/capture.py", 'w') as f:
        f.write(capture_content)
    
    # Tornar o script executável (Unix-like systems)
    if os.name != 'nt':
        os.chmod(".diary/scripts/capture.py", 0o755)

def personalize_files(project_name, project_type, project_language):
    """Personaliza os arquivos com informações do projeto"""
    install_date = datetime.now(timezone.utc).isoformat()
    git_branch = detect_git_branch()
    
    print_colored(f"   ⚙️  Personalizando para: {project_name}", Colors.CYAN)
    
    # Personalizar ativar.md
    if os.path.exists(".diary/ativar.md"):
        with open(".diary/ativar.md", 'r') as f:
            content = f.read()
        
        content = content.replace('[PROJECT_NAME]', project_name)
        content = content.replace('[PROJECT_TYPE]', project_type)
        content = content.replace('[INSTALL_DATE]', install_date)
        content = content.replace('[PRIMARY_LANGUAGE]', project_language)
        
        with open(".diary/ativar.md", 'w') as f:
            f.write(content)
    
    # Personalizar manifest.yaml
    if os.path.exists(".diary/manifest.yaml"):
        with open(".diary/manifest.yaml", 'r') as f:
            content = f.read()
        
        content = content.replace('[PROJECT_NAME]', project_name)
        content = content.replace('[PROJECT_TYPE]', project_type)
        content = content.replace('[PRIMARY_LANGUAGE]', project_language)
        content = content.replace('[INSTALL_DATE]', install_date)
        
        with open(".diary/manifest.yaml", 'w') as f:
            f.write(content)
    
    # Criar index.json personalizado
    index_data = {
        "project": project_name,
        "installed_at": install_date,
        "version": "1.1", 
        "project_type": project_type,
        "language": project_language,
        "git_branch": git_branch,
        "entries": [],
        "edges": [],
        "stats": {
            "total_entries": 0,
            "total_sessions": 0,
            "last_capture": None
        },
        "optimization": {
            "summary_system": "enabled",
            "token_limit_per_summary": 1000,
            "summary_retention_days": 30
        }
    }
    
    with open(".diary/data/index.json", 'w') as f:
        json.dump(index_data, f, indent=2)
    
    # Criar tags.json inicial
    tags_data = {
        "tags": {},
        "categories": {
            "feature": [],
            "bug": [],
            "refactor": [], 
            "risk": [],
            "insight": []
        },
        "last_updated": install_date
    }
    
    with open(".diary/data/tags.json", 'w') as f:
        json.dump(tags_data, f, indent=2)

def setup_gitignore():
    """Configura o .gitignore"""
    gitignore_entries = """
# DiaryMCP
.diary/io/
.diary/data/entries/
.diary/scripts/*.log
"""
    
    if os.path.exists(".gitignore"):
        with open(".gitignore", 'r') as f:
            content = f.read()
        
        if ".diary/io/" not in content:
            print_colored("   📝 Adicionando entradas ao .gitignore...", Colors.CYAN)
            with open(".gitignore", 'a') as f:
                f.write(gitignore_entries)
        else:
            print_colored("   ✅ .gitignore já configurado", Colors.CYAN)
    else:
        print_colored("   📝 Criando .gitignore...", Colors.CYAN)
        with open(".gitignore", 'w') as f:
            f.write(gitignore_entries)

def validate_installation():
    """Valida se a instalação foi bem-sucedida"""
    errors = 0
    
    print_colored("   🔍 Verificando arquivos essenciais...", Colors.CYAN)
    
    required_files = [
        ".diary/ativar.md",
        ".diary/manifest.yaml",
        ".diary/data/index.json", 
        ".diary/data/tags.json"
    ]
    
    for file_path in required_files:
        if os.path.exists(file_path):
            print_colored(f"   ✅ {file_path}", Colors.GREEN)
        else:
            print_colored(f"   ❌ {file_path}", Colors.RED)
            errors += 1
    
    required_dirs = [
        ".diary/data/entries",
        ".diary/engine", 
        ".diary/scripts"
    ]
    
    for dir_path in required_dirs:
        if os.path.exists(dir_path) and os.path.isdir(dir_path):
            print_colored(f"   ✅ {dir_path}/", Colors.GREEN)
        else:
            print_colored(f"   ❌ {dir_path}/", Colors.RED)
            errors += 1
    
    if errors > 0:
        print_colored(f"❌ Instalação incompleta ({errors} erros)", Colors.RED)
        sys.exit(1)

def show_next_steps():
    """Mostra os próximos passos após a instalação"""
    print()
    print_colored("🎯 PRÓXIMOS PASSOS:", Colors.GREEN)
    print_colored('   1. Teste a instalação: "Ative o DiaryMCP"', Colors.YELLOW)
    print_colored('   2. Primeira captura:   "capture Primeira sessão de teste"', Colors.YELLOW)
    print_colored('   3. Ver status:         "status"', Colors.YELLOW)
    print()
    print_colored("📊 ECONOMIA DE TOKENS:", Colors.PURPLE)
    print_colored("   • Esta instalação: 0 tokens usados", Colors.GREEN)
    print_colored("   • Futuras sessões: 90%+ economia com resumos", Colors.GREEN)
    print()
    print_colored("🗑️ LIMPEZA:", Colors.CYAN)
    print_colored("   A pasta de instalação pode ser removida:", Colors.NC)
    print_colored("   rm -rf DiaryMCP-AutoInstaller/ (se baixou temporariamente)", Colors.YELLOW)
    print()
    print_colored("✨ DiaryMCP v1.1 instalado e otimizado!", Colors.GREEN)

def main():
    parser = argparse.ArgumentParser(description='DiaryMCP Auto-Installer v1.1')
    parser.add_argument('--force', action='store_true', help='Sobrescrever instalação existente sem perguntar')
    args = parser.parse_args()
    
    print_logo()
    
    # 1. Verificar se já existe .diary/
    print_colored("🔍 Verificando instalação existente...", Colors.BLUE)
    if os.path.exists(".diary"):
        if not args.force:
            print_colored("⚠️  .diary/ já existe neste projeto.", Colors.YELLOW)
            response = input("   Sobrescrever instalação? (y/N): ")
            if response.lower() != 'y':
                print_colored("❌ Instalação cancelada pelo usuário", Colors.RED)
                sys.exit(1)
        print_colored("🗑️  Removendo instalação anterior...", Colors.YELLOW)
        shutil.rmtree(".diary")
    
    # 2. Detectar projeto
    print_colored("🔍 Detectando projeto...", Colors.BLUE)
    project_name = detect_project_name()
    project_type = detect_project_type()
    project_language = detect_language()
    os_info = get_os_info()
    
    print_colored(f"   📁 Nome: {project_name}", Colors.GREEN)
    print_colored(f"   🏷️  Tipo: {project_type}", Colors.GREEN)
    print_colored(f"   💻 Linguagem: {project_language}", Colors.GREEN)
    print_colored(f"   🖥️  Sistema: {os_info}", Colors.GREEN)
    
    # 3. Criar estrutura
    print_colored("🏗️  Criando estrutura .diary/...", Colors.BLUE)
    create_directory_structure()
    
    # 4. Personalizar arquivos
    print_colored("⚙️  Personalizando configurações...", Colors.BLUE)
    personalize_files(project_name, project_type, project_language)
    
    # 5. Configurar .gitignore
    print_colored("📝 Configurando .gitignore...", Colors.BLUE)
    setup_gitignore()
    
    # 6. Validar instalação
    print_colored("✅ Validando instalação...", Colors.BLUE)
    validate_installation()
    
    # 7. Sucesso!
    print()
    print_colored("╔══════════════════════════════════════╗", Colors.GREEN)
    print_colored("║      🎉 INSTALAÇÃO CONCLUÍDA!        ║", Colors.GREEN)
    print_colored("╚══════════════════════════════════════╝", Colors.GREEN)
    
    show_next_steps()

if __name__ == "__main__":
    main()