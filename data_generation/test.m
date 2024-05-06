addpath("plotting")

num_signals = 50000;
num_data_points = 1000;
num_components_range = [5 5]; % TODO: play with this
sampling_freq = 1000; % TODO: check realistic values -- for us
freq_range = [2 100]; % TODO: check realistic values -- for us
amplitude_range = [1 5]; % TODO: check realistic values -- for us
phase_range = [0 1]; % TODO: check realistic values -- for us
signal_to_noise_ratio = 0.1;
random_state = 101;
intermittent_prob = 0.33; % TODO: play with this
combined_prob = 0.33; % TODO: play with this
allow_intermittent = true; % TODO: play with this
allow_combined = true; % TODO: play with this
allow_multiple_intermittent = true;
allow_multiple_combined = true;

% TODO: try out different types of faults and make a table on how they affect the components
% TODO: make the algorithm online (constantly generating and analysing data)

obj = Generator(num_signals, num_data_points, num_components_range, sampling_freq, freq_range, amplitude_range, phase_range, signal_to_noise_ratio, random_state, intermittent_prob, combined_prob, allow_intermittent, allow_combined, allow_multiple_intermittent, allow_multiple_combined);
dataset = obj.generate_dataset([500 500]);

% Save dataset if needed
% dataset.save();


% Can load the dataset instead of generating from scratch
% dataset = Dataset.load();

% plot_raw_signals(dataset.signals)





% SAVING DATASET TO CSV

% Convert dataset to table
data = dataset.signals;
ys = dataset.fault_flags;
data = cat(2, data, ys);

data = array2table(data);

% Save table to CSV file
path = './NeuralNet/data.csv'; 
writetable(data, path);