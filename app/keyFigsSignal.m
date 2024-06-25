function [numOfComps_sig,meanPComp_sig,varPComp_sig,stftPComp_sig,freqs,faultDetectFlags] = keyFigsSignal(signal, windowSize, stepSize, sampFreq, thresh, getFaultDetection)
    if windowSize~=1000 && getFaultDetection
        warndlg('You can only use fault detection for a window length of 1000.')
    else
        maxNumComps = 1; % calculate number of plots iteratively

        meanPComp_sig = NaN(1,1); % mean per component
        varPComp_sig = NaN(1,1); % variance per component
        stftPComp_sig = cell(1,1); % stft per component, we get one matrix per component

        meanRes_sig = NaN(1,1); % mean of residual
        varRes_sig = NaN(1,1); % variance of residual
        stftRes_sig = cell(1,1); % stft of residual
        faultDetectFlags = [];
        numOfComps_sig = [];

        [m,n] = size(signal);
        end_idx = int32(floor((m - windowSize) / stepSize)) + 1;

        f = waitbar(0,'1','Name','Analysing Signal');
        
        for k=1:end_idx
            waitbar(double(k)/double(end_idx),f,'Processing Analysis...');
            start_win = 1+int32((k-1) * stepSize);
            end_win = int32(start_win + windowSize)-1;
            data = signal(start_win:end_win,:);

            comps = SSD(data, sampFreq, thresh); 
            comps = comps.';

            % calculate the values per window
            [numOfComps,meanPComp,varPComp,stftPComp,freqs] = keyFigsWindow(comps,sampFreq, windowSize);
            numOfComps_sig(k) = numOfComps;
            if numOfComps > maxNumComps 
                diff = numOfComps - maxNumComps;
                % if one window has more components than the
                % previous ones, add NaN rows
                numDP = size(meanPComp_sig,2);
                nanVecHor = NaN(diff, numDP);
                zeroMat = zeros(length(freqs),numDP);

                % add NaN rows
                meanPComp_sig(maxNumComps+1:numOfComps,:) = nanVecHor;
                varPComp_sig(maxNumComps+1:numOfComps,:) = nanVecHor;

                % add zero matrices for stft for new components
                for l=maxNumComps:1:numOfComps
                    stftPComp_sig{l} = zeroMat;
                end

                maxNumComps = numOfComps;
            end

            nanVecVert = NaN(maxNumComps, 1);

            % add NaN column at the end
            meanPComp_sig(:,k) = nanVecVert;
            varPComp_sig(:,k) = nanVecVert;

            % fill with values
            meanPComp_sig(1:numOfComps,k) = meanPComp(1:numOfComps);
            varPComp_sig(1:numOfComps,k) = varPComp(1:numOfComps);
            for l = 1:1:maxNumComps
                if l <= numOfComps
                    % if component with index n exists, add frequencys to the
                    % matrix
                    stftPComp_sig{l} = [stftPComp_sig{l} stftPComp(:,l)];
                else
                    stftPComp_sig{l} = [stftPComp_sig{l} zeros(size(stftPComp,1),1)];
                end
            end

            meanRes_sig(k) = meanPComp(end);
            varRes_sig(k) = varPComp(end);

            stftRes_sig{1} = [stftRes_sig{1} stftPComp(:,end)];
            
            % if fault detection is activated, get the response
            % from the NN
            if getFaultDetection
                faultDetectFlags(k) = faultDetectionWindow(data);
            end
                       
        end
        meanPComp_sig(end+1,:) = meanRes_sig;
        varPComp_sig(end+1,:) = varRes_sig;
        stftPComp_sig{end+1} = stftRes_sig{1};
        close(f)
    end
end