from functools import wraps
from pathlib import Path
from typing import Optional

import xlwings as xw
from PyQt6.QtWidgets import QFileDialog, QMessageBox, QWidget


def load_from_excel(parent: Optional[QWidget] = None, open_dir: Path = None) -> tuple:
    """
    Prompts the user to select an Excel file, opens it with xlwings, and then shows an information message to instruct
    the user to select the desired range in Excel before continuing.

    :param parent: The parent widget for the file dialog and message box.
    :param open_dir: Path; The directory to open the file dialog in.
    :return: Returns a tuple containing (None, None) or (data, file_path) where data is of type List[List[Any]] and
             file_path is of type Path.
    """
    # TODO: need to add a function that checks to see if excel is installed
    # Get file path from user
    file_path, _ = QFileDialog.getOpenFileName(
        parent,
        "Select an Excel File",
        open_dir,
        "Excel Files (*.xlsx *.xlsm *.xls);;All Files (*)"
    )

    if not file_path:
        return None, None
    file_path = Path(file_path)

    # Open the workbook
    book = xw.Book(file_path.absolute())
    app = book.app

    # Notify the user to make a selection in Excel
    # This modal message box will block until the user clicks OK.
    QMessageBox.information(
        parent,
        "Excel Selection",
        "Please go to Excel, select the desired range, then click OK to continue."
    )

    # Get current selection from excel
    selected_range = app.selection
    data = selected_range.value

    # Close the workbook
    book.close()
    app.quit()

    return data, file_path


# TODO: this should be adjusted to do something special if we get an unexpected exception
def catch_exceptions(func):
    """
    A decorator that catches exceptions and shows a message box to the user.

    :param func:
    :return:
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            parent = args[0] if isinstance(args[0], QWidget) else None
            QMessageBox.critical(parent, "Error", str(e))
    return wrapper
