function plot_raw_signals(time, signals)
    n = size(signals, 1);
    
    figure;
    sgtitle("Raw signals");
    for i = 1:n
        subplot(n, 1, i)
        plot(time, signals(i, :))
        title(["Signal ", num2str(i)]);
    end
end