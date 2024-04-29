function plot_raw_signals(signals)
    n = size(signals, 1);
    xs = 1:size(signals, 2);

    figure;
    sgtitle("Raw signals");
    for i = 1:n
        subplot(n, 1, i)
        plot(xs, signals(i, :))
        title(["Signal ", num2str(i)]);
    end
end