import matplotlib.pyplot as plt
import numpy as np
from PyQt6.QtWidgets import QWidget, QVBoxLayout, QPushButton, QHBoxLayout
from PyQt6.QtCore import Qt
from PyQt6 import QtCore
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas

from stressless import HopkinsonExperiment


class ShowSignal(QWidget):
    okClicked = QtCore.pyqtSignal()

    def __init__(self, experiment: HopkinsonExperiment = None, parent=None):
        super().__init__(parent)

        # Plot the signal
        fig, self.ax = plt.subplots()
        index = np.arange(experiment.n_samples)

        self.experiment = experiment
        if experiment.crop_voltage is not None:
            cropped_index = np.arange(experiment.crop_start, experiment.crop_end)
            self.adjusted_incident = self.ax.plot(cropped_index, experiment.incident_wave.crop_voltage,
                                                  label="Adjusted Incident")[0]
            self.adjusted_transmitted = self.ax.plot(cropped_index, experiment.transmitted_wave.crop_voltage,
                                                     label="Adjusted Transmitted")[0]
            self.ax.set_xlim(experiment.crop_start, experiment.crop_end)
            self.ax.relim()
            self.ax.autoscale_view(scalex=False, scaley=True)
        self.original_incident = self.ax.plot(index, experiment.raw_data[:, 0], label="Original Incident",
                                              ls='--')[0]
        self.original_transmitted = self.ax.plot(index, experiment.raw_data[:, 1], label="Original Transmitted",
                                                 ls='--')[0]
        self.ax.legend()
        self.ax.set_xlabel('Index')
        self.ax.set_ylabel('Voltage (V)')
        self.ax.set_title('Signal')

        # Set up the layout
        layout = QVBoxLayout()
        self.canvas = FigureCanvas(fig)
        layout.addWidget(self.canvas, True)

        # Add an ok button
        ok_btn = QPushButton("Ok")
        btn_layout = QHBoxLayout()
        ok_btn.setFixedWidth(50)
        ok_btn.clicked.connect(self.handle_ok)
        btn_layout.setAlignment(Qt.AlignmentFlag.AlignCenter)
        btn_layout.addWidget(ok_btn)
        layout.addLayout(btn_layout)

        self.setLayout(layout)

    def update_plot(self):
        # Update the adjusted signals
        if self.experiment.crop_voltage is not None:
            self.adjusted_incident.set_ydata(self.experiment.incident_wave.crop_voltage)
            self.adjusted_transmitted.set_ydata(self.experiment.transmitted_wave.crop_voltage)
            self.ax.autoscale_view(scaley=True, scalex=False)
            self.canvas.draw()

    def handle_ok(self):
        self.okClicked.emit()


if __name__ == '__main__':
    import sys
    from PyQt6.QtWidgets import QApplication
    from stressless.util._load_test import EXPERIMENT

    EXPERIMENT.crop_start = 8_000
    EXPERIMENT.crop_end = 30_000
    EXPERIMENT.set_crop()

    EXPERIMENT.set_incident_offset(5_000, 10_000)
    EXPERIMENT.set_transmitted_offset(10_000, 30_000)
    EXPERIMENT.update_crop_voltage()

    app = QApplication(sys.argv)
    signal_test = ShowSignal(EXPERIMENT)
    signal_test.show()
    sys.exit(app.exec())
