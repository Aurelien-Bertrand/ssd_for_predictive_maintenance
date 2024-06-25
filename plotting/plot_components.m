function plot_components(components)
    t = 1:1000;
    components = [components; residual];
    figure;
    hold on;
    for i = 1:11
        subplot(11, 1, i);
        plot(t, components(i, :));
        title(['Series ' num2str(i)]);
    length(components)
    % Plot each time series
    for i = 1:size(components, 1)
        subplot(11, 1, i);  % Create a subplot grid of 10 rows and 1 column, and select the ith subplot
        plot(t, components(i, :));  % Plot the ith time series
        title(['Series ' num2str(i)]);  % Title each subplot
        xlabel('Time');
        ylabel('Value');
    end
    xlabel('Time');
    ylabel('Value');
    title('10 Time Series Plot');
    legend('Series 1', 'Series 2', 'Series 3', 'Series 4', 'Series 5', 'Series 6', 'Series 7', 'Series 8', 'Series 9', 'Series 10');
    hold off;
end