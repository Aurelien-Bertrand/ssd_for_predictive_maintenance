addpath ../data_generation

% TODO: train model on this data and evaluate using real data

sampling_frequency = 2560;
signal_to_noise_ratio = 0;
rotor_speed_range = [9000/10 9000/10]; % This makes carrier frequency of 10/3

% You can load the dataset instead of generating from scratch
dataset = Dataset.load();

if isempty(dataset)
    generator = RealisticGenerator(...
        sampling_frequency,...
        signal_to_noise_ratio,...
        rotor_speed_range...
    );

    dataset = generator.generate_dataset(10, 0, 1);

    % Save dataset if needed (including the generator to save its parameters)
    dataset.save();

    % Alternatively, we can save the data only
    dataset.save_data()
end

dataset.plot()