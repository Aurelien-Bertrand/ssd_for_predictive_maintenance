classdef RealisticGenerator < DataGenerator
    properties (Constant, Access = private)
        ROTOR_RPM = [14 25]
    end
    
    properties
        range_n_teeth
        impulse_probability
        fault_probability
        wind_turbine
    end

    properties (SetAccess = private)
        use_persistent_faults
        impulse_flag
        fault_flag
        impulse_strength
    end

    methods
        function obj = RealisticGenerator(...
            sampling_frequency,...
            signal_to_noise_ratio,...
            range_n_teeth,...
            impulse_probability,...
            fault_probability,...
            random_state,...
            use_persistent_faults...
        )
            if nargin < 3 || isempty(range_n_teeth)
                range_n_teeth = [90 130];
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
            if nargin < 7 || isempty(use_persistent_faults)
                use_persistent_faults = false;
            end

            obj@DataGenerator(sampling_frequency, signal_to_noise_ratio, random_state);
            obj.range_n_teeth = range_n_teeth;
            obj.impulse_probability = impulse_probability;
            obj.fault_probability = fault_probability;
            obj.use_persistent_faults = use_persistent_faults;
            obj.wind_turbine = [];
            obj.impulse_flag = false;
            obj.fault_flag = false;
            obj.impulse_strength = 0;

            if ~isempty(obj.random_state)
                rng(obj.random_state);
            end
        end

        function dataset = generate_dataset(obj, num_signals, start_time, end_time)
            time = obj.generate_time_vector(start_time, end_time);
            healthy_signals = zeros(num_signals, length(time));
            faulty_signals = zeros(num_signals, length(time));
            noisy_signals = zeros(num_signals, length(time));
            fault_types = zeros(num_signals, 1);

            for i = 1:num_signals
                healthy_signal = obj.generate_signal(time);
                [faulty_signal, fault_type] = obj.add_noise_and_faults_to_signal(healthy_signal, time);
                noisy_signal = obj.add_noise_to_signal(healthy_signal);

                healthy_signals(i, :) = healthy_signal;
                faulty_signals(i, :) = faulty_signal;
                noisy_signals(i, :) = noisy_signal;
                fault_types(i) = fault_type;
            end
            dataset = Dataset(obj, time, healthy_signals, faulty_signals, noisy_signals, fault_types);
        end

        function signal = generate_signal(obj, time)
            % Generate a faultless signal from the wind turbine
            obj.get_or_generate_wind_turbine();
            signal = obj.wind_turbine.generate_signal(time, 0, 0);
        end

        function [faulty_signal, fault_type] = add_faults_to_signal(obj, signal, time)
            faulty_signal = signal;
            fault_type = FaultTypes.HEALTHY;
            
            if obj.use_persistent_faults
                rng("shuffle")
            end
            if obj.fault_flag || rand() <= obj.fault_probability
                if obj.use_persistent_faults
                    obj.fault_flag = true;
                end
                faulty_signal = obj.wind_turbine.generate_signal(time);
                specific_fault_type = obj.wind_turbine.get_fault_type();
                fault_type = update_fault_type(fault_type, specific_fault_type);
            end
            if obj.use_persistent_faults
                rng("shuffle")
            end
            if obj.impulse_flag || rand() <= obj.impulse_probability
                if obj.use_persistent_faults
                    obj.impulse_flag = true;
                end
                [impulse_signal, impulse_strength] = generate_impulse(length(signal), obj.random_state, obj.impulse_strength);
                if obj.use_persistent_faults
                    obj.impulse_strength = impulse_strength;
                end
                faulty_signal = faulty_signal + impulse_signal;
                specific_fault_type = FaultTypes.IMPULSE;
                fault_type = update_fault_type(fault_type, specific_fault_type);
            end
        end
    end

    methods (Access = private)
        function wind_turbine = get_or_generate_wind_turbine(obj)
            if isempty(obj.wind_turbine) || ~obj.use_persistent_faults
                obj.wind_turbine = obj.create_new_wind_turbine();
            end
            wind_turbine = obj.wind_turbine;
        end

        function wind_turbine = create_new_wind_turbine(obj)
            % Compute random carrier frequency, based on rotor rpm and convert to Hz
            carrier_frequency = 0.159155 * 2 * pi * unifrnd(obj.ROTOR_RPM(1), obj.ROTOR_RPM(2)) / 60;

            % Generate a wind turbine with random characteristics and its signal for a given time
            wind_turbine = WindTurbine(carrier_frequency, obj.range_n_teeth, obj.random_state, obj.use_persistent_faults);
        end
    end
end