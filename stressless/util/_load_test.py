# Module for generating test objects
import numpy as np

from stressless import HopkinsonExperiment


def get_path():
    import stressless
    from pathlib import Path

    return Path(stressless.__file__).parent


lib_path = get_path()
data_path = lib_path.parent/'SHPB Data'
assert data_path.exists(), f"Cannot find data path."

test_data = data_path/'test_data.txt'
raw_data = np.loadtxt(str(test_data))
EXPERIMENT = HopkinsonExperiment(raw_data, test_data)

if __name__ == '__main__':
    print(EXPERIMENT)
