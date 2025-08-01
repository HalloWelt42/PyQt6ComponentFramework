# Qt Component Framework - Workflow & Arbeitsanleitung

## Schritt-für-Schritt Anleitung für PyCharm

### 1. Projekt-Setup (Einmalig)

#### 1.1 Neues PyCharm-Projekt

1. **PyCharm öffnen**
2. **File → New Project**
3. **Einstellungen**:
   - Location: `/Users/[dein-name]/Projekte/meine-qt-app`
   - Python Interpreter: **New environment using Virtualenv**
   - Base interpreter: **Python 3.11** (oder höher)
   - ✅ **Create a main.py welcome script** (abwählen)

#### 1.2 Setup-Script einrichten

1. **Rechtsklick auf Projekt-Root** → **New** → **File**
2. Name: `setup.sh`
3. **Inhalt des Setup-Scripts einfügen** (von oben)
4. **Terminal öffnen** (unten in PyCharm)
5. Ausführbar machen:
   ```bash
   chmod +x setup.sh
   ```

#### 1.3 Framework installieren

```bash
# Im Terminal
./setup.sh

# Ausgabe beobachten:
# [INFO] Erkannte Plattform: macos_m1
# [INFO] Erstelle Projektstruktur...
# [ERFOLG] Projektstruktur erstellt
# ... (dauert 2-5 Minuten)
# [ERFOLG] Setup abgeschlossen!
```

#### 1.4 PyCharm konfigurieren

1. **Python Interpreter**:
   - **PyCharm → Preferences** (⌘,)
   - **Project: meine-qt-app → Python Interpreter**
   - Zahnrad-Icon → **Add...**
   - **Existing environment**
   - Interpreter: `.../meine-qt-app/.venv/bin/python`
   - **OK**

2. **Source Root markieren**:
   - **Rechtsklick auf `src` Ordner**
   - **Mark Directory as → Sources Root**
   - Ordner wird blau

3. **Run Configuration**:
   - Oben rechts: **Add Configuration...**
   - **+** → **Shell Script**
   - Name: `Demo App`
   - Script path: `./start.sh`
   - Script options: `demo`
   - Working directory: `$ProjectFileDir$`
   - **OK**

### 2. Täglicher Workflow

#### 2.1 Projekt öffnen und vorbereiten

```bash
# 1. Git-Updates holen (falls vorhanden)
git pull

# 2. Dependencies aktualisieren
./start.sh update

# 3. Entwicklungsmodus starten
./start.sh dev
```

#### 2.2 Neue Komponente erstellen

1. **Rechtsklick auf `src/qt_components/components`**
2. **New → Python File**
3. Name: `my_card.py`
4. **Template verwenden**:

```python
"""
Karten-Komponente für Info-Anzeige.

Zeigt Informationen in einer stilvollen Karte an.
"""
from PySide6.QtWidgets import QVBoxLayout, QLabel
from PySide6.QtCore import Signal
from ..core.component import BaseComponent
from ..components.button import Button


class MyCard(BaseComponent):
    """
    Moderne Karten-Komponente.
    
    Props:
        title (str): Kartentitel
        content (str): Karteninhalt
        actions (list): Liste von Actions
    
    Signals:
        action_clicked(str): Wird bei Action-Klick emittiert
    """
    
    action_clicked = Signal(str)
    
    def setup_props(self):
        """Definiere Props."""
        self.title = self.props.get('title', 'Titel')
        self.content = self.props.get('content', '')
        self.actions = self.props.get('actions', [])
    
    def setup_state(self):
        """Definiere State."""
        self.state['expanded'] = False
        self.state['loading'] = False
    
    def setup_ui(self):
        """Erstelle UI."""
        layout = QVBoxLayout(self)
        layout.setContentsMargins(16, 16, 16, 16)
        
        # Titel
        self.title_label = QLabel(self.title)
        self.title_label.setObjectName("card-title")
        layout.addWidget(self.title_label)
        
        # Inhalt
        self.content_label = QLabel(self.content)
        self.content_label.setObjectName("card-content")
        self.content_label.setWordWrap(True)
        layout.addWidget(self.content_label)
        
        # Actions
        if self.actions:
            for action in self.actions:
                btn = Button(
                    text=action['text'],
                    icon=action.get('icon'),
                    variant=action.get('variant', 'ghost')
                )
                btn.clicked.connect(
                    lambda a=action: self.action_clicked.emit(a['name'])
                )
                layout.addWidget(btn)
        
        layout.addStretch()
```

#### 2.3 Komponente in Demo einbinden

1. **Öffne `src/qt_components/examples/demo.py`**
2. **Import hinzufügen**:
   ```python
   from ..components.my_card import MyCard
   ```
3. **Komponente verwenden**:
   ```python
   # In _setup_ui() Methode
   card = MyCard(
       title="Willkommen",
       content="Dies ist eine Demo-Karte",
       actions=[
           {'name': 'ok', 'text': 'OK', 'icon': 'fa.check'},
           {'name': 'cancel', 'text': 'Abbrechen', 'icon': 'fa.times'}
       ]
   )
   card.action_clicked.connect(lambda name: print(f"Action: {name}"))
   layout.addWidget(card)
   ```

#### 2.4 Styling anpassen

1. **Öffne `src/qt_components/styles/default_theme.json`**
2. **Komponenten-Styles hinzufügen**:

```json
"MyCard": {
  "default": {
    "backgroundColor": "{colors.surface}",
    "border": "1px solid {colors.border}",
    "borderRadius": "{borderRadius.lg}",
    "padding": "{spacing.lg}",
    "boxShadow": "{elevation.sm}"
  },
  "#card-title": {
    "fontSize": "{typography.fontSize.lg}",
    "fontWeight": "{typography.fontWeight.bold}",
    "color": "{colors.text}",
    "marginBottom": "{spacing.md}"
  },
  "#card-content": {
    "fontSize": "{typography.fontSize.md}",
    "color": "{colors.textSecondary}",
    "lineHeight": "{typography.lineHeight.relaxed}"
  },
  "states": {
    "hover": {
      "boxShadow": "{elevation.md}",
      "transform": "translateY(-2px)"
    }
  }
}
```

#### 2.5 Tests schreiben

1. **Neue Test-Datei**: `tests/test_components/test_my_card.py`

```python
import pytest
from qt_components.components.my_card import MyCard
from PySide6.QtCore import Qt


@pytest.fixture
def card(qtbot):
    """Card-Komponente für Tests."""
    widget = MyCard(
        title="Test Card",
        content="Test Content",
        actions=[
            {'name': 'test', 'text': 'Test', 'icon': 'fa.check'}
        ]
    )
    qtbot.addWidget(widget)
    return widget


def test_card_creation(card):
    """Test Karten-Erstellung."""
    assert card.title == "Test Card"
    assert card.content == "Test Content"
    assert len(card.actions) == 1


def test_card_action_signal(card, qtbot):
    """Test Action-Click Signal."""
    # Signal-Spy erstellen
    with qtbot.waitSignal(card.action_clicked) as blocker:
        # Finde und klicke Button
        button = card.findChild(Button)
        qtbot.mouseClick(button, Qt.LeftButton)
    
    # Prüfe Signal-Argument
    assert blocker.args[0] == 'test'


def test_card_state_management(card):
    """Test State-Verwaltung."""
    # Initial State
    assert card.state['expanded'] == False
    assert card.state['loading'] == False
    
    # State ändern
    card.state['expanded'] = True
    assert card.state['expanded'] == True
```

2. **Tests ausführen**:
   ```bash
   ./start.sh test
   ```

### 3. Development Best Practices

#### 3.1 Code-Organisation

```
components/
├── base/           # Basis-Komponenten
│   ├── __init__.py
│   └── card.py
├── forms/          # Formular-Komponenten
│   ├── __init__.py
│   ├── input.py
│   └── select.py
├── layout/         # Layout-Komponenten
│   ├── __init__.py
│   ├── grid.py
│   └── stack.py
└── feedback/       # Feedback-Komponenten
    ├── __init__.py
    ├── alert.py
    └── toast.py
```

#### 3.2 Git Workflow

```bash
# Feature-Branch erstellen
git checkout -b feature/neue-komponente

# Änderungen stagen
git add .

# Code prüfen vor Commit
./start.sh lint

# Tests ausführen
./start.sh test

# Commit
git commit -m "feat: Neue Card-Komponente hinzugefügt"

# Push
git push origin feature/neue-komponente
```

#### 3.3 Debugging in PyCharm

1. **Breakpoint setzen**: Klick links neben Zeilennummer
2. **Debug-Modus starten**: 
   - Run Configuration auf `Demo App` 
   - Klick auf Debug-Icon (Käfer)
3. **Debug-Panel nutzen**:
   - Variables: Aktuelle Variablen
   - Watches: Spezifische Ausdrücke
   - Console: Interaktive Python-Console

#### 3.4 Performance-Profiling

```python
# In main.py oder demo.py
if __name__ == "__main__":
    import cProfile
    import pstats
    
    # Profiling aktivieren
    profiler = cProfile.Profile()
    profiler.enable()
    
    # App ausführen
    app = QApplication(sys.argv)
    window = DemoWindow()
    window.show()
    app.exec()
    
    # Profiling beenden
    profiler.disable()
    
    # Ergebnisse ausgeben
    stats = pstats.Stats(profiler)
    stats.sort_stats('cumulative')
    stats.print_stats(20)  # Top 20 Functions
```

### 4. Tipps für effizientes Arbeiten

#### 4.1 PyCharm Shortcuts (macOS)

- **⌘⇧F**: Globale Suche
- **⌘B**: Gehe zu Definition
- **⌘⌥L**: Code formatieren
- **⌘/**: Kommentar toggle
- **⌃Space**: Code-Completion
- **⌘⇧O**: Datei öffnen
- **⌘E**: Letzte Dateien
- **⌘⇧A**: Action suchen

#### 4.2 Live Templates erstellen

1. **PyCharm → Preferences → Editor → Live Templates**
2. **+** → **Template Group** → "Qt Components"
3. **+** → **Live Template**:
   - Abbreviation: `qtcomp`
   - Description: "Qt Component Template"
   - Template text:
   ```python
   class $NAME$(BaseComponent):
       """$DESCRIPTION$"""
       
       def setup_props(self):
           """Props definieren."""
           $END$
       
       def setup_state(self):
           """State definieren."""
           pass
       
       def setup_ui(self):
           """UI erstellen."""
           pass
   ```

#### 4.3 Automatisierung

**Pre-commit Hook** (`.git/hooks/pre-commit`):
```bash
#!/bin/bash
echo "Running pre-commit checks..."

# Linting
./start.sh lint
if [ $? -ne 0 ]; then
    echo "Linting failed. Please fix errors."
    exit 1
fi

# Tests
./start.sh test
if [ $? -ne 0 ]; then
    echo "Tests failed. Please fix."
    exit 1
fi

echo "Pre-commit checks passed!"
```

### 5. Troubleshooting Workflow

#### Problem-Diagnose Checkliste

1. **Import-Fehler?**
   ```bash
   # Python-Path prüfen
   python -c "import sys; print('\n'.join(sys.path))"
   
   # Module prüfen
   python -c "import qt_components; print(qt_components.__file__)"
   ```

2. **UI wird nicht aktualisiert?**
   ```python
   # Debug-Output hinzufügen
   import logging
   logging.basicConfig(level=logging.DEBUG)
   
   # In Komponente
   logger.debug(f"State changed: {self.state._values}")
   ```

3. **Performance-Probleme?**
   ```python
   # Timer für Code-Abschnitte
   import time
   
   start = time.time()
   # ... code ...
   print(f"Execution time: {time.time() - start:.3f}s")
   ```

### 6. Deployment Workflow

#### 6.1 Release vorbereiten

```bash
# Version updaten in pyproject.toml
# version = "0.2.0"

# Changelog updaten
echo "## [0.2.0] - $(date +%Y-%m-%d)" >> CHANGELOG.md
echo "### Added" >> CHANGELOG.md
echo "- Neue Card-Komponente" >> CHANGELOG.md

# Tag erstellen
git tag -a v0.2.0 -m "Release version 0.2.0"
git push origin v0.2.0
```

#### 6.2 Standalone-App erstellen

```bash
# Requirements einfrieren
poetry export -f requirements.txt > requirements.txt

# PyInstaller Spec erstellen
poetry run pyi-makespec \
    --name="MeineQtApp" \
    --windowed \
    --onefile \
    --add-data=".configs:configs" \
    --add-data="src/qt_components:qt_components" \
    src/qt_components/examples/main.py

# Build
poetry run pyinstaller MeineQtApp.spec

# Testen
./dist/MeineQtApp
```

Diese Workflow-Anleitung sollte dir helfen, effizient mit dem Framework zu arbeiten. Bei Fragen schaue in die Hauptdokumentation oder die Beispiele!