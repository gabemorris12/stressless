# A module for the bar configuration window
from PyQt6.QtCore import QRegularExpression
from PyQt6.QtGui import QDoubleValidator, QRegularExpressionValidator
from PyQt6.QtWidgets import QDialog, QVBoxLayout, QLabel, QLineEdit, QPushButton, QHBoxLayout, QWidget
import numpy as np

# Changing these constants is not advised
ATTRIBUTES = [
    'tag',  # if this changes, then be sure to adjust the validator below
    'gauge_factor',
    'sampling_frequency',
    'modulus',
    'density',
    'wave_speed',
    'diameter'
]

LABELS = [
    'Tag',
    'Gauge Factor',
    'Sampling Frequency',
    'Modulus',
    'Density',
    'Wave Speed',
    'Diameter'
]

UNITS = [
    '',
    'ε/V',
    'MHz',
    'MPa',
    'kg/m³',
    'm/s',
    'mm'
]


class BarConfigWindow(QDialog):
    def __init__(self, parent=None, bar_dict=None):
        super().__init__(parent)
        self.setWindowTitle("Bar Configuration")
        # self.setFixedSize(300, 200)
        self._setup_ui(bar_dict)

    def _setup_ui(self, bar_dict):
        layout = QVBoxLayout(self)
        self.bar = {}

        for attr, label, unit in zip(ATTRIBUTES, LABELS, UNITS):
            label = label + f' ({unit})' if unit else label
            label = QLabel(label, self)
            layout.addWidget(label)

            line = QLineEdit(self)
            if attr == 'tag':
                regex = QRegularExpression(r'^[A-Za-z]+$')
                validator = QRegularExpressionValidator(regex, line)
            else:
                validator = QDoubleValidator(line)

            line.setValidator(validator)
            layout.addWidget(line)
            self.bar[attr] = line

        # Add ok and cancel
        buttons_widget = QWidget(self)
        button_layout = QHBoxLayout(buttons_widget)
        ok_button = QPushButton("Ok", buttons_widget)
        ok_button.clicked.connect(self.accept)
        button_layout.addWidget(ok_button)
        cancel_button = QPushButton("Cancel", buttons_widget)
        cancel_button.clicked.connect(self.reject)
        button_layout.addWidget(cancel_button)
        buttons_widget.setLayout(button_layout)
        layout.addWidget(buttons_widget)

        self.bar['wave_speed'].editingFinished.connect(self._wave_speed_continuity)
        self.bar['density'].editingFinished.connect(self._wave_speed_continuity)
        self.bar['modulus'].editingFinished.connect(self._wave_speed_continuity)

        self.adjustSize()
        self.setFixedSize(self.size())

        if bar_dict is not None:
            self.bar['tag'].setEnabled(False)
            for key, value in bar_dict.items():
                if key not in ('wave_speed', 'density', 'modulus'):
                    self.bar[key].setText(str(value))

    def validate(self):
        values = [line_edit.text() for line_edit in self.bar.values()]
        if not all(values):
            raise ValueError("All fields must be filled.")

        bar_dict = {'tag': self.bar_dict()['tag']}
        bar_dict.update({key: float(value) for key, value in self.bar_dict().items() if key != 'tag'})
        return bar_dict

    def bar_dict(self) -> dict:
        """
        Returns a dictionary of all entered values.
        """
        return {key: widget.text() for key, widget in self.bar.items()}

    def _wave_speed_continuity(self):
        """
        The wave speed is the sqrt(E/rho). The callback ensures that this relationship remains true as the user is
        filling in the fields.
        """
        params = ['wave_speed', 'density', 'modulus']
        values = wave_speed, density, modulus = [
            self.bar_dict()[attr] for attr in params
        ]
        bools = [bool(value) for value in values]

        if bools.count(True) == 2:
            # Find the one that's not filled and deactivate it
            not_filled = bools.index(False)
            attr = params[not_filled]

            # Calculate the value
            if attr == 'wave_speed':
                wave_speed = np.sqrt(float(modulus)*10**6/float(density))
                self.bar[attr].setText(str(wave_speed))
            elif attr == 'density':
                density = float(modulus)*10**6/float(wave_speed)**2
                self.bar[attr].setText(str(density))
            else:
                modulus = float(wave_speed)**2*float(density)/10**6
                self.bar[attr].setText(str(modulus))

            # Deactivate them all
            for attr in params:
                self.bar[attr].setEnabled(False)


if __name__ == '__main__':
    from PyQt6.QtWidgets import QApplication
    import sys

    app = QApplication(sys.argv)
    window = BarConfigWindow()
    window.show()
    sys.exit(app.exec())
