import re
from collections.abc import Iterable
from pathlib import Path

import numpy as np


class HopkinsonExperiment:
    def __init__(self, raw_data: Iterable, file: Path, existing_data: list[str] = None):
        self._validate_data(raw_data)

        self.file = file
        self.name = None

        # If existing data is provided, then adjust the name
        if existing_data is not None:
            self._set_name(existing_data)

    def _validate_data(self, raw_data: Iterable):
        """
        Will raise ValueError if the data is not able to cast to float, or if it is not Mx2.
        """
        try:
            self.raw_data = np.asarray(raw_data, dtype=np.float64)
        except Exception:
            raise ValueError("Cannot cast all the data to floats. Ensure the selected data is only numerical.")

        if self.raw_data.ndim != 2 or self.raw_data.shape[1] != 2:
            raise ValueError("Data must only consist of two columns: incident and transmitted data.")

        # Ensure there are no nan values
        if np.isnan(self.raw_data).any():
            raise ValueError("Data contains empty values. Please adjust selection before importing.")

    def _set_name(self, existing_data: list[str]):
        """
        Loops through each existing name, ensuring no duplicate names are possible, then sets the name attribute.

        :param existing_data: List of existing names.
        """
        file_name = self.file.stem

        if file_name not in existing_data:
            self.name = file_name
        else:
            # Loop through the existing data to find the max number
            sample_name_pattern = re.compile(r'(.+)(\s\d+)*')
            max_num = 0
            for name in existing_data:
                match = sample_name_pattern.match(name)
                if match and match.group(2):
                    num = int(match.group(2).strip())
                    if num > max_num:
                        max_num = num
            self.name = f"{file_name} {max_num + 1}"

    def __repr__(self):
        return f"HopkinsonExperiment({self.raw_data.shape}, {self.file}, {self.name})"
