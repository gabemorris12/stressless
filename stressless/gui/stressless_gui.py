import sys

from PyQt6.QtGui import QAction
from PyQt6.QtWidgets import QMainWindow, QApplication

from stressless.util.helpers import load_from_excel
from stressless import SETTINGS


class MainWindow(QMainWindow):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Stressless - SHPB Analysis")
        self.open_dir = SETTINGS.value("open_dir", "")
        self.setup_menu()

    def setup_menu(self):
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
        load_data.triggered.connect(self._data_loader)

    def _data_loader(self):
        """
        Called when the user selects the Load Data action in the File menu.
        """
        # TODO: add use case for no excel (will probably need to be a separate action; consider making the Load Data
        #  action expand to two options)
        # TODO: add data validation
        data, file_name = load_from_excel(self, self.open_dir)
        if data is not None:
            self.open_dir = str(file_name.parent)
            SETTINGS.setValue("open_dir", self.open_dir)
        print(data, file_name)


def main():
    # sys.excepthook = my_exception_hook

    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
