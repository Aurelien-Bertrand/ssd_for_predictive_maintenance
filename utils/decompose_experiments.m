addpath('./singular_spectrum_decomposition/');
addpath('./plotting/');

% data = readmatrix('./experiments/simple/Noise10/fault_impulse/data_noisy.csv');
data = readmatrix('./experiments/simple/Noise10/fault_impulse/data_faulty.csv');
% data = readmatrix('./experiments/simple/Noise10/fault_extra/data_noisy.csv');
% data = readmatrix('./experiments/simple/Noise10/fault_extra/data_faulty.csv');


p = 100;
[m, ~] = size(data);

n_components_list = [];

tic;
for i = 1:m
    
    signal = data(i, 1:1000);  % Extract the ith signal (row)

    % Do SSD decomposition
    signal_components = SSD(signal, 2560);

    % Find the residual
    sum_components = sum(signal_components, 1);  % Sum all the components
    residual = signal - sum_components;
    % signal_components = [signal_components; residual];

    % Plot the components
    % plot_components(signal_components)
    % plot(signal)
    num_components = size(signal_components, 1);
    n_components_list = [n_components_list, num_components];
end
toc;

men = mean(n_components_list)
med = median(n_components_list)
