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
