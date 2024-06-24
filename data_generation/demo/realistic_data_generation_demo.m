addpath ./data_generation
addpath ./data_generation/utils/

sampling_frequency = 5120;
signal_to_noise_ratio = 10;
random_state = []; % You can set this, in which case the signals will always look the same

% You can load the dataset instead of generating from scratch
dataset = Dataset.load();

if isempty(dataset) || true
    generator = RealisticGenerator(sampling_frequency, signal_to_noise_ratio, [], [], [], random_state);
    
    dataset = generator.generate_dataset(10, 0, 10);

    % Save dataset if needed (including the generator to save its parameters)
    dataset.save();

    % Alternatively, we can save the data only
    dataset.save_data()
end

dataset.plot()