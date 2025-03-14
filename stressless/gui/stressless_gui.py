import sys
from typing import Optional

import matplotlib.pyplot as plt
import numpy as np
from PyQt6.QtCore import QSignalBlocker
from PyQt6.QtGui import QAction
from PyQt6.QtWidgets import QMainWindow, QApplication, QComboBox, QWidget, QVBoxLayout, QHBoxLayout, \
    QLabel, QGroupBox, QGridLayout, QLineEdit, QPushButton, QInputDialog, QMessageBox, QRadioButton

from stressless.gui import _SETTINGS
from stressless.core.hopkinson_data import HopkinsonExperiment
from stressless.gui._bar_config import BarConfigWindow
from stressless.gui._crop_widget import CropWidget
from stressless.gui._show_signal_widget import ShowSignal
from stressless.util.helpers import load_from_excel, catch_exceptions
from stressless.util.logger import logger

WIDGET_SPACE = 5
SIDEBAR_WIDTH = 240


class MainWindow(QMainWindow):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Stressless - SHPB Analysis")
        self.resize(1200, 800)
        self.open_dir = _SETTINGS.value("open_dir", "")

        self.hopkinson_data: list[HopkinsonExperiment] = []
        self.current_experiment: Optional[HopkinsonExperiment] = None
        self.bar_dicts = {}
        self.bar_tags = set()  # used to ensure unique tags

        self._setup_menu()
        self._setup_ui()

    def _setup_menu(self):
        # Create the menu bar
        menu_bar = self.menuBar()

        # Create File menu and add actions
        file_menu = menu_bar.addMenu("&File")
        load_data = QAction("Load Data", self)
        exit_action = QAction("Exit", self)
        file_menu.addAction(load_data)
        file_menu.addSeparator()
        file_menu.addAction(exit_action)

        # Connect actions to functions
        exit_action.triggered.connect(self.close)
        load_data.triggered.connect(lambda: self._data_loader())

    def _setup_ui(self):
        # Set the central widget with a horizontal layout to divide the window
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QHBoxLayout()
        main_layout.setContentsMargins(WIDGET_SPACE, WIDGET_SPACE, WIDGET_SPACE, WIDGET_SPACE)
        main_layout.setSpacing(WIDGET_SPACE)
        central_widget.setLayout(main_layout)

        # Left sidebar: fixed width
        sidebar = QWidget()
        sidebar.setFixedWidth(SIDEBAR_WIDTH)
        sidebar_layout = QVBoxLayout()
        sidebar_layout.setContentsMargins(WIDGET_SPACE, WIDGET_SPACE, WIDGET_SPACE, WIDGET_SPACE)
        sidebar_layout.setSpacing(WIDGET_SPACE)
        sidebar.setLayout(sidebar_layout)

        # Dataset GroupBox
        dataset_box = QGroupBox("Dataset")
        dataset_layout = QVBoxLayout()
        self.dataset_combo = QComboBox()
        self.dataset_combo.currentIndexChanged.connect(self._update_dataset)
        dataset_layout.addWidget(self.dataset_combo)
        dataset_box.setLayout(dataset_layout)
        sidebar_layout.addWidget(dataset_box)

        # Bar Configuration GroupBox
        bar_config_box = QGroupBox("Bar Configuration")
        bar_config_layout = QVBoxLayout()
        bar_combo_layout = QGridLayout()
        bar_combo_layout.addWidget(QLabel("Incident Bar"), 0, 0)
        self.incident_combo = QComboBox()
        bar_combo_layout.addWidget(self.incident_combo, 0, 1)
        bar_combo_layout.addWidget(QLabel("Transmitted Bar"), 1, 0)
        self.transmitted_combo = QComboBox()
        bar_combo_layout.addWidget(self.transmitted_combo, 1, 1)
        bar_config_layout.addLayout(bar_combo_layout)
        bar_button_layout = QHBoxLayout()
        add_button = QPushButton("Add")
        edit_button = QPushButton("Edit")
        remove_button = QPushButton("Remove")
        bar_button_layout.addWidget(add_button)
        bar_button_layout.addWidget(edit_button)
        bar_button_layout.addWidget(remove_button)
        add_button.clicked.connect(lambda: self._add_bar())
        edit_button.clicked.connect(lambda: self._edit_bar())
        remove_button.clicked.connect(lambda: self._remove_bar())
        self.incident_combo.currentIndexChanged.connect(self._update_bar)
        self.transmitted_combo.currentIndexChanged.connect(self._update_bar)
        bar_config_layout.addLayout(bar_button_layout)
        bar_config_box.setLayout(bar_config_layout)
        sidebar_layout.addWidget(bar_config_box)

        # Sample Geometry GroupBox
        sample_geometry_box = QGroupBox("Sample Geometry")
        sample_geometry_layout = QGridLayout()
        # Row 1: Length
        length_label = QLabel("Length")
        length_input = QLineEdit()
        length_unit = QLabel("mm")
        sample_geometry_layout.addWidget(length_label, 0, 0)
        sample_geometry_layout.addWidget(length_input, 0, 1)
        sample_geometry_layout.addWidget(length_unit, 0, 2)
        # Row 2: Area
        area_label = QLabel("Area")
        area_input = QLineEdit()
        area_unit = QLabel("mm²")
        sample_geometry_layout.addWidget(area_label, 1, 0)
        sample_geometry_layout.addWidget(area_input, 1, 1)
        sample_geometry_layout.addWidget(area_unit, 1, 2)
        # Row 3: Diameter
        diameter_label = QLabel("Diameter")
        diameter_input = QLineEdit()
        diameter_unit = QLabel("mm")
        sample_geometry_layout.addWidget(diameter_label, 2, 0)
        sample_geometry_layout.addWidget(diameter_input, 2, 1)
        sample_geometry_layout.addWidget(diameter_unit, 2, 2)
        sample_geometry_layout.setColumnStretch(0, 1)
        sample_geometry_layout.setColumnStretch(1, 2)
        sample_geometry_layout.setColumnStretch(2, 1)
        sample_geometry_box.setLayout(sample_geometry_layout)
        sidebar_layout.addWidget(sample_geometry_box)

        # Signal Processing GroupBox
        signal_processing_box = QGroupBox("Signal Processing")
        signal_processing_layout = QVBoxLayout()
        self.show_signal_btn = QPushButton("Show Signal")
        self.show_signal_btn.setEnabled(False)
        self.show_signal_btn.clicked.connect(self._show_signal)
        signal_processing_layout.addWidget(self.show_signal_btn)
        self.crop_button = QPushButton("Crop Signal")
        self.crop_button.setCheckable(True)
        self.crop_button.setEnabled(False)
        self.crop_button.clicked.connect(self._crop_signal)
        signal_processing_layout.addWidget(self.crop_button)
        null_layout = QGridLayout()
        self.null_incident_button = QPushButton("Null Incident")
        self.null_incident_button.setCheckable(True)
        self.null_incident_button.setEnabled(False)
        self.null_incident_button.clicked.connect(self._null_incident)
        self.incident_invert = QRadioButton("Invert")
        self.incident_invert.clicked.connect(self._on_incident_invert)
        self.incident_invert.setAutoExclusive(False)
        self.incident_invert.setEnabled(False)
        null_layout.addWidget(self.incident_invert, 0, 0)
        null_layout.addWidget(self.null_incident_button, 0, 1)
        self.null_transmitted_button = QPushButton("Null Transmitted")
        self.null_transmitted_button.setCheckable(True)
        self.null_transmitted_button.setEnabled(False)
        self.null_transmitted_button.clicked.connect(self._null_transmitted)
        self.transmitted_invert = QRadioButton("Invert")
        self.transmitted_invert.clicked.connect(self._on_transmitted_invert)
        self.transmitted_invert.setAutoExclusive(False)
        self.transmitted_invert.setEnabled(False)
        null_layout.addWidget(self.transmitted_invert, 1, 0)
        null_layout.addWidget(self.null_transmitted_button, 1, 1)
        null_layout.setColumnStretch(0, 1)
        null_layout.setColumnStretch(1, 2)
        signal_processing_layout.addLayout(null_layout)
        signal_processing_box.setLayout(signal_processing_layout)
        sidebar_layout.addWidget(signal_processing_box)

        sidebar_layout.addStretch()
        main_layout.addWidget(sidebar)

        # Plot area
        plot_area = QWidget()
        self.plot_layout = QVBoxLayout()
        self.plot_layout.setContentsMargins(WIDGET_SPACE, WIDGET_SPACE, WIDGET_SPACE, WIDGET_SPACE)
        self.plot_layout.setSpacing(WIDGET_SPACE)
        plot_area.setLayout(self.plot_layout)
        main_layout.addWidget(plot_area)

    @catch_exceptions
    def _data_loader(self):
        """
        Called when the user selects the Load Data action in the File menu.
        """
        # TODO: add use case for no excel (will probably need to be a separate action; consider making the Load Data
        #  action expand to two options)
        # TODO: add an Excel loading message or notification somewhere
        data, file_name = load_from_excel(self, self.open_dir)
        if data is not None:
            self.open_dir = str(file_name.parent)
            _SETTINGS.setValue("open_dir", self.open_dir)

            # Create a HopkinsonExperiment object from the data
            existing_labels = [self.dataset_combo.itemText(i) for i in range(self.dataset_combo.count())]
            experiment = HopkinsonExperiment(data, file_name, existing_labels)  # will validate data in init

            # Update the combo box and block signals to prevent premature triggering
            with QSignalBlocker(self.dataset_combo):
                self.dataset_combo.addItem(experiment.name)
                self.hopkinson_data.append(experiment)
                self.dataset_combo.setCurrentIndex(self.dataset_combo.count() - 1)
            self.show_signal_btn.setEnabled(True)
            self._update_dataset()  # necessary because the above line doesn't trigger sometimes

    def _update_dataset(self):
        """
        Called when the user selects a different dataset from the combo box. It will update the widgets with the
        given index as well as ensure that the appropriate HopkinsonExperiment object is selected.
        """
        # TODO: this needs to be modified if a method of removing datasets is added
        index = self.dataset_combo.currentIndex()
        self.current_experiment = self.hopkinson_data[index]
        logger.info(f"Selected dataset: {self.current_experiment.name} from {self.current_experiment.file}")
        logger.info(f"Current datasets: {[exp.name for exp in self.hopkinson_data]}")
        self.crop_button.setEnabled(True)

        # Check if the dataset has been cropped and nulled:
        if self.current_experiment.crop_start is None:
            self.crop_button.setChecked(False)
            self.incident_invert.setEnabled(False)
            self.transmitted_invert.setEnabled(False)
        else:
            self.crop_button.setChecked(True)
            self.incident_invert.setEnabled(True)
            self.transmitted_invert.setEnabled(True)
            incident_invert_val = True if self.current_experiment.incident_invert == -1 else False
            transmitted_invert_val = True if self.current_experiment.transmitted_invert == -1 else False
            self.incident_invert.setChecked(incident_invert_val)
            self.transmitted_invert.setChecked(transmitted_invert_val)
        if self.current_experiment.incident_offset:
            self.null_incident_button.setChecked(True)
            self.null_incident_button.setEnabled(True)
        elif not self.current_experiment.incident_offset and self.current_experiment.crop_start:
            self.null_incident_button.setChecked(False)
            self.null_incident_button.setEnabled(True)
        else:
            self.null_incident_button.setChecked(False)
            self.null_incident_button.setEnabled(False)
        if self.current_experiment.transmitted_offset:
            self.null_transmitted_button.setChecked(True)
            self.null_transmitted_button.setEnabled(True)
        elif not self.current_experiment.transmitted_offset and self.current_experiment.crop_start:
            self.null_transmitted_button.setChecked(False)
            self.null_transmitted_button.setEnabled(True)
        else:
            self.null_transmitted_button.setChecked(False)
            self.null_transmitted_button.setEnabled(False)

        self._clear_layout(self.plot_layout)
        self._update_bar()

    @catch_exceptions
    def _add_bar(self):
        """
        Adds a new bar to the bar configuration combo boxes.
        """
        if self.current_experiment is None:
            self._prompt_message("Please load a dataset before adding a bar.", "No Dataset Loaded")
            return

        bar_config_window = BarConfigWindow(self)
        result = bar_config_window.exec()
        if result:
            bar_dict = bar_config_window.validate()
            self.bar_dicts[bar_dict['tag']] = bar_dict
            self.bar_tags.add(bar_dict['tag'])
            bar_index = list(self.bar_tags).index(bar_dict['tag'])

            # Update the combo boxes
            existing_bars = [self.incident_combo.itemText(i) for i in range(self.incident_combo.count())]
            with QSignalBlocker(self.incident_combo), QSignalBlocker(self.transmitted_combo):
                self.incident_combo.addItems(self.bar_tags.difference(existing_bars))
                self.transmitted_combo.addItems(self.bar_tags.difference(existing_bars))
                self.incident_combo.setCurrentIndex(bar_index)
                self.transmitted_combo.setCurrentIndex(bar_index)
            self._update_bar()

    @catch_exceptions
    def _edit_bar(self):
        if self.current_experiment is None:
            self._prompt_message("Please load a dataset before editing a bar.", "No Dataset Loaded")
            return

        item, ok = QInputDialog.getItem(
            self, "Select Bar to Edit", "Choose a bar:", self.bar_tags, 0, False
        )

        if ok and item:
            bar_config_window = BarConfigWindow(self, self.bar_dicts[item])
            result = bar_config_window.exec()
            if result:
                bar_dict = bar_config_window.validate()
                self.bar_dicts[bar_dict['tag']] = bar_dict
                self._update_bar()

    def _remove_bar(self):
        if self.current_experiment is None:
            self._prompt_message("Please load a dataset before removing a bar.", "No Dataset Loaded")
            return

        item, ok = QInputDialog.getItem(
            self, "Select Bar to Remove", "Choose a bar:", self.bar_tags, 0, False
        )

        if ok and item:
            self.bar_dicts.pop(item)
            self.bar_tags.remove(item)
            with QSignalBlocker(self.incident_combo), QSignalBlocker(self.transmitted_combo):
                self.incident_combo.removeItem(self.incident_combo.findText(item))
                self.transmitted_combo.removeItem(self.transmitted_combo.findText(item))
            self._update_bar()

    def _update_bar(self):
        """
        Updates the bar label and the HopkinsonExperiment object with the selected bar configuration. This will only
        update if both the incident and transmitted bars are selected.
        """
        incident_tag = self.incident_combo.currentText()
        transmitted_tag = self.transmitted_combo.currentText()

        if incident_tag and transmitted_tag:
            self.current_experiment.incident_bar = self.bar_dicts[incident_tag]
            self.current_experiment.transmitted_bar = self.bar_dicts[transmitted_tag]

            logger.info(f"Updated incident bar: {incident_tag}")
            logger.info(f"Incident bar properties: {self.current_experiment.incident_wave.bar_properties}")
            logger.info(f"Updated transmitted bar: {transmitted_tag}")
            logger.info(f"Transmitted bar properties: {self.current_experiment.transmitted_wave.bar_properties}")
        else:
            logger.info("Clearing bar properties.")
            self.current_experiment.incident_bar = None
            self.current_experiment.transmitted_bar = None

    def _prompt_message(self, message: str, title: str):
        """
        Prompts a message to the user.
        """
        QMessageBox.information(self, title, message)

    def _crop_signal(self):

        if not self.plot_layout.count():
            self.crop_button.setChecked(False)
            instructions = [
                'Zoom in on the analysis region, which should contain at least one full incident, reflected, and transmitted wave.',
                'Click once to set the start of the region, and click again to set the end.',
                'Once finished, click "Ok" to proceed with the analysis.'
            ]
            instructions = '\n'.join(instructions)

            # Plot the raw data
            fig, axes = plt.subplots()
            x = np.arange(len(self.current_experiment.raw_data))
            axes.plot(x, self.current_experiment.raw_data[:, 0], picker=True, label='Incident')
            axes.plot(x, self.current_experiment.raw_data[:, 1], picker=True, label='Transmitted')

            # Add labels
            axes.legend()
            axes.set_xlabel('Index')
            axes.set_ylabel('Voltage (V)')
            axes.set_title('Signal Cropping')
            crop_widget = CropWidget(self.current_experiment, fig, axes, instructions)
            crop_widget.okClicked.connect(self._on_crop_signal)
            self.plot_layout.addWidget(crop_widget)
        else:
            self.crop_button.setChecked(not self.crop_button.isChecked())

    def _on_crop_signal(self):
        # Get the one widget in the layout
        # noinspection PyTypeChecker
        crop_widget: CropWidget = self.plot_layout.itemAt(0).widget()
        self._clear_layout(self.plot_layout)
        self.current_experiment.crop_start = crop_widget.start
        self.current_experiment.crop_end = crop_widget.end
        self.crop_button.setChecked(True)
        self.current_experiment.set_crop()
        self.current_experiment.update_crop_voltage()
        self.null_incident_button.setEnabled(True)
        self.null_transmitted_button.setEnabled(True)
        self.incident_invert.setEnabled(True)
        self.transmitted_invert.setEnabled(True)

    def _clear_layout(self, layout):
        while layout.count():
            item = layout.takeAt(0)
            widget = item.widget()
            if widget is not None:
                widget.deleteLater()
            else:
                # If the item is a layout, clear it recursively.
                self._clear_layout(item.layout())

    def _null_incident(self):

        if not self.plot_layout.count():
            self.null_incident_button.setChecked(False)
            instructions = [
                'Select the region of the incident wave that is supposed to be zero. An offset will be applied later.',
                'Click once to set the start of the region, and click again to set the end.',
                'Once finished, click "Ok" to proceed with the analysis.'
            ]
            instructions = '\n'.join(instructions)

            # Make a plot with only incident data
            fig, ax = plt.subplots()
            x = np.arange(self.current_experiment.n_samples)
            incident_raw = self.current_experiment.raw_data[:, 0]
            ax.plot(x, incident_raw, label='Incident')

            # Add labels
            ax.legend()
            ax.set_xlabel('Index')
            ax.set_ylabel('Voltage (V)')
            ax.set_title('Null Incident')

            crop_widget = CropWidget(self.current_experiment, fig, ax, instructions, ignore_initial_crop=True)
            crop_widget.okClicked.connect(self._on_null_incident)
            self.plot_layout.addWidget(crop_widget)
        else:
            self.null_incident_button.setChecked(not self.null_incident_button.isChecked())

    def _on_null_incident(self):
        # noinspection PyTypeChecker
        crop_widget: CropWidget = self.plot_layout.itemAt(0).widget()
        self._clear_layout(self.plot_layout)
        self.current_experiment.set_incident_offset(crop_widget.start, crop_widget.end)
        self.current_experiment.update_crop_voltage()
        self.null_incident_button.setChecked(True)

    def _null_transmitted(self):

        if not self.plot_layout.count():
            self.null_transmitted_button.setChecked(False)
            instructions = [
                'Select the region of the transmitted wave that is supposed to be zero. An offset will be applied later.',
                'Click once to set the start of the region, and click again to set the end.',
                'Once finished, click "Ok" to proceed with the analysis.'
            ]
            instructions = '\n'.join(instructions)

            # Make a plot with only transmitted data
            fig, ax = plt.subplots()
            x = np.arange(self.current_experiment.n_samples)
            transmitted_raw = self.current_experiment.raw_data[:, 1]
            ax.plot(x, transmitted_raw, label='Transmitted')

            # Add labels
            ax.legend()
            ax.set_xlabel('Index')
            ax.set_ylabel('Voltage (V)')
            ax.set_title('Null Transmitted')

            crop_widget = CropWidget(self.current_experiment, fig, ax, instructions, ignore_initial_crop=True)
            crop_widget.okClicked.connect(self._on_null_transmitted)
            self.plot_layout.addWidget(crop_widget)
        else:
            self.null_transmitted_button.setChecked(not self.null_transmitted_button.isChecked())

    def _on_null_transmitted(self):
        # noinspection PyTypeChecker
        crop_widget: CropWidget = self.plot_layout.itemAt(0).widget()
        self._clear_layout(self.plot_layout)
        self.current_experiment.set_transmitted_offset(crop_widget.start, crop_widget.end)
        self.current_experiment.update_crop_voltage()
        self.null_transmitted_button.setChecked(True)

    def _show_signal(self):
        if not self.plot_layout.count():
            signal = ShowSignal(self.current_experiment)
            signal.okClicked.connect(self._on_show_signal)
            self.plot_layout.addWidget(signal)

    def _on_show_signal(self):
        self._clear_layout(self.plot_layout)

    def _on_incident_invert(self):
        self.current_experiment.incident_invert = -self.current_experiment.incident_invert
        self.current_experiment.update_crop_voltage()
        logger.info(f"Inverting incident wave at {self.current_experiment.name}.")

        # If the ShowSignal widget is present, update the plot
        if self.plot_layout.count():
            existing_widget = self.plot_layout.itemAt(0).widget()
            if isinstance(existing_widget, ShowSignal):
                existing_widget.update_plot()

    def _on_transmitted_invert(self):
        self.current_experiment.transmitted_invert = -self.current_experiment.transmitted_invert
        self.current_experiment.update_crop_voltage()
        logger.info(f"Inverting transmitted wave at {self.current_experiment.name}.")

        # If the ShowSignal widget is present, update the plot
        if self.plot_layout.count():
            existing_widget = self.plot_layout.itemAt(0).widget()
            if isinstance(existing_widget, ShowSignal):
                existing_widget.update_plot()


def exception_hook(exctype, value, tb):
    logger.exception("Uncaught exception", exc_info=(exctype, value, tb))
    # Optionally call the default excepthook
    sys.__excepthook__(exctype, value, tb)


sys.excepthook = exception_hook


def main():
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
