classdef RealisticGenerator < DataGenerator
    properties (Constant, Access = private)
        ROTOR_RPM = [14 25]

        % Default probabilities
        IMPULSE_PROBABILITY = 0.01
        SPECIFIC_FAULT_PROBABILITY = 0.01
    end
    % TODO: future work, simulate wind to generate rotor RPM --> in report, mention that working condition of wind turbines are assumed to be constant
    % TODO: A and B random but should be worse (or same) next window
    properties
        range_n_teeth
    end

    methods
        function obj = RealisticGenerator(sampling_frequency, signal_to_noise_ratio, range_n_teeth, impulse_probability, fault_probability, random_state)
            if nargin < 3 || isempty(range_n_teeth)
                range_n_teeth = [90 130]; % TODO: mention this in report, this is assumed!
            end
            if nargin < 4 || isempty(impulse_probability)
                impulse_probability = 0.01;
            end
            if nargin < 5 || isempty(fault_probability)
                fault_probability = 0.001;
            end
            if nargin < 6
                random_state = [];
            end

            obj@DataGenerator(sampling_frequency, signal_to_noise_ratio, impulse_probability, fault_probability, random_state);
            obj.range_n_teeth = range_n_teeth;
        end

        function dataset = generate_dataset(obj, num_signals, start_time, end_time)
            time = obj.generate_time_vector(start_time, end_time);
            healthy_signals = zeros(num_signals, length(time));
            faulty_signals = zeros(num_signals, length(time));
            fault_types = zeros(num_signals, 1);

            % parfor i = 1:num_signals
            for i = 1:num_signals
                healthy_signal = obj.generate_signal(time);
                [faulty_signal, fault_type] = obj.add_noise_and_faults_to_signal(healthy_signal, time);
                
                healthy_signals(i, :) = healthy_signal;
                faulty_signals(i, :) = faulty_signal;
                fault_types(i) = fault_type;
            end
            dataset = Dataset(obj, time, healthy_signals, faulty_signals, fault_types);
            disp("Data generated")
        end

        function [faults, specific_fault_type] = generate_specific_faults(obj, time)
            faults = 0;
            specific_fault_type = 0;
        end
    end

    methods (Access = private)
        function signal = generate_signal(obj, time)
            if ~isempty(obj.random_state)
                rng(obj.random_state);
            end

            % Compute random carrier frequency, based on rotor rpm and convert to Hz
            carrier_frequency = unifrnd(obj.ROTOR_RPM(1), obj.ROTOR_RPM(2)) / 60;

            % Generate a wind turbine with random characteristics and its signal for a given time
            wind_turbine = WindTurbine(carrier_frequency, obj.range_n_teeth, obj.random_state);

            % Generate a signal from the wind turbine, and add faults and noise
            signal = wind_turbine.generate_signal(time);
        end
    end
end