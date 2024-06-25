addpath ./data_generation/
addpath ./data_generation/utils/

sampling_frequency = 5120;
signal_to_noise_ratio = 10;
impulse_probability = 1;
fault_probability = 1;
random_state = 101;
range_n_teeth = [90 100];
start_time = 0;
end_time = 1;
use_persistent_faults = false;

generator = RealisticGenerator(...
    sampling_frequency,...
    signal_to_noise_ratio,...
    range_n_teeth,...
    impulse_probability,...
    fault_probability,...
    random_state,...
    use_persistent_faults...
)

data = generator.generate_dataset(1, start_time, end_time);

data.save("./_tests/_cache/realistic_dataset.mat")

            % save("./_tests/_cache/truncated_signal.m", "signal", "-v7.3");