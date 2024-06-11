addpath('./singular_spectrum_decomposition/');
addpath('./plotting/');
data = readmatrix('./NeuralNet/data/test.csv');

p = 100;
[m, ~] = size(data);
m = 10;
components = {};  % Each cell will hold the components of a signal
processed_data = [];

tic;
for i = 1:m
    
    signal = data(i, 1:1000);  % Extract the ith signal (row)
    target = data(i, 1001);  % Extract the class of the ith signal

    % Do SSD decomposition
    %signal_components = SSD(signal, 1000, 0.01, 10);
    signal_components = rSSD(signal, 1000, 0.01, 10);

    len = size(signal_components);
    % For each component
    for j = 1:len(1)
        component = signal_components(j,:);

        % Choose FFT size and calculate spectrum
        Nfft = 1000;
        fsamp = 1000;
        [Pxx,f] = pwelch(component,gausswin(Nfft),Nfft/2,Nfft,fsamp);
    
        % Get frequency estimate (spectral peak)
        [~,loc] = max(Pxx);
        freq = f(loc);

        % signal_components(j,:) = component;
        processed_data = [processed_data; i, component, freq, target];
    end
end
toc;

data = array2table(processed_data);
size(data);
% Save table to CSV file
path = './NeuralNet/data/test_processed.csv'; 
writetable(data, path)



% DONE
%   Decompose signals
%   Create new dataset with componenets
%   Components have signal_id, frequency, and class.

% TO DO
%   Save decomposed components
%   Append the frequency to each component
%   Find max amount of components (c_max)
%   Bin components into c_max bins
%   Find median of each bin

% TO DO TOO 
%   Match components to correct bins
%   Organize dataset based on bins