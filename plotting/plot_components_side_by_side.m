function plot_components_side_by_side(components1, components2)
    % Assuming components1 and components2 are matrices where each row is a time series signal
    num_series1 = size(components1, 1);  % Number of time series signals in components1
    num_series2 = size(components2, 1);  % Number of time series signals in components2
    t = 1:size(components1, 2);  % Assuming time indices if not provided in t
    
    % Create a new figure
    figure;
    
    % Plot for components1
    subplot(num_series1, 2, 1*2-1);  % 2 columns for each set, first column for components1
    plot(t, components1(1, :));  % Plot the i-th time series signal from components1
    title('Healthy Signal');  % Title for each subplot
    % xlabel('Time');  % X-axis label
    xticks([]);
    ylabel('Amplitude');  % Y-axis label

    for i = 2:num_series1-1
        subplot(num_series1, 2, i*2-1);  % 2 columns for each set, first column for components1
        plot(t, components1(i, :));  % Plot the i-th time series signal from components1
        title(['Component ' num2str(i-1)]);  % Title for each subplot
        % xlabel('Time');  % X-axis label
        xticks([]);
        ylabel('Amplitude');  % Y-axis label
    end

    subplot(num_series1, 2, num_series1*2-1);  % 2 columns for each set, first column for components1
    plot(t, components1(num_series1, :));  % Plot the i-th time series signal from components1
    title('Residual');  % Title for each subplot
    % xlabel('Time');  % X-axis label
    xticks([]);
    ylabel('Amplitude');  % Y-axis label
    


    % Plot for components2
    subplot(num_series2, 2, 1*2);  % 2 columns for each set, second column for components2
    plot(t, components2(1, :));  % Plot the i-th time series signal from components2
    title('Faulty Signal');  % Title for each subplot
    % xlabel('Time');  % X-axis label
    xticks([]);
    ylabel('Amplitude');  % Y-axis label

    for i = 2:num_series2-1
        subplot(num_series2, 2, i*2);  % 2 columns for each set, second column for components2
        plot(t, components2(i, :));  % Plot the i-th time series signal from components2
        title(['Component ' num2str(i-1)]);  % Title for each subplot
        % xlabel('Time');  % X-axis label
        xticks([]);
        ylabel('Amplitude');  % Y-axis label
    end

    subplot(num_series2, 2, num_series2*2);  % 2 columns for each set, second column for components2
    plot(t, components2(num_series2, :));  % Plot the i-th time series signal from components2
    title('Residual');  % Title for each subplot
    % xlabel('Time');  % X-axis label
    xticks([]);
    ylabel('Amplitude');  % Y-axis label
    
    sgtitle('SSD Components of Signal with and without Component Fault');  % Overall title for the entire figure
end