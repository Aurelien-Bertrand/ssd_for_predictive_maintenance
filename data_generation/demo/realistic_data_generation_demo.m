addpath ./data_generation
addpath ./plotting
addpath ./data_generation/utils/

sampling_frequency = 2560;
signal_to_noise_ratio = 0; % TODO: understand this

% You can load the dataset instead of generating from scratch
dataset = Dataset.load();

if isempty(dataset)
    generator = RealisticGenerator(sampling_frequency, signal_to_noise_ratio);
    
    dataset = generator.generate_dataset(10, 0, 1);

    % Save dataset if needed (including the generator to save its parameters)
    % dataset.save();

    % Alternatively, we can save the data only
    % dataset.save_data()
end

dataset.plot()