function [numOfComps_sig,meanPComp_sig,varPComp_sig,stftPComp_sig,freqs,faultDetectFlags] = keyFigsSignal(signal, windowSize, stepSize, sampFreq, thresh, getFaultDetection)
    if windowSize~=1000 && getFaultDetection
        warndlg('You can only use fault detection for a window length of 1000.')
    else
        faultDetectFlags = [];
        [m,n] = size(signal);
        end_idx = int32(floor((m - windowSize) / stepSize)) + 1;
        allMeanPComps = cell(1,end_idx);
        allVarPComps = cell(1,end_idx);
        allStftPComp = cell(1,end_idx);
        f = waitbar(0,'1','Name','Analysing Signal');
        for k=1:end_idx
            waitbar(double(k)/double(end_idx),f,'Processing Analysis...');
            start_win = 1+int32((k-1) * stepSize);
            end_win = int32(start_win + windowSize)-1;
            win = signal(start_win:end_win,:);
            comps = SSD(win, sampFreq, thresh);
            comps = comps.';
            [numOfComps,meanPComp,varPComp,stftPComp,freqs] = keyFigsWindow(comps,sampFreq, windowSize);
            numOfComps_sig(k) = numOfComps;
            allMeanPComps{k} = meanPComp;
            allVarPComps{k} = varPComp;
            allStftPComp{k} = stftPComp;
            if getFaultDetection
                faultDetectFlags(k) = faultDetectionWindow(win);
            end
        end

        maxNumComps = max(numOfComps_sig);
        
        meanPComp_sig = NaN(end_idx,maxNumComps);
        varPComp_sig = NaN(end_idx,maxNumComps);
        stftPComp_sig = cell(maxNumComps,1);
        for n=1:maxNumComps
            stftPComp_sig{n} = [];
        end
        for i=1:end_idx
            waitbar(double(i)/double(end_idx),f,'Cleaning Results...')
            meanPComp_sig(i,1:length(allMeanPComps{i})) = allMeanPComps{i};
            varPComp_sig(i,1:length(allVarPComps{i})) = allVarPComps{i};
            % get frequencies of window per component
            stftComps = allStftPComp{i};
    
            % add the components frequencies to frequency matrix
            for n=1:maxNumComps
                if n <= size(stftComps,2)
                    % if component with index n exists, add frequencys to the
                    % matrix
                    stftComp_temp = stftComps(:,n);
                    stftPComp_sig{n} = [stftPComp_sig{n} stftComp_temp];
                else
                    stftPComp_sig{n} = [stftPComp_sig{n} zeros(size(stftComps,1),1)];
                end
            end
        end
       close(f)
    end
end