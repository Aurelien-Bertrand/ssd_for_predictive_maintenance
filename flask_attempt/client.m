url = 'http://127.0.0.1:5000/predict';
signal = randn(1000, 1);

% Convert the array to a JSON string
jsonData = jsonencode(struct('array', signal));

% Set the options for the webwrite function
options = weboptions('MediaType', 'application/json');

% Send the JSON data to the Flask server
response = webwrite(url, jsonData, options);

disp(response.result)
