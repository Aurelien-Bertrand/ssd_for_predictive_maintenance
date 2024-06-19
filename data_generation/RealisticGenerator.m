classdef RealisticGenerator
    properties (Constant, Access = private)
        ROTOR_RPM = [14 25]

        IMPULSE_PROBABILITY = 1
    end
    % TODO: try FFT after adding noise --> for testing check if FFT of cached signal and generated are the same for same seed
    % TODO: add simple faults and noise

    properties
        sampling_frequency
        signal_to_noise_ratio
        range_n_teeth
    end

    methods
        function obj = RealisticGenerator(sampling_frequency, signal_to_noise_ratio, range_n_teeth)
            if nargin < 3 || isempty(range_n_teeth) % TODO: find realistic values with article!
                range_n_teeth = [90 130];
            end
            obj.sampling_frequency = sampling_frequency;
            obj.signal_to_noise_ratio = signal_to_noise_ratio;
            obj.range_n_teeth = range_n_teeth;
        end

        % Start_time and end_time are assumed to be in seconds
        function dataset = generate_dataset(obj, num_signals, start_time, end_time)
            time = start_time:1/obj.sampling_frequency:end_time;
            signals = zeros(num_signals, length(time));
            fault_flags = false(num_signals, 1);
            
            % parfor i = 1:num_signals
            for i = 1:num_signals
                % Compute random carrier frequency, based on rotor rpm and convert to Hz
                carrier_frequency = unifrnd(obj.ROTOR_RPM(1), obj.ROTOR_RPM(2)) / 60;

                % Generate a wind turbine with random characteristics and its signal for a given time
                wind_turbine = WindTurbine(carrier_frequency, obj.range_n_teeth);
                disp(wind_turbine)

                % Generate a signal from the wind turbine, and add faults and noise
                signal = wind_turbine.generate_signal(time);
                signal = obj.add_faults_to_signal(signal);
                signal = obj.add_noise_to_signal(signal);

                signals(i, :) = signal;
            end

            dataset = Dataset(obj, time, signals, fault_flags);
            disp("Data generated")
        end
    end

    methods (Access = private)
        function truncated_signal = truncate_signal(obj, signal, is_impulse)
            start = randi([0, length(signal)]);
            truncated_signal = signal;
            if nargin < 3 || isempty(is_impulse) || ~is_impulse
                value_to_replace = 0;
            else
                value_to_replace = 1;
            end
            truncated_signal(1:start) = value_to_replace;
        end

        function impulse_signal = generate_impulse(obj, signal)
            impulse_strength = unifrnd(1, 2);

            n = length(signal);
            step_size = randi([floor(n / 30), floor(n / 15)]);

            impulse_signal = ones(1, n);
            impulse_signal(1:step_size:n) = impulse_strength;
            impulse_signal = obj.truncate_signal(impulse_signal, true);
        end

        function [faulty_signal, flag] = generate_simple_faults(obj, signal)
            faulty_signal = signal;
            flag = false;

            if rand() < obj.IMPULSE_PROBABILITY
                faulty_signal = signal .* obj.generate_impulse(signal);
                flag = true;
            end
        end

        function [faulty_signal, flag] = generate_realistic_faults(obj, signal)
            faulty_signal = signal;
            flag = false;
            % TODO
        end

        function [faulty_signal, flag] = add_faults_to_signal(obj, signal, use_realistic_faults)
            if nargin < 3 || isempty(use_realistic_faults) || ~use_realistic_faults
                [faulty_signal, flag] = obj.generate_simple_faults(signal);
            else
                [faulty_signal, flag] = obj.generate_realistic_faults(signal);
            end
        end

        function noisy_signal = add_noise_to_signal(obj, signal)
            if obj.signal_to_noise_ratio == 0
                noisy_signal = signal;
                return
            end
        
            signal_power = rms(signal)^2;
            noise_power = signal_power / (10^(obj.signal_to_noise_ratio / 10));
            
            white_noise = randn(size(signal));
            white_noise = white_noise * sqrt(noise_power / rms(white_noise)^2);
            
            red_noise = cumsum(randn(size(signal)));
            red_noise = red_noise * sqrt(noise_power / rms(red_noise)^2);
            
            noise = white_noise + red_noise;
            
            noisy_signal = signal + noise;
        end
    end
end