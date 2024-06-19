% TODO: could use a 0.5Hz sampling interval and a 10-minute averaging interval
% TODO: somehow relate to SCADA - so 10 minutes averages?

addpath ./utils/
addpath ./data_generation/

WINDOW_SIZE = 1000; % Size of the window
SAMPLING_FREQUENCY = 5120; % Amount of samples per second
SIGNAL_TO_NOISE_RATIO = 0;

number_of_hours = 0.2;
total_number_of_seconds = number_of_hours * 60 * 60;

total_samples = total_number_of_seconds * SAMPLING_FREQUENCY;
time = linspace(0, total_number_of_seconds, total_samples);

generator = RealisticGenerator(SAMPLING_FREQUENCY, SIGNAL_TO_NOISE_RATIO);
model = get_maintain_network(2);

for i = 1:WINDOW_SIZE:length(time)-WINDOW_SIZE+1
    window_time = time(i:i+WINDOW_SIZE-1);
    
    start_time = secondsToHMS(window_time(1));
    end_time = secondsToHMS(window_time(end));
    
    data = generator.generate_dataset(1, window_time);
    fault = string(model.predict(data.signals));

    disp(['Window Start Time: ' start_time ', End Time: ' end_time ', Predicted fault: ' fault]);
end

function timeString = secondsToHMS(seconds)
    hours = floor(seconds / 3600);
    minutes = floor(mod(seconds, 3600) / 60);
    seconds = mod(seconds, 60);
    
    timeString = sprintf('%02d:%02d:%02.0f', hours, minutes, seconds);
end
