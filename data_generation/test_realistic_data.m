sampling_frequency = 2560;
n_teeths_by_gear = [99 21 38 95 21 123 25];
carrier_frequency = 10/3;
signal_to_noise_ratio = 0.5;


% You can load the dataset instead of generating from scratch
dataset = Dataset.load();

if isempty(dataset)
    disp("Generating data")

    generator = RealisticGenerator(...
        sampling_frequency,...
        n_teeths_by_gear,...
        carrier_frequency,...
        signal_to_noise_ratio...
    );

    dataset = generator.generate_dataset(10, 0, 1);

    % Save dataset if needed (including the generator to save its parameters)
    dataset.save();

    % Alternatively, we can save the data only
    dataset.save_data()
end

dataset.plot()