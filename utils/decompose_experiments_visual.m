addpath('./singular_spectrum_decomposition/');
addpath('./plotting/');

data_healthy = readmatrix('./experiments/simple/Noise0/fault_impulse/data_healthy.csv');
data_faulty = readmatrix('./experiments/simple/Noise0/fault_impulse/data_faulty.csv');
% data = readmatrix('./experiments/simple/Noise10/fault_extra/data_noisy.csv');
% data = readmatrix('./experiments/simple/Noise10/fault_extra/data_faulty.csv');


i = 5;

signal_healthy = data_healthy(i, 1:1000);  % Extract the ith signal (row)

% Do SSD decomposition
signal_healthy_components = SSD(signal_healthy, 1000);

% Find the residual
sum_components = sum(signal_healthy_components, 1);  % Sum all the components
residual = signal_healthy - sum_components;
signal_healthy_components = [signal_healthy_components; residual];


signal_faulty = data_faulty(i, 1:1000);  % Extract the ith signal (row)
plot(signal_faulty)
% Do SSD decomposition
signal_faulty_components = SSD(signal_faulty, 2560);

% Find the residual
sum_components = sum(signal_faulty_components, 1);  % Sum all the components
residual = signal_faulty - sum_components;
signal_faulty_components = [signal_faulty_components; residual];

% Plot the components
plot_components_side_by_side(signal_healthy_components, signal_faulty_components)
% plot(signal)



% men = mean(n_components_list)
% med = median(n_components_list)
