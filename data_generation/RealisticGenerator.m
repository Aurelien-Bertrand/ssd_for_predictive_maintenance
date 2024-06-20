classdef RealisticGenerator < DataGenerator
    properties (Constant, Access = private)
        ROTOR_RPM = [14 25]
    end
    % TODO: try FFT after adding noise --> for testing check if FFT of cached signal and generated are the same for same seed
    % TODO: if time left, make same turbine but with different rotational speed (just keep everything constant and change rotor RPM)
    % TODO: parse probability of faults here (same for simple generator)

    properties
        range_n_teeth
    end

    methods
        function obj = RealisticGenerator(sampling_frequency, signal_to_noise_ratio, range_n_teeth)
            if nargin < 3 || isempty(range_n_teeth) % TODO: find realistic values with article!
                range_n_teeth = [90 130];
            end
            obj@DataGenerator(sampling_frequency, signal_to_noise_ratio);
            obj.range_n_teeth = range_n_teeth;
        end

        function dataset = generate_dataset(obj, num_signals, start_time, end_time)
            time = obj.generate_time_vector(start_time, end_time);
            signals = zeros(num_signals, length(time));
            fault_types = zeros(num_signals, 1);

            % parfor i = 1:num_signals
            for i = 1:num_signals
                signal = obj.generate_signal(time);
                [signal, fault_type] = obj.add_noise_and_faults_to_signal(signal, time);
                signals(i, :) = signal;
                fault_types(i) = fault_type;
            end
            dataset = Dataset(obj, time, signals, fault_types);
            disp("Data generated")
        end
    end

    methods (Access = private)
        function signal = generate_signal(obj, time)
            % Compute random carrier frequency, based on rotor rpm and convert to Hz
            carrier_frequency = unifrnd(obj.ROTOR_RPM(1), obj.ROTOR_RPM(2)) / 60;

            % Generate a wind turbine with random characteristics and its signal for a given time
            wind_turbine = WindTurbine(carrier_frequency, obj.range_n_teeth);

            % Generate a signal from the wind turbine, and add faults and noise
            signal = wind_turbine.generate_signal(time);
        end
    end
end