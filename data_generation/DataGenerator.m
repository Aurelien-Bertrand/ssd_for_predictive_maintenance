classdef DataGenerator < handle
    properties
        sampling_frequency
        signal_to_noise_ratio  % Signal power x times the noise power
        random_state
    end
    
    methods
        function obj = DataGenerator(...
            sampling_frequency,...
            signal_to_noise_ratio,...
            random_state...
        )
            if nargin < 3 || isempty(random_state)
                random_state = [];
            end
            obj.sampling_frequency = sampling_frequency;
            obj.signal_to_noise_ratio = signal_to_noise_ratio;
            obj.random_state = random_state;
        end

        function time = generate_time_vector(obj, start_time, end_time)
            time = start_time:1/obj.sampling_frequency:end_time;
        end

        function [noisy_and_faulty_signal, fault_type] = add_noise_and_faults_to_signal(obj, signal, time)
            [faulty_signal, fault_type] = obj.add_faults_to_signal(signal, time);
            noisy_and_faulty_signal = obj.add_noise_to_signal(faulty_signal);
        end
    end

    methods (Access = private)
        function noisy_signal = add_noise_to_signal(obj, signal)
            if obj.signal_to_noise_ratio == 0
                noisy_signal = signal;
                return
            end
            signal_power = mean(signal.^2);
            noise_power = signal_power / obj.signal_to_noise_ratio;
            noise = sqrt(noise_power) * randn(size(signal));
            % Randomly choose between white (outside if) and red (inside if) noise
            if rand() <= 0.5
                noise = cumsum(noise);
                noise = noise / std(noise);
                noise = sqrt(noise_power) * noise;
            end
            noisy_signal = signal + noise;
        end
    end

    methods (Abstract)
        dataset = generate_dataset(obj, num_signals, start_time, end_time) % Start_time and end_time are assumed to be in seconds
        signal = generate_signal(obj, time)
        [faults, specific_fault_type] = add_faults_to_signal(obj, signal, time)
    end
end