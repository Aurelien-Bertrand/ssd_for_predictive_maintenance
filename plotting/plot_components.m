function plot_components(components)
    t = 1:1000;
    components = [components; residual];
    figure;
    hold on;
    for i = 1:11
        subplot(11, 1, i);
        plot(t, components(i, :));
        title(['Series ' num2str(i)]);
        xlabel('Time');
        ylabel('Value');
    end
    xlabel('Time');
    ylabel('Value');
    title('10 Time Series Plot');
    legend('Series 1', 'Series 2', 'Series 3', 'Series 4', 'Series 5', 'Series 6', 'Series 7', 'Series 8', 'Series 9', 'Series 10');
    hold off;
end