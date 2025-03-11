

class Wave:
    def __init__(self, voltage_data, sample_rate):
        self.voltage_data = voltage_data
        self.sample_rate = sample_rate


class IncidentWave(Wave):
    def __init__(self, voltage_data, sample_rate):
        super().__init__(voltage_data, sample_rate)


class ReflectedWave(Wave):
    def __init__(self, voltage_data, sample_rate):
        super().__init__(voltage_data, sample_rate)


class TransmittedWave(Wave):
    def __init__(self, voltage_data, sample_rate):
        super().__init__(voltage_data, sample_rate)
