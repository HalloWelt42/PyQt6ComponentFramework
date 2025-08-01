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
