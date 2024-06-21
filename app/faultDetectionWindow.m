function [flag] = faultDetectionWindow(signal)

if(length(signal)~= 1000)
    warndlg('Fault detection is only possible for signals of length 1000!')
else
    % use url from server for NN classification
    url = 'http://127.0.0.1:5000/predict';
        
    try
        % Convert the array to a JSON string
        jsonData = jsonencode(struct('array', signal));
    
        % Set the options for the webwrite function
        options = weboptions('MediaType', 'application/json');
    
        % Send the JSON data to the Flask server
        response = webwrite(url, jsonData, options);
                        
        
        %turn on the fault detection lamp
        if strcmp(response.result, 'faulty')
        %       lamp = red 
            flag = true;
        else
        %       lamp = green
            flag = false;
        end
    
        % Process `response.result` in MATLAB as needed
        % Update MATLAB UI with processed results as needed
    catch ME
        % Handle any errors that may occur during webwrite
        disp('Error occurred during webwrite:');
        disp(ME.message);
        warndlg('Failed to communicate with server.');
    end
end

end