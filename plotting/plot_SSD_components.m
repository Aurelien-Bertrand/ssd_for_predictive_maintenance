function plot_SSD_components(frequencies, SSDcomponents)

n = size(SSDcomponents, 1);

for i = 1:n
    figure('Position', [100, 100, 800, 100]); % Adjust the position and size as needed
    plot(frequencies, SSDcomponents(i, :));
    title(['Component ', num2str(i)]);
end

end
