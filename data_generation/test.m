num_signals = 10; % TODO: how many signals you want to process at once
num_data_points = 1000;
num_components_range = [5 5]; % TODO: play with this
sampling_freq = 1000; % TODO: check realistic values -- for us
freq_range = [2 100]; % TODO: check realistic values -- for us
amplitude_range = [1 5]; % TODO: check realistic values -- for us
phase_range = [0 1]; % TODO: check realistic values -- for us
random_state = 101;
intermittent_prob = 0.33; % TODO: play with this
combined_prob = 0.33; % TODO: play with this
allow_intermittent = true; % TODO: play with this
allow_combined = true; % TODO: play with this
allow_multiple_intermittent = true;
allow_multiple_combined = true;

% TODO: 1. stack e.g., 5 base signals and then introduce one at 500 with high frequency --> check if we can detect it
% TODO: 1. signal-to-noise ratio
% TODO: 2. add impulses and noise
% TODO: 3. try out different types of faults and make a table on how they affect the components
% TODO: 4. make the algorithm online (constantly generating and analysing data)

obj = Generator(num_signals, num_data_points, num_components_range, sampling_freq, freq_range, amplitude_range, phase_range, random_state, intermittent_prob, combined_prob, allow_intermittent, allow_combined, allow_multiple_intermittent, allow_multiple_combined);
[components, signals] = obj.generate_dataset([500 500]);

figure;
for i = 1:num_signals
    subplot(num_signals, 1, i)
    plot(signals(i, :))
    title(['Signal ', num2str(i)]);
end
