function plot_components(components)
    % Generate some example data
    t = 1:1000; % Time vector
    components = [components; residual];
    % Create a new figure
    figure;
    
    % Hold the plot
    hold on;

    % Plot each time series
    for i = 1:11
        subplot(11, 1, i);  % Create a subplot grid of 10 rows and 1 column, and select the ith subplot
        plot(t, components(i, :));  % Plot the ith time series
        title(['Series ' num2str(i)]);  % Title each subplot
        xlabel('Time');
        ylabel('Value');
    end
    % plot(t, residual)
    % title(['Series ' num2str(11)]);  % Title each subplot
    % xlabel('Time');
    % ylabel('Value');

    % Add labels and title
    xlabel('Time');
    ylabel('Value');
    title('10 Time Series Plot');
    legend('Series 1', 'Series 2', 'Series 3', 'Series 4', 'Series 5', 'Series 6', 'Series 7', 'Series 8', 'Series 9', 'Series 10');
    
    % Release the hold
    hold off;
end