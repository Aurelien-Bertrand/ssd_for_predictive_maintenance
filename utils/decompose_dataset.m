addpath('./singular_spectrum_decomposition/');
addpath('./plotting/');
data = readmatrix('./NeuralNet/data/test.csv');

p = 100;
[m, ~] = size(data);

% Preallocate the processed_data matrix
% Assuming each signal can have at most 11 components
max_components = 11;
num_columns = 1002; % 1 for index, 1000 for component, 1 for target
processed_data = zeros(m * max_components, num_columns);

row_index = 1;

tic;
for i = 1:m
    
    signal = data(i, 1:1000);  % Extract the ith signal (row)
    target = data(i, 1001);    % Extract the class of the ith signal

    % Do SSD decomposition
    % signal_components = SSD(signal, 1000, 0.01, 10);
    signal_components = rSSD(signal, 1000, 0.01, 10);

    % Find the residual
    sum_components = sum(signal_components, 1);  % Sum all the components
    residual = signal - sum_components;
    signal_components = [signal_components; residual];

    % Plot the components
    % plot_components(signal_components)

    num_components = size(signal_components, 1);

    % For each component
    for j = 1:num_components
        component = signal_components(j, :);

        % Choose FFT size and calculate spectrum
        % Nfft = 1000;
        % fsamp = 1000;
        % [Pxx, f] = pwelch(component, gausswin(Nfft), Nfft/2, Nfft, fsamp);
    
        % Get frequency estimate (spectral peak)
        % [~, loc] = max(Pxx);
        % freq = f(loc);

        % Append to preallocated matrix
        processed_data(row_index, :) = [i, component, target];
        row_index = row_index + 1;
    end
end
toc;

% Remove any unused preallocated rows
processed_data = processed_data(1:row_index-1, :);

data_table = array2table(processed_data);
size(data_table);
% Save table to CSV file
path = './NeuralNet/data/zzzz.csv'; 
writetable(data_table, path);