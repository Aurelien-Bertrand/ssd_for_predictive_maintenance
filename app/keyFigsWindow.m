function [numOfComps,meanPComp,varPComp] = keyFigsWindow(components)
% Function to calculate key figures for the components that are the results
% of the SSD function. The results are ordered by decreasng frequency, that
% means the first mean corresponds to the result with the highest
% frequency.

% The given components need to be saved along the columns, e.g. the first
% column contains the first component.

    numOfComps = size(components,2);
    for i=1:numOfComps
        comp = components(i,:);
        meanPComp(i) = mean(comp);
        varPComp(i) = var(comp);
    end
end