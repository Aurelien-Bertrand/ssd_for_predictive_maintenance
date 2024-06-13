data = array2table(processed_data);
size(data);
% Save table to CSV file
path = './NeuralNet/data/test_processed.csv'; 
writetable(data, path)