addpath ./data_generation
addpath ./data_generation/utils

num_components_range = [1 10];
sampling_frequency = 2560;
frequency_range = [1 100];
amplitude_range = [1 5];
phase_range = [0 1];
signal_to_noise_ratio = 0;
random_state = []; % You can set this, in which case the signals will always look the same
intermittent_prob = 0.33;
combined_prob = 0.33;
allow_intermittent = true;
allow_combined = true;
allow_multiple_intermittent = true;
allow_multiple_combined = true;

additional_component_frequency_range = [300 600];

% You can load the dataset instead of generating from scratch
dataset = Dataset.load();

if isempty(dataset) || true
    disp("Generating data...")
    generator = SimpleGenerator(...
        num_components_range,...
        sampling_frequency,...
        frequency_range,...
        amplitude_range,...
        phase_range,...
        signal_to_noise_ratio,...
        intermittent_prob,...
        combined_prob,...
        allow_intermittent,...
        allow_combined,...
        allow_multiple_intermittent,...
        allow_multiple_combined,...
        [],... % impulse prob
        additional_component_frequency_range,...
        [],... % additional component prob
        random_state...
    );
    dataset = generator.generate_dataset(10, 0, 1);

    % Save dataset if needed (including the generator to save its parameters)
    dataset.save();

    % Alternatively, we can save the data only
    dataset.save_data();
    dataset.fault_types;
    
end

% dataset.plot()