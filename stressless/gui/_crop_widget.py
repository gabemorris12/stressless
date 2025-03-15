import matplotlib.pyplot as plt
from PyQt6 import QtWidgets, QtCore
from PyQt6.QtCore import Qt
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas

from stressless.core.hopkinson_data import HopkinsonExperiment
from stressless.util.logger import logger


class CropWidget(QtWidgets.QWidget):
    # Custom signal that is emitted when the OK button is pressed.
    okClicked = QtCore.pyqtSignal()

    def __init__(self, experiment: HopkinsonExperiment = None, figure: plt.Figure = None, axes: plt.Axes = None,
                 instructions=None, ignore_initial_crop=False, parent=None):
        super().__init__(parent)

        # Set up the layout.
        layout = QtWidgets.QVBoxLayout(self)
        instruction_label = QtWidgets.QLabel(instructions)
        layout.addWidget(instruction_label)

        # Create the matplotlib figure and canvas.
        self.figure = figure
        self.axes = axes
        self.canvas = FigureCanvas(self.figure)
        layout.addWidget(self.canvas, True)

        # Create a horizontal layout for the buttons.
        btn_layout = QtWidgets.QHBoxLayout()
        btn_grid_layout = QtWidgets.QGridLayout()
        self.ok_button = QtWidgets.QPushButton("Ok")
        self.restart_button = QtWidgets.QPushButton("Restart")
        self.ok_button.setFixedWidth(70)
        self.restart_button.setFixedWidth(70)
        btn_layout.addWidget(self.ok_button)
        btn_layout.addWidget(self.restart_button)
        btn_grid_layout.addLayout(btn_layout, 0, 1, Qt.AlignmentFlag.AlignCenter)
        layout.addLayout(btn_grid_layout)
        layout.addStretch()

        # Connect the button signals.
        self.ok_button.clicked.connect(self.handle_ok)
        self.restart_button.clicked.connect(self.handle_restart)

        # Save the original x-limits to use for restart.
        self.original_xlim = self.axes.get_xlim()

        # State variables for domain selection.
        self.selection_start = None  # x-value of first click.
        self.perm_line_start = None  # Permanent red vertical line from the first click.

        # Store the start and end indices
        self.experiment = experiment
        self.start, self.end = experiment.crop_start, experiment.crop_end
        if self.start is not None and self.end is not None and not ignore_initial_crop:
            # Update x-limits to zoom in.
            self.axes.set_xlim(self.start, self.end)
            self.axes.relim()
            self.axes.autoscale_view(scalex=False, scaley=True)
        else:
            self.start = 0
            self.end = experiment.n_samples - 1

        # Temporary vertical line (blue) for the mouse cursor.
        self.temp_line = self.axes.axvline(0, color='blue', linestyle='--', alpha=0.7, visible=False)

        # Variable to store the canvas background for blitting.
        self.background = None

        # Connect matplotlib events.
        # noinspection PyTypeChecker
        self.canvas.mpl_connect("button_press_event", self.on_click)
        # noinspection PyTypeChecker
        self.canvas.mpl_connect("motion_notify_event", self.on_motion)
        self.canvas.mpl_connect("resize_event", self.on_resize)

        # Initial draw and capture of the background.
        self.canvas.draw()
        self.background = self.canvas.copy_from_bbox(self.axes.bbox)

    def on_resize(self, _):
        # Redraw and recapture the background on resize.
        self.canvas.draw()
        self.background = self.canvas.copy_from_bbox(self.axes.bbox)

    def on_click(self, event):
        if event.inaxes != self.axes:
            return

        if self.selection_start is None:
            # First click: record the starting x-value.
            self.selection_start = event.xdata
            if self.perm_line_start:
                self.perm_line_start.remove()
            self.perm_line_start = self.axes.axvline(self.selection_start, color='red', linestyle='--')
            self.canvas.draw()
            self.background = self.canvas.copy_from_bbox(self.axes.bbox)
            logger.debug(f"Selection start set at x = {self.selection_start:.2f}")
        else:
            # Second click: finalize the selection and zoom in.
            selection_end = event.xdata
            self.start = int(min(self.selection_start, selection_end))
            self.end = int(max(self.selection_start, selection_end))
            logger.debug(f"Zooming in from x = {self.start} to x = {self.end}")

            # Update x-limits to zoom in.
            self.axes.set_xlim(self.start, self.end)
            self.axes.relim()
            self.axes.autoscale_view(scalex=False, scaley=True)

            # Remove the permanent red line.
            if self.perm_line_start:
                self.perm_line_start.remove()
                self.perm_line_start = None

            self.canvas.draw()
            self.background = self.canvas.copy_from_bbox(self.axes.bbox)
            self.selection_start = None  # Reset for a new selection.
            self.temp_line.set_visible(False)

    def on_motion(self, event):
        if event.inaxes != self.axes:
            # Hide temporary line if the cursor leaves the axes.
            if self.temp_line.get_visible():
                self.temp_line.set_visible(False)
                self.canvas.draw()
                self.background = self.canvas.copy_from_bbox(self.axes.bbox)
            return

        current_x = event.xdata
        if current_x is None:
            return

        # Update the temporary line position.
        self.temp_line.set_xdata([current_x, current_x])
        if not self.temp_line.get_visible():
            self.temp_line.set_visible(True)

        # Blitting for smooth updates.
        if self.background is not None:
            self.canvas.restore_region(self.background)
            self.axes.draw_artist(self.temp_line)
            self.canvas.blit(self.axes.bbox)
        else:
            self.canvas.draw_idle()

    def handle_restart(self):
        # Reset the axes to the original un-cropped state.
        self.start = 0
        self.end = self.experiment.n_samples - 1
        self.axes.set_xlim(self.original_xlim)
        self.axes.relim()
        self.axes.autoscale_view(scalex=False, scaley=True)
        # Remove any selection markers.
        if self.perm_line_start:
            self.perm_line_start.remove()
            self.perm_line_start = None
        self.selection_start = None
        self.canvas.draw()
        self.background = self.canvas.copy_from_bbox(self.axes.bbox)
        logger.debug("Restarted to original state.")

    def handle_ok(self):
        if not self.start or self.end == self.experiment.n_samples - 1:
            logger.debug("No crop selection made.")
            return

        if self.start is not None and self.end is not None:
            # Set the crop start and end indices in the experiment.
            self.start = self.start if self.start >= 0 else 0
            self.end = self.end if self.end < self.experiment.n_samples else self.experiment.n_samples - 1

            # Emit the custom signal to notify the parent.
            self.okClicked.emit()
            logger.debug("Ok crop button pressed; signal emitted.")
