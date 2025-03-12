import sys
from typing import Optional

from PyQt6.QtCore import Qt
from PyQt6.QtGui import QAction
from PyQt6.QtWidgets import QMainWindow, QApplication, QComboBox, QWidget, QVBoxLayout, QHBoxLayout, \
    QLabel, QGroupBox, QGridLayout, QLineEdit, QPushButton, QInputDialog

from stressless import SETTINGS
from stressless.core.hopkinson_data import HopkinsonExperiment
from stressless.util.helpers import load_from_excel, catch_exceptions
from stressless.gui._bar_config import BarConfigWindow

WIDGET_SPACE = 5
SIDEBAR_WIDTH = 200


class MainWindow(QMainWindow):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Stressless - SHPB Analysis")
        self.open_dir = SETTINGS.value("open_dir", "")

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
        central_widget = QWidget(self)
        self.setCentralWidget(central_widget)
        main_layout = QHBoxLayout(central_widget)
        main_layout.setContentsMargins(WIDGET_SPACE, WIDGET_SPACE, WIDGET_SPACE, WIDGET_SPACE)
        main_layout.setSpacing(WIDGET_SPACE)

        # Left sidebar: fixed width
        sidebar = QWidget(central_widget)
        sidebar.setFixedWidth(SIDEBAR_WIDTH)
        sidebar_layout = QVBoxLayout(sidebar)
        sidebar_layout.setContentsMargins(WIDGET_SPACE, WIDGET_SPACE, WIDGET_SPACE, WIDGET_SPACE)
        sidebar_layout.setSpacing(WIDGET_SPACE)

        # Add the dataset box and combobox to the sidebar
        dataset_box = QGroupBox("Dataset", sidebar)
        dataset_layout = QVBoxLayout(dataset_box)
        self.dataset_combo = QComboBox(dataset_box)
        dataset_layout.addWidget(self.dataset_combo)
        dataset_box.setLayout(dataset_layout)

        sidebar_layout.addWidget(dataset_box)

        # Add the bar configuration box and widgets
        bar_config_box = QGroupBox("Bar Configuration", sidebar)
        bar_config_layout = QVBoxLayout(bar_config_box)
        bar_combo_layout = QGridLayout(bar_config_box)
        bar_combo_layout.addWidget(
            QLabel('Incident Bar', bar_config_box), 0, 0
        )
        self.incident_combo = QComboBox(bar_config_box)
        bar_combo_layout.addWidget(self.incident_combo, 0, 1)
        bar_combo_layout.addWidget(
            QLabel('Transmitted Bar', bar_config_box), 1, 0
        )
        self.transmitted_combo = QComboBox(bar_config_box)
        bar_combo_layout.addWidget(self.transmitted_combo, 1, 1)
        bar_config_layout.addLayout(bar_combo_layout)
        bar_button_layout = QHBoxLayout(bar_config_box)
        add_button = QPushButton("Add", bar_config_box)
        edit_button = QPushButton("Edit", bar_config_box)
        remove_button = QPushButton("Remove", bar_config_box)
        bar_button_layout.addWidget(add_button)
        bar_button_layout.addWidget(edit_button)
        bar_button_layout.addWidget(remove_button)
        add_button.clicked.connect(lambda: self._add_bar())
        edit_button.clicked.connect(lambda: self._edit_bar())
        remove_button.clicked.connect(lambda: self._remove_bar())
        bar_config_layout.addLayout(bar_button_layout)

        bar_config_box.setLayout(bar_config_layout)

        sidebar_layout.addWidget(bar_config_box)

        # Add the sample geometry box and widgets
        sample_geometry_box = QGroupBox("Sample Geometry", sidebar)
        sample_geometry_layout = QGridLayout(sample_geometry_box)
        # row 1 is the length
        length_label = QLabel("Length", sample_geometry_box)
        length_input = QLineEdit(sample_geometry_box)
        length_unit = QLabel("mm", sample_geometry_box)
        # row 2 is the area
        area_label = QLabel("Area", sample_geometry_box)
        area_input = QLineEdit(sample_geometry_box)
        area_unit = QLabel("mm²", sample_geometry_box)
        # row 3 is the diameter
        diameter_label = QLabel("Diameter", sample_geometry_box)
        diameter_input = QLineEdit(sample_geometry_box)
        diameter_unit = QLabel("mm", sample_geometry_box)
        sample_geometry_layout.addWidget(length_label, 0, 0)
        sample_geometry_layout.addWidget(length_input, 0, 1)
        sample_geometry_layout.addWidget(length_unit, 0, 2)
        sample_geometry_layout.addWidget(area_label, 1, 0)
        sample_geometry_layout.addWidget(area_input, 1, 1)
        sample_geometry_layout.addWidget(area_unit, 1, 2)
        sample_geometry_layout.addWidget(diameter_label, 2, 0)
        sample_geometry_layout.addWidget(diameter_input, 2, 1)
        sample_geometry_layout.addWidget(diameter_unit, 2, 2)
        sample_geometry_layout.setColumnStretch(0, 1)
        sample_geometry_layout.setColumnStretch(1, 2)
        sample_geometry_layout.setColumnStretch(2, 1)
        sample_geometry_box.setLayout(sample_geometry_layout)

        sidebar_layout.addWidget(sample_geometry_box)

        # Right area: plot area, which will occupy the remaining space
        plot_area = QWidget(central_widget)
        plot_layout = QVBoxLayout(plot_area)
        plot_layout.setContentsMargins(WIDGET_SPACE, WIDGET_SPACE, WIDGET_SPACE, WIDGET_SPACE)
        plot_layout.setSpacing(WIDGET_SPACE)
        temp_label = QLabel("Plot Area (will contain plots)", plot_area)
        temp_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        plot_layout.addWidget(temp_label)

        # Add sidebar and plot area to the main layout
        sidebar_layout.addStretch()
        main_layout.addWidget(sidebar)
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
            SETTINGS.setValue("open_dir", self.open_dir)

            # Create a HopkinsonExperiment object from the data
            existing_labels = [self.dataset_combo.itemText(i) for i in range(self.dataset_combo.count())]
            experiment = HopkinsonExperiment(data, file_name, existing_labels)  # will validate data in init

            # Update the combo box
            self.dataset_combo.addItem(experiment.name)
            self.hopkinson_data.append(experiment)
            self.dataset_combo.setCurrentIndex(self.dataset_combo.count() - 1)
            self._update_dataset(self.dataset_combo.currentIndex())

    def _update_dataset(self, index: int):
        """
        Called when the user selects a different dataset from the combo box. It will update the widgets with the
        given index as well as ensure that the appropriate HopkinsonExperiment object is selected.

        :param index: self.dataset_combo.currentIndex()
        """
        self.current_experiment = self.hopkinson_data[index]

    @catch_exceptions
    def _add_bar(self):
        """
        Adds a new bar to the bar configuration combo boxes.
        """
        bar_config_window = BarConfigWindow(self)
        result = bar_config_window.exec()
        if result:
            bar_dict = bar_config_window.validate()
            self.bar_dicts[bar_dict['tag']] = bar_dict
            self.bar_tags.add(bar_dict['tag'])

            # Update the combo boxes
            existing_bars = [self.incident_combo.itemText(i) for i in range(self.incident_combo.count())]
            self.incident_combo.addItems(self.bar_tags.difference(existing_bars))
            self.transmitted_combo.addItems(self.bar_tags.difference(existing_bars))

    @catch_exceptions
    def _edit_bar(self):
        item, ok = QInputDialog.getItem(
            self, "Select Bar to Edit", "Choose a bar:", self.bar_tags, 0, False
        )

        if ok and item:
            bar_config_window = BarConfigWindow(self, self.bar_dicts[item])
            result = bar_config_window.exec()
            if result:
                bar_dict = bar_config_window.validate()
                self.bar_dicts[bar_dict['tag']] = bar_dict

    def _remove_bar(self):
        item, ok = QInputDialog.getItem(
            self, "Select Bar to Remove", "Choose a bar:", self.bar_tags, 0, False
        )

        if ok and item:
            self.bar_dicts.pop(item)
            self.bar_tags.remove(item)
            self.incident_combo.removeItem(self.incident_combo.findText(item))
            self.transmitted_combo.removeItem(self.transmitted_combo.findText(item))


def main():
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
