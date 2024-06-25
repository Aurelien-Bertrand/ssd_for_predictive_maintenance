function plot_components(components)
    % Assuming components is a matrix where each row is a time series signal
    num_series = size(components, 1);  % Number of time series signals
    t = 1:size(components, 2);  % Assuming time indices if not provided in t
    
    figure;  % Create a new figure
    
    for i = 1:num_series
        subplot(num_series, 1, i);  % Create subplot grid of num_series rows, 1 column, and select the i-th subplot
        plot(t, components(i, :));  % Plot the i-th time series signal
        title(['Series ' num2str(i)]);  % Title for each subplot
        xlabel('Time');  % X-axis label
        ylabel('Value');  % Y-axis label
    end
    
    sgtitle('Time Series Plot');  % Overall title for the entire figure
end