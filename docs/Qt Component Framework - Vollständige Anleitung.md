# Qt Component Framework - Vollständige Anleitung

Ein modernes, reaktives Component-Framework für Qt-Anwendungen in Python, inspiriert von Svelte's Einfachheit und Reaktivitätsmodell.

## Inhaltsverzeichnis

1. [Überblick](#überblick)
2. [Systemanforderungen](#systemanforderungen)
3. [Installation für neues PyCharm-Projekt](#installation-für-neues-pycharm-projekt)
4. [Framework-Architektur](#framework-architektur)
5. [Arbeitsweise und Workflow](#arbeitsweise-und-workflow)
6. [Komponenten-Entwicklung](#komponenten-entwicklung)
7. [Styling mit JSON](#styling-mit-json)
8. [Icon-System](#icon-system)
9. [Beispiele](#beispiele)
10. [Best Practices](#best-practices)
11. [Fehlerbehebung](#fehlerbehebung)

## Überblick

### Was ist das Qt Component Framework?

Ein Python-Framework, das die Entwicklung von Qt-Anwendungen revolutioniert durch:

- **Svelte-inspirierte Reaktivität**: Automatische UI-Updates bei State-Änderungen
- **JSON-basiertes Styling**: Überwindet Qt Style Sheet Limitierungen
- **Material Design Icons**: 6,997 Icons out-of-the-box
- **Component-First Architektur**: Wiederverwendbare UI-Bausteine
- **M1 Mac optimiert**: Native Performance auf Apple Silicon

### Warum dieses Framework?

- **Einfacher als Pure Qt**: Weniger Boilerplate, mehr Produktivität
- **Moderner als traditionelle Ansätze**: Reaktive Patterns aus dem Web
- **Flexibler als Qt Designer**: Programmatische UI mit voller Kontrolle
- **Performanter durch Caching**: Optimiert für große Anwendungen

## Systemanforderungen

- **Python**: 3.11 oder höher
- **Betriebssystem**: macOS (inkl. M1/M2), Linux, Windows
- **Speicher**: Mind. 4 GB RAM empfohlen
- **Speicherplatz**: ~500 MB für Framework + Dependencies

### Spezielle M1 Mac Hinweise

Das Framework ist speziell für Apple Silicon optimiert:
- Nutzt native ARM64 Builds von PySide6
- Hardware-beschleunigte Rendering
- Optimiert für Retina-Displays

## Installation für neues PyCharm-Projekt

### Schritt 1: Neues PyCharm-Projekt erstellen

1. Öffne PyCharm
2. "File" → "New Project"
3. Wähle Projektort: `/Users/deinname/projekte/meine-qt-app`
4. Python Interpreter: 
   - Wähle "New environment using Virtualenv"
   - Base interpreter: Python 3.11+
5. Klicke "Create"

### Schritt 2: Setup-Script vorbereiten

1. Erstelle im Projekt-Root eine neue Datei: `setup.sh`
2. Kopiere den Inhalt des Setup-Scripts (siehe oben)
3. Mache das Script ausführbar:
   ```bash
   chmod +x setup.sh
   ```

### Schritt 3: Framework installieren

Im PyCharm Terminal:

```bash
# Setup ausführen
./setup.sh

# Warte bis Installation abgeschlossen ist (ca. 2-5 Minuten)
```

### Schritt 4: PyCharm konfigurieren

1. **Interpreter konfigurieren**:
   - "PyCharm" → "Preferences" → "Project" → "Python Interpreter"
   - Wähle den `.venv` Interpreter im Projekt
   
2. **Quellverzeichnis markieren**:
   - Rechtsklick auf `src` Ordner
   - "Mark Directory as" → "Sources Root"
   
3. **Run Configuration erstellen**:
   - Oben rechts: "Add Configuration"
   - "+" → "Python"
   - Name: "Demo App"
   - Script path: Wähle `start.sh`
   - Parameters: `demo`
   - Working directory: Projekt-Root

### Schritt 5: Erste Anwendung starten

```bash
# Demo starten
./start.sh demo

# Oder in PyCharm: Klicke auf grünen Play-Button
```

## Framework-Architektur

### Verzeichnisstruktur

```
meine-qt-app/
├── .venv/                    # Virtuelle Umgebung
├── .configs/                 # Konfiguration und Ressourcen
│   ├── fonts/               # Icon-Fonts (automatisch heruntergeladen)
│   └── icons/               # Custom Icons und Mappings
├── src/
│   └── qt_components/       # Framework-Code
│       ├── core/           # Basis-Klassen
│       │   ├── component.py    # BaseComponent Klasse
│       │   └── reactive.py     # State Management
│       ├── components/     # UI-Komponenten
│       │   ├── button.py      # Button-Komponente
│       │   ├── input.py       # Input-Komponente
│       │   └── ...
│       ├── styles/         # Styling-System
│       │   ├── style_manager.py
│       │   └── themes/        # JSON Theme-Dateien
│       ├── utils/          # Hilfsfunktionen
│       │   └── icon_manager.py
│       └── examples/       # Beispiel-Anwendungen
├── tests/                  # Unit Tests
├── docs/                   # Dokumentation
├── pyproject.toml         # Projekt-Konfiguration
├── setup.sh               # Setup-Script
└── start.sh              # Start-Script
```

### Kern-Komponenten

1. **BaseComponent**: Basis-Klasse für alle UI-Komponenten
2. **ReactiveState**: Svelte-ähnliche State-Verwaltung
3. **StyleManager**: JSON-zu-QSS Konvertierung
4. **IconManager**: Icon-Font-Verwaltung

## Arbeitsweise und Workflow

### Entwicklungs-Workflow

1. **Komponente erstellen**:
   ```python
   # src/qt_components/components/my_component.py
   from ..core.component import BaseComponent
   
   class MyComponent(BaseComponent):
       def setup_ui(self):
           # UI erstellen
           pass
   ```

2. **Im Dev-Modus testen**:
   ```bash
   ./start.sh dev  # Hot-Reload aktiviert
   ```

3. **Tests schreiben**:
   ```python
   # tests/test_components/test_my_component.py
   def test_my_component():
       component = MyComponent()
       assert component is not None
   ```

4. **Tests ausführen**:
   ```bash
   ./start.sh test
   ```

### Täglicher Workflow

```bash
# Morgens: Projekt öffnen und Updates holen
git pull
./start.sh update

# Entwicklung starten
./start.sh dev

# Vor Commit: Code formatieren und prüfen
./start.sh lint

# Tests ausführen
./start.sh test

# Am Ende: Aufräumen
./start.sh clean
```

## Komponenten-Entwicklung

### Anatomie einer Komponente

```python
from PySide6.QtWidgets import QLabel, QVBoxLayout
from ..core.component import BaseComponent

class Counter(BaseComponent):
    """Ein einfacher Zähler mit Svelte-ähnlicher Reaktivität."""
    
    def setup_props(self):
        """Definiere Props (Eingabe-Parameter)."""
        self.initial_value = self.props.get('initial', 0)
        self.step = self.props.get('step', 1)
    
    def setup_state(self):
        """Definiere reaktiven State."""
        # State initialisieren
        self.state['count'] = self.initial_value
        
        # Auf State-Änderungen reagieren
        self.state.subscribe('count', self._on_count_change)
    
    def setup_computed(self):
        """Definiere berechnete Properties."""
        # Doppelter Wert wird automatisch aktualisiert
        self.state.computed('double_count', 
            lambda: self.state['count'] * 2)
    
    def setup_ui(self):
        """Erstelle die UI."""
        layout = QVBoxLayout(self)
        
        # Anzeige
        self.label = QLabel(f"Count: {self.state['count']}")
        layout.addWidget(self.label)
        
        # Buttons
        btn_inc = Button(text="+", icon="fa.plus")
        btn_inc.clicked.connect(self.increment)
        layout.addWidget(btn_inc)
        
        btn_dec = Button(text="-", icon="fa.minus")
        btn_dec.clicked.connect(self.decrement)
        layout.addWidget(btn_dec)
    
    def increment(self):
        """Erhöhe Zähler."""
        self.state['count'] += self.step
    
    def decrement(self):
        """Verringere Zähler."""
        self.state['count'] -= self.step
    
    def _on_count_change(self, new_value, old_value):
        """Reagiere auf Count-Änderungen."""
        self.label.setText(f"Count: {new_value}")
        
        # Emittiere Event für Parent-Komponenten
        if new_value > 10:
            self.emit_state_change('high_count', True)
```

### Lifecycle-Methoden

```python
class MyComponent(BaseComponent):
    def on_mount(self):
        """Wird aufgerufen wenn Komponente angezeigt wird."""
        print("Komponente gemountet")
        # Starte Timer, lade Daten, etc.
    
    def on_unmount(self):
        """Wird aufgerufen wenn Komponente versteckt wird."""
        print("Komponente unmountet")
        # Pausiere Updates
    
    def on_destroy(self):
        """Wird aufgerufen wenn Komponente zerstört wird."""
        print("Komponente zerstört")
        # Cleanup: Timer stoppen, Connections trennen
    
    def before_update(self):
        """Wird vor jedem UI-Update aufgerufen."""
        pass
    
    def after_update(self):
        """Wird nach jedem UI-Update aufgerufen."""
        pass
```

### Props vs State

**Props**: Eingabe-Parameter von außen
```python
# Erstelle Komponente mit Props
button = Button(
    text="Klick mich",
    variant="primary",
    size="lg"
)

# Props später ändern
button.set_props(text="Neuer Text")
```

**State**: Interner Zustand der Komponente
```python
# In der Komponente
self.state['loading'] = True

# State von außen lesen (nicht empfohlen)
is_loading = button.state['loading']
```

## Styling mit JSON

### Theme-Struktur

```json
{
  "themes": {
    "default": {
      "colors": {
        "primary": "#007ACC",
        "background": "#FFFFFF",
        "text": "#323130"
      },
      "spacing": {
        "sm": 8,
        "md": 16,
        "lg": 24
      }
    }
  },
  "components": {
    "QPushButton": {
      "default": {
        "backgroundColor": "{colors.primary}",
        "color": "white",
        "padding": "{spacing.md}px",
        "borderRadius": "4px"
      },
      "variants": {
        "secondary": {
          "backgroundColor": "transparent",
          "border": "2px solid {colors.primary}"
        }
      }
    }
  }
}
```

### Theme laden und wechseln

```python
from qt_components.styles.style_manager import StyleManager

# Theme laden
style_manager = StyleManager.instance()
style_manager.load_theme('src/qt_components/styles/my_theme.json')

# Theme zur Laufzeit wechseln
style_manager.set_theme('dark')

# Einzelne Tokens ändern
style_manager.set_token('colors.primary', '#FF0000')
```

### Komponenten-spezifisches Styling

```python
class MyButton(BaseComponent):
    def on_mount(self):
        # Registriere custom Styles
        StyleManager.instance().register_component_styles(
            'MyButton',
            {
                'default': {
                    'backgroundColor': 'linear-gradient(...)' 
                },
                'states': {
                    'hover': {
                        'transform': 'scale(1.05)'
                    }
                }
            }
        )
```

## Icon-System

### Icon verwenden

```python
# Font Awesome
button = Button(text="Home", icon="fa.home")

# Material Design Icons  
button = Button(text="Account", icon="mdi.account")

# Aliases
button = Button(text="Einstellungen", icon="settings")
```

### Verfügbare Icons erkunden

```python
from qt_components.utils.icon_manager import IconManager

manager = IconManager.instance()

# Alle Icons auflisten
all_icons = manager.get_available_icons()

# Nach Präfix filtern
fa_icons = manager.get_available_icons('fa')
mdi_icons = manager.get_available_icons('mdi')
```

### Custom Icons registrieren

```python
# SVG Icon
manager.register_custom_icon('my-logo', 'assets/logo.svg')

# PNG Icon
manager.register_custom_icon('my-avatar', 'assets/avatar.png')

# Verwenden
button = Button(icon="my-logo")
```

## Beispiele

### Beispiel 1: Todo-Liste

```python
from qt_components.core.component import BaseComponent
from qt_components.components.button import Button
from qt_components.components.input import TextInput
from PySide6.QtWidgets import QVBoxLayout, QHBoxLayout, QListWidget

class TodoApp(BaseComponent):
    def setup_state(self):
        self.state['todos'] = []
        self.state['input_text'] = ''
    
    def setup_ui(self):
        layout = QVBoxLayout(self)
        
        # Eingabe
        input_layout = QHBoxLayout()
        
        self.input = TextInput(
            placeholder="Neue Aufgabe...",
            on_change=self.on_input_change
        )
        input_layout.addWidget(self.input)
        
        add_btn = Button(
            text="Hinzufügen",
            icon="fa.plus",
            variant="primary",
            on_click=self.add_todo
        )
        input_layout.addWidget(add_btn)
        
        layout.addLayout(input_layout)
        
        # Liste
        self.list = QListWidget()
        layout.addWidget(self.list)
    
    def on_input_change(self, text):
        self.state['input_text'] = text
    
    def add_todo(self):
        if self.state['input_text']:
            todos = self.state['todos']
            todos.append(self.state['input_text'])
            self.state['todos'] = todos
            
            # UI Update
            self.list.addItem(self.state['input_text'])
            self.input.clear()
            self.state['input_text'] = ''
```

### Beispiel 2: Theme-Switcher

```python
class ThemeSwitcher(BaseComponent):
    def setup_state(self):
        self.state['current_theme'] = 'default'
    
    def setup_ui(self):
        layout = QHBoxLayout(self)
        
        # Theme Buttons
        for theme in ['default', 'dark', 'blue']:
            btn = Button(
                text=theme.capitalize(),
                variant='ghost',
                on_click=lambda t=theme: self.switch_theme(t)
            )
            layout.addWidget(btn)
    
    def switch_theme(self, theme_name):
        self.state['current_theme'] = theme_name
        
        # Theme global ändern
        style_manager = StyleManager.instance()
        style_manager.set_theme(theme_name)
        
        # Alle Komponenten updaten
        QApplication.instance().setStyleSheet("")
        for widget in QApplication.allWidgets():
            if isinstance(widget, BaseComponent):
                widget.request_update()
```

### Beispiel 3: Reaktives Formular

```python
class ContactForm(BaseComponent):
    submitted = Signal(dict)  # Form data
    
    def setup_state(self):
        self.state['form_data'] = {
            'name': '',
            'email': '',
            'message': ''
        }
        self.state['errors'] = {}
        self.state['submitting'] = False
    
    def setup_computed(self):
        # Formular ist valide wenn keine Fehler
        self.state.computed('is_valid', 
            lambda: len(self.state['errors']) == 0)
    
    def setup_ui(self):
        layout = QVBoxLayout(self)
        
        # Name Input
        self.name_input = TextInput(
            placeholder="Ihr Name",
            on_change=lambda v: self.update_field('name', v),
            validator=self.validate_name
        )
        layout.addWidget(self.name_input)
        
        # Email Input
        self.email_input = TextInput(
            placeholder="Ihre E-Mail",
            type="email",
            on_change=lambda v: self.update_field('email', v),
            validator=self.validate_email
        )
        layout.addWidget(self.email_input)
        
        # Message TextArea
        self.message_input = TextArea(
            placeholder="Ihre Nachricht",
            on_change=lambda v: self.update_field('message', v),
            min_length=10
        )
        layout.addWidget(self.message_input)
        
        # Submit Button
        self.submit_btn = Button(
            text="Absenden",
            variant="primary",
            icon="fa.paper-plane",
            on_click=self.submit_form
        )
        self.state.subscribe('submitting', 
            lambda v, _: self.submit_btn.set_loading(v))
        self.state.subscribe('is_valid',
            lambda v, _: self.submit_btn.set_disabled(not v))
        
        layout.addWidget(self.submit_btn)
    
    def update_field(self, field, value):
        form_data = self.state['form_data']
        form_data[field] = value
        self.state['form_data'] = form_data
    
    def validate_name(self, value):
        if len(value) < 2:
            return "Name muss mindestens 2 Zeichen haben"
        return None
    
    def validate_email(self, value):
        if '@' not in value:
            return "Ungültige E-Mail-Adresse"
        return None
    
    def submit_form(self):
        if self.state['is_valid']:
            self.state['submitting'] = True
            
            # Simuliere API-Call
            QTimer.singleShot(2000, lambda: {
                self.state.__setitem__('submitting', False),
                self.submitted.emit(self.state['form_data'])
            })
```

## Best Practices

### 1. Komponenten klein halten

```python
# ❌ Schlecht: Große monolithische Komponente
class AppWindow(BaseComponent):
    def setup_ui(self):
        # 500 Zeilen UI-Code...
        pass

# ✅ Gut: Aufgeteilt in kleine Komponenten
class AppWindow(BaseComponent):
    def setup_ui(self):
        layout = QVBoxLayout(self)
        layout.addWidget(Header())
        layout.addWidget(MainContent())
        layout.addWidget(Footer())
```

### 2. State-Management

```python
# ❌ Schlecht: Direkter State-Zugriff
def update_ui(self):
    self.label.setText(str(self.state._values['count']))

# ✅ Gut: Über Subscriptions
def setup_state(self):
    self.state.subscribe('count', self._update_label)

def _update_label(self, count, _):
    self.label.setText(str(count))
```

### 3. Performance

```python
# ❌ Schlecht: Update bei jeder kleinen Änderung
def on_mouse_move(self, event):
    self.state['mouse_x'] = event.x()
    self.state['mouse_y'] = event.y()

# ✅ Gut: Batch-Updates
def on_mouse_move(self, event):
    self._mouse_pos = (event.x(), event.y())
    self.request_update('mouse_position')
```

### 4. Icon-Usage

```python
# ❌ Schlecht: Icon jedes Mal neu laden
def update_icon(self):
    icon = IconManager.instance().get_icon('fa.home')
    self.button.setIcon(icon)

# ✅ Gut: Icon einmal laden
def setup_ui(self):
    self.home_icon = IconManager.instance().get_icon('fa.home')
    self.button.setIcon(self.home_icon)
```

### 5. Error Handling

```python
# ✅ Gut: Fehler abfangen und User informieren
def load_data(self):
    try:
        data = self.api.fetch_data()
        self.state['data'] = data
    except Exception as e