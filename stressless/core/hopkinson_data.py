import re
from collections.abc import Iterable
from pathlib import Path

import numpy as np
from typing import Optional

from stressless.core.waves import IncidentWave, ReflectedWave, TransmittedWave
from stressless.util.logger import logger


class HopkinsonExperiment:
    def __init__(self, raw_data: Iterable, file: Path | str | None = None, existing_data: list[str] = None):
        self._validate_data(raw_data)

        self.file = file
        self.name = None
        self._incident_bar: Optional[dict] = None
        self._transmitted_bar: Optional[dict] = None

        self.incident_wave = IncidentWave(self.raw_data[:, 0])
        self.reflected_wave = ReflectedWave(self.raw_data[:, 0])
        self.transmitted_wave = TransmittedWave(self.raw_data[:, 1])

        self.crop_start, self.crop_end = None, None
        self.crop_voltage = None
        self._no_adjustment_crop = None
        self.incident_invert, self.transmitted_invert = 1, 1
        self.n_samples = self.raw_data.shape[0]

        # Null offset
        self.incident_offset = 0
        self.transmitted_offset = 0

        # If existing data is provided, then adjust the name
        if existing_data is not None:
            self._set_name(existing_data)

    @property
    def incident_bar(self) -> Optional[dict]:
        """
        :return: Dictionary of the incident bar configuration information.
        """
        return self._incident_bar

    @incident_bar.setter
    def incident_bar(self, value: dict):
        """
        The setter for the incident bar configuration information. This will also populate

        :param value: Dictionary of the incident bar configuration information.
        """
        self._incident_bar = value

        self.incident_wave.bar_properties = value
        self.reflected_wave.bar_properties = value

    @property
    def transmitted_bar(self) -> Optional[dict]:
        """
        :return: Dictionary of the transmitted bar configuration information.
        """
        return self._transmitted_bar

    @transmitted_bar.setter
    def transmitted_bar(self, value: dict):
        """
        The setter for the transmitted bar configuration information.

        :param value: Dictionary of the transmitted bar configuration information.
        """
        self._transmitted_bar = value
        self.transmitted_wave.bar_properties = value

    def set_crop(self):
        """
        Sets the crop_voltage attribute
        """
        assert self.crop_start and self.crop_end, "Crop start and end must be set before setting the crop."
        self.crop_voltage = np.copy(self.raw_data[self.crop_start:self.crop_end, :])
        self._no_adjustment_crop = np.copy(self.crop_voltage)

        self._set_crop_voltage_to_waves()

        logger.info(f"Crop set to {self.crop_start} to {self.crop_end} for {self.name}.")

    def set_incident_offset(self, start: int, end: int):
        """
        Set the incident offset by taking an average of the data between start and end. The mean of the values
        between start and end is the offset value. The domain from start and end should be the zero region of the
        signal.

        :param start: The start index of the zero region.
        :param end: The end index of the zero region.
        """
        self.incident_offset = np.mean(self.raw_data[start:end, 0])
        logger.info(f"Incident offset set to {self.incident_offset}")

    def set_transmitted_offset(self, start: int, end: int):
        """
        Set the transmitted offset by taking an average of the data between start and end. The mean of the values
        between start and end is the offset value. The domain from start and end should be the zero region of the
        signal.

        :param start: The start index of the zero region.
        :param end: The end index of the zero region.
        """
        self.transmitted_offset = np.mean(self.raw_data[start:end, 1])
        logger.info(f"Transmitted offset set to {self.transmitted_offset}")

    def update_crop_voltage(self):
        """
        Modifies the cropped voltage by subtracting the offsets and inverting. This will raise an error if the crop
        has not yet been set.
        """
        if self.crop_voltage is None:
            raise ValueError("Crop voltage must be set before updating the crop voltage.")

        self.crop_voltage[:, 0] = (self._no_adjustment_crop[:, 0] - self.incident_offset)*self.incident_invert
        self.crop_voltage[:, 1] = (self._no_adjustment_crop[:, 1] - self.transmitted_offset)*self.transmitted_invert

        self._set_crop_voltage_to_waves()

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

    def _set_crop_voltage_to_waves(self):
        self.incident_wave.crop_voltage = self.crop_voltage[:, 0]
        self.reflected_wave.crop_voltage = self.crop_voltage
        self.transmitted_wave.crop_voltage = self.crop_voltage[:, 1]

    def __repr__(self):
        return f"HopkinsonExperiment({self.raw_data.shape}, {self.file}, {self.name})"
