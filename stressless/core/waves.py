from typing import Optional


class Wave:
    def __init__(self, voltage_data):
        self.voltage_data = voltage_data
        self.crop_voltage = None

        self._bar_properties: Optional[dict] = None

        # Bar properties
        self.gauge_factor = None
        self.sampling_frequency = None
        self.modulus = None
        self.density = None
        self.wave_speed = None
        self.diameter = None

    @property
    def bar_properties(self) -> Optional[dict]:
        if self._bar_properties is not None:
            return {
                'gauge_factor': self.gauge_factor,
                'sampling_frequency': self.sampling_frequency,
                'modulus': self.modulus,
                'density': self.density,
                'wave_speed': self.wave_speed,
                'diameter': self.diameter
            }
        else:
            return None

    @bar_properties.setter
    def bar_properties(self, value: Optional[dict]):
        self._bar_properties = value

        if value is not None:
            self.gauge_factor = value['gauge_factor']
            self.sampling_frequency = value['sampling_frequency']*1e6
            self.modulus = value['modulus']*1e6
            self.density = value['density']
            self.wave_speed = value['wave_speed']
            self.diameter = value['diameter']*1e-3
        else:
            self.gauge_factor = None
            self.sampling_frequency = None
            self.modulus = None
            self.density = None
            self.wave_speed = None
            self.diameter = None


class IncidentWave(Wave):
    def __init__(self, voltage_data):
        super().__init__(voltage_data)


class ReflectedWave(Wave):
    def __init__(self, voltage_data):
        super().__init__(voltage_data)


class TransmittedWave(Wave):
    def __init__(self, voltage_data):
        super().__init__(voltage_data)
