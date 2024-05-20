function [numOfComps_sig,meanPComp_sig,varPComp_sig] = keyFigsSignal(signal, windowSize, stepSize, samp_freq, thresh)
    [m,n] = size(signal);
    end_idx = int32(floor((m - windowSize) / stepSize)) + 1;
    allMeanPComps = cell(1,end_idx);
    allVarPComps = cell(1,end_idx);
    f = waitbar(0,'1','Name','Analysing Signal');
    for k=1:end_idx
        waitbar(double(k)/double(end_idx),f,'Processing Analysis...');
        start_win = 1+int32((k-1) * stepSize);
        end_win = int32(start_win + windowSize)-1;
        win = signal(start_win:end_win,:);
        comps = SSD(win, samp_freq, thresh);
        comps = comps.';
        [numOfComps,meanPComp,varPComp] = keyFigsWindow(comps);
        numOfComps_sig(k) = numOfComps;
        allMeanPComps{k} = meanPComp;
        allVarPComps{k} = varPComp;
    end
    maxNumComps = max(numOfComps_sig);
    
    meanPComp_sig = NaN(end_idx,maxNumComps);
    varPComp_sig = NaN(end_idx,maxNumComps);

    for i=1:end_idx
        waitbar(double(i)/double(end_idx),f,'Cleaning Results...')
        meanPComp_sig(i,1:length(allMeanPComps{i})) = allMeanPComps{i};
        varPComp_sig(i,1:length(allVarPComps{i})) = allVarPComps{i};
    end

    close(f)
end