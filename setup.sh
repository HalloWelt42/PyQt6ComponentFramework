#!/usr/bin/env bash
set -euo pipefail

# Qt Component Framework Setup Script
# Unterstützt macOS (inkl. M1), Linux und Windows (via Git Bash)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[ERFOLG]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNUNG]${NC} $1"; }
log_error() { echo -e "${RED}[FEHLER]${NC} $1"; }

detect_platform() {
    case "$(uname -s)" in
        Darwin*)    PLATFORM="macos" ;;
        Linux*)     PLATFORM="linux" ;;
        MINGW*|CYGWIN*|MSYS*) PLATFORM="windows" ;;
        *)          PLATFORM="unknown" ;;
    esac

    if [[ "$PLATFORM" == "macos" ]] && [[ "$(uname -m)" == "arm64" ]]; then
        PLATFORM="macos_m1"
    fi

    log_info "Erkannte Plattform: $PLATFORM"
}

create_project_structure() {
    log_info "Erstelle Projektstruktur..."

    # Hauptverzeichnisse - wichtig: erst alle Verzeichnisse erstellen!
    mkdir -p "$PROJECT_ROOT/src/qt_components/core"
    mkdir -p "$PROJECT_ROOT/src/qt_components/components"
    mkdir -p "$PROJECT_ROOT/src/qt_components/utils"
    mkdir -p "$PROJECT_ROOT/src/qt_components/styles"
    mkdir -p "$PROJECT_ROOT/src/qt_components/config"
    mkdir -p "$PROJECT_ROOT/src/qt_components/examples/basic_app"
    mkdir -p "$PROJECT_ROOT/src/qt_components/examples/todo_app"
    mkdir -p "$PROJECT_ROOT/src/qt_components/examples/dashboard"
    mkdir -p "$PROJECT_ROOT/.configs/fonts"
    mkdir -p "$PROJECT_ROOT/.configs/icons/mappings"
    mkdir -p "$PROJECT_ROOT/tests/test_components"
    mkdir -p "$PROJECT_ROOT/tests/test_reactive"
    mkdir -p "$PROJECT_ROOT/tests/fixtures"
    mkdir -p "$PROJECT_ROOT/docs"
    mkdir -p "$PROJECT_ROOT/logs"

    # __init__.py Dateien erstellen
    find "$PROJECT_ROOT/src" -type d -exec touch {}/__init__.py \;
    find "$PROJECT_ROOT/tests" -type d -exec touch {}/__init__.py \;

    # .gitignore
    cat > "$PROJECT_ROOT/.gitignore" << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
.venv/
venv/
ENV/
env/
*.egg-info/
dist/
build/

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# Project specific
.configs/fonts/*.ttf
.configs/fonts/*.otf
logs/
*.log
.DS_Store

# Testing
.pytest_cache/
.coverage
htmlcov/
.mypy_cache/
.ruff_cache/

# Poetry
poetry.lock
EOF

    log_success "Projektstruktur erstellt"
}

check_python_version() {
    log_info "Prüfe Python-Version..."

    # Suche nach Python 3.11 oder 3.12 (NICHT 3.13+ wegen PySide6)
    for python_cmd in python3.12 python3.11 python3 python; do
        if command -v $python_cmd &> /dev/null; then
            version=$($python_cmd --version 2>&1 | awk '{print $2}')
            major=$(echo $version | cut -d. -f1)
            minor=$(echo $version | cut -d. -f2)

            if [[ $major -eq 3 ]] && [[ $minor -ge 11 ]] && [[ $minor -le 12 ]]; then
                PYTHON_CMD=$python_cmd
                log_success "Verwende $PYTHON_CMD (Version $version)"
                return 0
            fi
        fi
    done

    log_error "Python 3.11 oder 3.12 nicht gefunden!"
    log_info "PySide6 unterstützt nur Python 3.11 und 3.12"
    log_info "Bitte installiere Python 3.12:"
    log_info "  macOS: brew install python@3.12"
    log_info "  Linux: sudo apt install python3.12"
    exit 1
}

create_virtual_env() {
    log_info "Erstelle virtuelle Umgebung..."

    if [[ -d "$PROJECT_ROOT/.venv" ]]; then
        log_warning "Virtuelle Umgebung existiert bereits"
        log_info "Lösche alte venv und erstelle neu..."
        rm -rf "$PROJECT_ROOT/.venv"
    fi

    $PYTHON_CMD -m venv "$PROJECT_ROOT/.venv"
    log_success "Virtuelle Umgebung erstellt"

    # Aktiviere venv für dieses Script
    source "$PROJECT_ROOT/.venv/bin/activate"

    # Upgrade pip
    python -m pip install --upgrade pip
}

create_pyproject_toml() {
    log_info "Erstelle pyproject.toml..."

    cat > "$PROJECT_ROOT/pyproject.toml" << 'EOF'
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "qt-component-framework"
version = "0.1.0"
description = "Ein Svelte-inspiriertes reaktives Component-Framework für Qt-Anwendungen"
authors = [{name = "Dein Name", email = "deine.email@example.com"}]
license = {text = "MIT"}
readme = "README.md"
requires-python = ">=3.11,<3.13"
dependencies = [
    "PySide6>=6.6.0",
    "qtawesome>=1.3.0",
    "loguru>=0.7.0",
    "pydantic>=2.5.0",
    "typing-extensions>=4.8.0",
    "requests>=2.31.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "pytest-qt>=4.2.0",
    "black>=23.0.0",
    "ruff>=0.1.0",
    "mypy>=1.7.0",
    "pre-commit>=3.5.0",
]

[tool.setuptools.packages.find]
where = ["src"]

[tool.black]
line-length = 88
target-version = ['py311']

[tool.ruff]
line-length = 88
target-version = "py311"
select = ["E", "F", "I", "N", "W"]

[tool.mypy]
python_version = "3.11"
strict = true
ignore_missing_imports = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
EOF

    # Erstelle auch requirements.txt für einfachere Installation
    cat > "$PROJECT_ROOT/requirements.txt" << 'EOF'
# Core dependencies
PySide6>=6.6.0
qtawesome>=1.3.0
loguru>=0.7.0
pydantic>=2.5.0
typing-extensions>=4.8.0
requests>=2.31.0

# Development dependencies
pytest>=7.4.0
pytest-qt>=4.2.0
black>=23.0.0
ruff>=0.1.0
mypy>=1.7.0
EOF

    log_success "pyproject.toml und requirements.txt erstellt"
}

create_core_files() {
    log_info "Erstelle Core-Framework-Dateien..."

    # core/component.py
    cat > "$PROJECT_ROOT/src/qt_components/core/component.py" << 'EOF'
"""
Basis-Component-Klasse mit Svelte-inspirierter Reaktivität.

Diese Datei sollte enthalten:
- ReactiveState Klasse für Zustandsverwaltung
- BaseComponent Klasse als Basis für alle Komponenten
- Lifecycle-Methoden: on_mount(), on_destroy(), update()
- Props-System für Datenübergabe
- JSON-Styling-Integration
"""
# Implementation wird hier eingefügt
from PySide6.QtWidgets import QWidget

class BaseComponent(QWidget):
    """Platzhalter für BaseComponent"""
    pass
EOF

    # core/reactive.py
    cat > "$PROJECT_ROOT/src/qt_components/core/reactive.py" << 'EOF'
"""
Reaktives State-Management-System.

Diese Datei sollte enthalten:
- Observable/Observer Pattern Implementation
- State-Subscriptions mit Callbacks
- Computed Properties (abgeleitete Zustände)
- State-History für Undo/Redo
"""
# Implementation wird hier eingefügt
EOF

    # utils/icon_manager.py
    cat > "$PROJECT_ROOT/src/qt_components/utils/icon_manager.py" << 'EOF'
"""
Icon-Font-Verwaltung mit Material Design Icons Support.

Diese Datei sollte enthalten:
- IconManager Singleton-Klasse
- Font-Loading aus .configs/fonts
- Icon-Caching für Performance
- Unterstützung für Font Awesome und Material Design Icons
- Fallback-Mechanismen bei fehlenden Icons
"""
# Implementation wird hier eingefügt
class IconManager:
    """Platzhalter für IconManager"""
    _instance = None

    @classmethod
    def instance(cls):
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance
EOF

    # styles/style_manager.py
    cat > "$PROJECT_ROOT/src/qt_components/styles/style_manager.py" << 'EOF'
"""
JSON-basiertes Style-Management-System.

Diese Datei sollte enthalten:
- StyleManager Singleton-Klasse
- JSON zu QSS Konvertierung
- Design-Token-Auflösung ({colors.primary})
- Theme-Verwaltung und -Wechsel
- State-basiertes Styling (hover, pressed, disabled)
- Performance-Optimierung durch Caching
"""
# Implementation wird hier eingefügt
class StyleManager:
    """Platzhalter für StyleManager"""
    _instance = None

    @classmethod
    def instance(cls):
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance
EOF

    # components/button.py
    cat > "$PROJECT_ROOT/src/qt_components/components/button.py" << 'EOF'
"""
Moderne Button-Komponente mit reaktivem State.

Diese Datei sollte enthalten:
- Button-Klasse erbt von BaseComponent
- Props: text, icon, variant, size, loading
- Varianten: primary, secondary, ghost, danger
- Größen: sm, md, lg
- Loading-State mit Animation
- Icon-Integration
"""
# Implementation wird hier eingefügt
from ..core.component import BaseComponent

class Button(BaseComponent):
    """Platzhalter für Button"""
    pass
EOF

    # components/input.py
    cat > "$PROJECT_ROOT/src/qt_components/components/input.py" << 'EOF'
"""
Input-Komponente mit Validierung.

Diese Datei sollte enthalten:
- TextInput-Klasse mit reaktiver Validierung
- Props: placeholder, type, validator, icon
- Echtzeit-Validierung mit Fehlermeldungen
- Icon-Support (links/rechts)
- Verschiedene Input-Typen (text, password, email, number)
"""
# Implementation wird hier eingefügt
EOF

    # components/card.py
    cat > "$PROJECT_ROOT/src/qt_components/components/card.py" << 'EOF'
"""
Card-Komponente für Container-Layouts.

Diese Datei sollte enthalten:
- Card-Klasse mit flexiblem Layout
- Props: title, subtitle, actions, elevation
- Shadow/Elevation-Support
- Header/Body/Footer Bereiche
- Responsive Padding
"""
# Implementation wird hier eingefügt
EOF

    # config/settings.py
    cat > "$PROJECT_ROOT/src/qt_components/config/settings.py" << 'EOF'
"""
Globale Framework-Einstellungen.

Diese Datei sollte enthalten:
- Framework-Konfiguration
- Standard-Pfade (.configs, logs)
- Debug-Einstellungen
- Performance-Optionen
- Platform-spezifische Anpassungen
"""
# Implementation wird hier eingefügt
EOF

    log_success "Core-Dateien erstellt"
}

create_example_files() {
    log_info "Erstelle Beispiel-Anwendungen..."

    # examples/demo.py
    cat > "$PROJECT_ROOT/src/qt_components/examples/demo.py" << 'EOF'
"""
Demo-Anwendung zur Präsentation der Framework-Komponenten.
"""
import sys
from PySide6.QtWidgets import QApplication, QMainWindow, QLabel, QVBoxLayout, QWidget
from PySide6.QtCore import Qt

class DemoWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Qt Component Framework Demo")
        self.setGeometry(100, 100, 800, 600)

        # Central widget
        central_widget = QWidget()
        layout = QVBoxLayout()

        # Demo label
        label = QLabel("Qt Component Framework - Demo läuft!")
        label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        label.setStyleSheet("font-size: 24px; padding: 20px;")
        layout.addWidget(label)

        central_widget.setLayout(layout)
        self.setCentralWidget(central_widget)

def main():
    app = QApplication(sys.argv)
    window = DemoWindow()
    window.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
EOF

    # examples/basic_app/main.py
    cat > "$PROJECT_ROOT/src/qt_components/examples/basic_app/main.py" << 'EOF'
"""
Einfache Beispielanwendung.
"""
# Implementation wird hier eingefügt
EOF

    # examples/todo_app/main.py
    cat > "$PROJECT_ROOT/src/qt_components/examples/todo_app/main.py" << 'EOF'
"""
Todo-Listen-Anwendung als komplexeres Beispiel.
"""
# Implementation wird hier eingefügt
EOF

    log_success "Beispiel-Anwendungen erstellt"
}

create_test_files() {
    log_info "Erstelle Test-Dateien..."

    # tests/test_components/test_button.py
    cat > "$PROJECT_ROOT/tests/test_components/test_button.py" << 'EOF'
"""
Tests für Button-Komponente.
"""
def test_placeholder():
    """Platzhalter-Test"""
    assert True
EOF

    # tests/test_reactive/test_state.py
    cat > "$PROJECT_ROOT/tests/test_reactive/test_state.py" << 'EOF'
"""
Tests für reaktives State-System.
"""
def test_placeholder():
    """Platzhalter-Test"""
    assert True
EOF

    log_success "Test-Dateien erstellt"
}

create_style_files() {
    log_info "Erstelle Style-Dateien..."

    # styles/default_theme.json
    cat > "$PROJECT_ROOT/src/qt_components/styles/default_theme.json" << 'EOF'
{
  "themes": {
    "default": {
      "colors": {
        "primary": "#007ACC",
        "background": "#FFFFFF",
        "text": "#323130"
      }
    }
  },
  "components": {}
}
EOF

    # styles/dark_theme.json
    cat > "$PROJECT_ROOT/src/qt_components/styles/dark_theme.json" << 'EOF'
{
  "themes": {
    "dark": {
      "colors": {
        "primary": "#2D7FF9",
        "background": "#0D1117",
        "text": "#F0F6FC"
      }
    }
  },
  "components": {}
}
EOF

    log_success "Style-Dateien erstellt"
}

download_icon_fonts() {
    log_info "Lade Icon-Fonts herunter..."

    FONT_DIR="$PROJECT_ROOT/.configs/fonts"
    mkdir -p "$FONT_DIR"

    # Material Design Icons
    MDI_URL="https://github.com/Templarian/MaterialDesign-Webfont/raw/master/fonts/materialdesignicons-webfont.ttf"
    if curl -L "$MDI_URL" -o "$FONT_DIR/material-design-icons.ttf" 2>/dev/null; then
        log_success "Material Design Icons heruntergeladen"
    else
        log_warning "Konnte Material Design Icons nicht herunterladen"
    fi

    # Font Awesome (Free Version)
    FA_URL="https://github.com/FortAwesome/Font-Awesome/raw/6.x/webfonts/fa-solid-900.ttf"
    if curl -L "$FA_URL" -o "$FONT_DIR/font-awesome-solid.ttf" 2>/dev/null; then
        log_success "Font Awesome heruntergeladen"
    else
        log_warning "Konnte Font Awesome nicht herunterladen"
    fi
}

install_dependencies() {
    log_info "Installiere Abhängigkeiten..."

    cd "$PROJECT_ROOT"

    # Verwende pip direkt (zuverlässiger als Poetry)
    log_info "Installiere Python-Pakete mit pip..."
    pip install -r requirements.txt

    # Prüfe Installation
    if python -c "import PySide6; print('PySide6 Version:', PySide6.__version__)" 2>/dev/null; then
        log_success "Abhängigkeiten installiert"
    else
        log_error "Installation fehlgeschlagen!"
        log_info "Versuche manuell:"
        log_info "  pip install PySide6"
        exit 1
    fi
}

create_start_script() {
    log_info "Erstelle start.sh..."

    cat > "$PROJECT_ROOT/start.sh" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Prüfe ob .venv existiert
if [[ ! -d ".venv" ]]; then
    echo "Virtuelle Umgebung nicht gefunden. Bitte zuerst ./setup.sh ausführen."
    exit 1
fi

# Aktiviere venv
source .venv/bin/activate

# Stelle sicher dass PYTHONPATH gesetzt ist
export PYTHONPATH="${PYTHONPATH:-}:${SCRIPT_DIR}/src"

# Kommando parsen
case "${1:-demo}" in
    "demo")
        echo "Starte Demo-Anwendung..."
        python -m qt_components.examples.demo
        ;;
    "test")
        echo "Führe Tests aus..."
        pytest -v
        ;;
    "lint")
        echo "Führe Linter aus..."
        black src/ tests/
        ruff check src/ tests/
        mypy src/ --ignore-missing-imports
        ;;
    "dev")
        echo "Starte Entwicklungsmodus..."
        python -m qt_components.examples.demo --dev
        ;;
    "clean")
        echo "Räume auf..."
        find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
        find . -type f -name "*.pyc" -delete
        rm -rf .pytest_cache .mypy_cache .ruff_cache
        ;;
    *)
        echo "Verwendung: ./start.sh [demo|test|lint|dev|clean]"
        echo ""
        echo "Befehle:"
        echo "  demo  - Startet die Demo-Anwendung"
        echo "  test  - Führt alle Tests aus"
        echo "  lint  - Führt Code-Linting aus"
        echo "  dev   - Startet im Entwicklungsmodus"
        echo "  clean - Löscht temporäre Dateien"
        exit 1
        ;;
esac
EOF

    chmod +x "$PROJECT_ROOT/start.sh"
    log_success "start.sh erstellt"
}

create_readme() {
    log_info "Erstelle README.md..."

    cat > "$PROJECT_ROOT/README.md" << 'EOF'
# Qt Component Framework

Ein modernes, reaktives Component-Framework für Qt-Anwendungen in Python.

## Voraussetzungen

- Python 3.11 oder 3.12 (NICHT 3.13+ wegen PySide6)
- macOS, Linux oder Windows

## Installation

```bash
# Setup ausführen
./setup.sh

# Bei Problemen mit Poetry, direkt pip verwenden:
source .venv/bin/activate
pip install -r requirements.txt
```

## Verwendung

```bash
# Demo starten
./start.sh demo

# Tests ausführen
./start.sh test

# Entwicklungsmodus
./start.sh dev
```

## Bekannte Probleme

- PySide6 unterstützt nur Python 3.11 und 3.12
- Auf macOS: Homebrew Python verwenden, nicht System-Python

## Dokumentation

Siehe `docs/` Verzeichnis für vollständige Dokumentation.
EOF

    log_success "README.md erstellt"
}

main() {
    log_info "Qt Component Framework Setup"
    log_info "=============================="

    detect_platform
    check_python_version
    create_project_structure
    create_virtual_env
    create_pyproject_toml
    create_core_files
    create_example_files
    create_test_files
    create_style_files
    download_icon_fonts
    install_dependencies
    create_start_script
    create_readme

    log_success "Setup abgeschlossen!"
    echo ""
    echo "Nächste Schritte:"
    echo "  1. Aktiviere die virtuelle Umgebung:"
    echo "     source .venv/bin/activate"
    echo "  2. Starte die Demo:"
    echo "     ./start.sh demo"
    echo ""
    echo "Bei Problemen siehe README.md"
    echo ""
    echo "Viel Spaß beim Entwickeln! 🚀"
}

# Script-Argumente verarbeiten
case "${1:-}" in
    "-h"|"--help")
        echo "Qt Component Framework Setup Script"
        echo ""
        echo "Verwendung: ./setup.sh [OPTION]"
        echo ""
        echo "Dieses Script:"
        echo "  - Erstellt die Projektstruktur"
        echo "  - Installiert Abhängigkeiten"
        echo "  - Lädt Icon-Fonts herunter"
        echo "  - Erstellt Beispiel-Komponenten"
        echo ""
        echo "Voraussetzungen:"
        echo "  - Python 3.11 oder 3.12"
        echo "  - curl (für Font-Downloads)"
        echo "  - Internetverbindung"
        echo ""
        echo "Optionen:"
        echo "  -h, --help    Diese Hilfe anzeigen"
        exit 0
        ;;
    *)
        main
        ;;
esac