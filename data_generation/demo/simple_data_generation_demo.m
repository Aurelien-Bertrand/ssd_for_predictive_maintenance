addpath ./data_generation
addpath ./data_generation/utils

num_signals = 1;
num_components_range = [1 1];
sampling_frequency = 1000;
frequency_range = [2 100];
amplitude_range = [1 5];
phase_range = [0 1];
signal_to_noise_ratio = 0;
random_state = 101;
intermittent_prob = 0;
combined_prob = 0;
allow_intermittent = false;
allow_combined = false;
allow_multiple_intermittent = false;
allow_multiple_combined = false;

additional_component_frequency_range = [500 500];

% You can load the dataset instead of generating from scratch
dataset = Dataset.load();

if isempty(dataset)
    disp("Generating data...")
    generator = SimpleGenerator(...
        num_components_range,...
        sampling_frequency,...
        frequency_range,...
        amplitude_range,...
        phase_range,...
        signal_to_noise_ratio,...
        random_state,...
        intermittent_prob,...
        combined_prob,...
        allow_intermittent,...
        allow_combined,...
        allow_multiple_intermittent,...
        allow_multiple_combined,...
        additional_component_frequency_range...
    );

    dataset = generator.generate_dataset(10, 0, 1);

    % Save dataset if needed (including the generator to save its parameters)
    % dataset.save();

    % Alternatively, we can save the data only
    % dataset.save_data()
end

dataset.plot()