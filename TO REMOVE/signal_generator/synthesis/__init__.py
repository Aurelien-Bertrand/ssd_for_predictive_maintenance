from .generator import Generator

default_params = {
    "num_signals": 500,
    "num_components_range": (1, 4),
    "num_data_points": 1000,
    "random_state": None,
    "sampling_freq": 1000,
    "freq_range": (2, 100),
    "amplitude_range": (1, 5),
    "phase_range": (0, 1),
    "intermittent_prob": 0.33,
    "combined_prob": 0.33,
    "allow_multiple_intermittent": False,
    "allow_multiple_combined": False,
}

def get_generator(**params):
    merged_params = {**default_params, **params}
    return Generator(**merged_params)