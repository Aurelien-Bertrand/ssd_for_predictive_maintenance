function [numOfComps,meanPComp,varPComp,stftPComp,freqs] = keyFigsWindow(components,samp_freq,windowSize)
% Function to calculate key figures for the components that are the results
% of the SSD function. The results are ordered by decreasng frequency, that
% means the first mean corresponds to the result with the highest
% frequency.

% The given components need to be saved along the columns, e.g. the first
% column contains the first component.

    numOfComps = size(components,2);
    for i=1:numOfComps
        if i==7
            a=0;
        end
        comp = components(:,i);
        meanPComp(i) = mean(comp);
        varPComp(i) = var(comp);
        fs = double(samp_freq);
        w = windowSize;
        no = w / 2; % Overlap
        [s,freqs,t] = spectrogram(comp, w, no, [], samp_freq);
        stftPComp(:,i) = s;
    end
end