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
