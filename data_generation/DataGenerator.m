classdef DataGenerator
    properties
        sampling_frequency
        signal_to_noise_ratio  % Signal power x times the noise power
        random_state
    end

    properties (Access = private)
        impulse_probability
        fault_probability
    end

    methods
        function obj = DataGenerator(...
            sampling_frequency,...
            signal_to_noise_ratio,...
            impulse_probability,...
            fault_probability,...
            random_state...
        )
            if nargin < 5 || isempty(random_state)
                random_state = [];
            end
            obj.sampling_frequency = sampling_frequency;
            obj.signal_to_noise_ratio = signal_to_noise_ratio;
            obj.impulse_probability = impulse_probability;
            obj.fault_probability = fault_probability;
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
    
    methods (Abstract)
        % Start_time and end_time are assumed to be in seconds
        dataset = generate_dataset(obj, num_signals, start_time, end_time)

        [faults, specific_fault_type] = generate_specific_faults(obj, time)
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

        % TODO: here, impulse strength and specific faults should be worse over time!
        function [faulty_signal, fault_type] = add_faults_to_signal(obj, signal, time, fault_flag)
            if nargin < 4 || isempty(fault_flag)
                fault_flag = false;
            end
            faulty_signal = signal;
            fault_type = FaultTypes.HEALTHY;
            if fault_flag || rand() <= obj.impulse_probability
                faulty_signal = signal + generate_impulse(length(signal));
                fault_type = FaultTypes.IMPULSE;
            end
            if fault_flag || rand() <= obj.fault_probability
                [faults, specific_fault_type] = obj.generate_specific_faults(time);
                faulty_signal = faulty_signal + faults;
                fault_type = obj.update_fault_type(fault_type, specific_fault_type);
            end
        end

        function fault_type = update_fault_type(obj, previous_fault_type, new_fault_type)
            if previous_fault_type == FaultTypes.HEALTHY
                fault_type = new_fault_type;
            elseif previous_fault_type == FaultTypes.IMPULSE
                if new_fault_type == FaultTypes.ADDITIONAL_COMPONENT
                    fault_type = FaultTypes.IMPULSE_AND_ADDITIONAL_COMPONENT;
                elseif new_fault_type == FaultTypes.FREQUENCY_MODULATION
                    fault_type = FaultTypes.IMPULSE_AND_FREQUENCY_MODULATION;
                elseif new_fault_type == FaultTypes.AMPLITUDE_MODULATION
                    fault_type = FaultTypes.IMPULSE_AND_AMPLITUDE_MODULATION;
                elseif new_fault_type == FaultTypes.FREQUENCY_AND_AMPLITUDE_MODULATION
                    fault_type = FaultTypes.IMPULSE_AND_FREQUENCY_AND_AMPLITUDE_MODULATION;
                end
            else
                error("Faut type %s not suported", previous_fault_type)
            end
        end
    end
end