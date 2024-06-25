classdef SimpleGenerator < DataGenerator
    properties (Constant, Access = private)
        MIN_FREQUENCY_DIFFERENCE = 0.1
        MAX_NARROW_FREQUENCY_DIFFERENCE = 0.5
    end
    
    properties
        num_components_range
        frequency_range
        amplitude_range
        phase_range
        intermittent_prob
        combined_prob
        allow_intermittent
        allow_combined
        allow_multiple_intermittent
        allow_multiple_combined
        additional_component_frequency_range
        impulse_probability
        fault_probability
    end

    properties (Access = private)
        use_persistent_faults
    end

    methods
        function obj = SimpleGenerator(...
            num_components_range,...
            sampling_frequency,...
            frequency_range,...
            amplitude_range,...
            phase_range,...
            signal_to_noise_ratio,...
            intermittent_prob,...
            combined_prob,...
            allow_intermittent,...
            allow_combined,...
            allow_multiple_intermittent,...
            allow_multiple_combined,...
            impulse_probability,...
            additional_component_frequency_range,...
            fault_probability,...
            random_state,...
            use_persistent_faults...
        )
            if nargin < 13 || isempty(impulse_probability)
                impulse_probability = 0;
            end
            if nargin < 14 || isempty(additional_component_frequency_range)
                additional_component_frequency_range = [];
            end 
            if nargin < 15 || isempty(fault_probability)
                fault_probability = 0;
            end
            if nargin < 16
                random_state = [];
            end
            if nargin < 17 || isempty(use_persistent_faults)
                use_persistent_faults = false;
            end
            
            obj@DataGenerator(sampling_frequency, signal_to_noise_ratio, random_state);

            obj.num_components_range = num_components_range;
            obj.frequency_range = frequency_range;
            obj.amplitude_range = amplitude_range;
            obj.phase_range = phase_range;
            obj.intermittent_prob = intermittent_prob;
            obj.combined_prob = combined_prob;
            obj.allow_intermittent = allow_intermittent;
            obj.allow_combined = allow_combined;
            obj.allow_multiple_intermittent = allow_multiple_intermittent;
            obj.allow_multiple_combined = allow_multiple_combined;
            obj.additional_component_frequency_range = additional_component_frequency_range;
            obj.impulse_probability = impulse_probability;
            obj.fault_probability = fault_probability;
            obj.use_persistent_faults = use_persistent_faults;
        end

        function dataset = generate_dataset(obj, num_signals, start_time, end_time)
            time = obj.generate_time_vector(start_time, end_time);
            components = cell(num_signals, 1);
            healthy_signals = zeros(num_signals, length(time));
            faulty_signals = zeros(num_signals, length(time));
            noisy_signals = zeros(num_signals, length(time));
            fault_types = zeros(num_signals, 1);

            % parfor i = 1:num_signals
            for i = 1:num_signals
                [healthy_signal, signal_components] = obj.generate_signal(time);
                [faulty_signal, fault_type] = obj.add_noise_and_faults_to_signal(healthy_signal, time);
                noisy_signal = obj.add_noise_to_signal(healthy_signal);

                healthy_signals(i, :) = healthy_signal;
                faulty_signals(i, :) = faulty_signal;
                noisy_signals(i, :) = noisy_signal;
                fault_types(i) = fault_type;
                components{i} = signal_components;
            end
            dataset = Dataset(obj, time, healthy_signals, faulty_signals, noisy_signals, fault_types, components);
        end

        function [signal, components] = generate_signal(obj, time, num_components_range, frequency_range)
            if nargin < 3 || isempty(num_components_range)
                num_components_range = obj.num_components_range;
            end
            if nargin < 4 || isempty(frequency_range)
                frequency_range = obj.frequency_range;
            end

            if ~isempty(obj.random_state)
                rng(obj.random_state);
            end

            num_components = randi(num_components_range);
            components = zeros(num_components, length(time));
            frequencies = zeros(num_components, 1);
            
            for i = 1:num_components
                generate_new_component = true;
                generate_attempts = 0;
                generate_intermittent = obj.allow_intermittent && rand() < obj.intermittent_prob;
                generate_combined = obj.allow_combined && ~generate_intermittent && rand() < obj.combined_prob;
                current_frequencies = [];

                while generate_new_component
                    [component, new_freq_hz] = obj.generate_random_signal(time, frequency_range, obj.amplitude_range, obj.phase_range);
                    generate_attempts = generate_attempts + 1;
                    if generate_attempts > 100
                        components = zeros(num_components, length(time));
                        signal = sum(components, 1);
                        return;
                    end
                    generate_new_component = any(abs(new_freq_hz - frequencies) < obj.MIN_FREQUENCY_DIFFERENCE * max(frequencies, new_freq_hz));
                    if ~generate_new_component
                        current_frequencies = [current_frequencies; new_freq_hz];
                    end
                end
                if generate_combined
                    frequency_range = [new_freq_hz * (1 - obj.MAX_NARROW_FREQUENCY_DIFFERENCE), new_freq_hz * (1 + obj.MAX_NARROW_FREQUENCY_DIFFERENCE)];
                    [additional_component, additional_freq] = obj.generate_random_signal(time, frequency_range, obj.amplitude_range, obj.phase_range);
                    component = component + additional_component;
                    current_frequencies = [current_frequencies; additional_freq];
                    allow_combined = obj.allow_multiple_combined;
                end
                if ~generate_new_component && generate_intermittent && num_components > 1
                    component = truncate_signal(component, obj.random_state);
                    allow_intermittent = obj.allow_multiple_intermittent;
                end
                components(i, :) = component;
                frequencies(i) = max(current_frequencies);
            end
            [~, idx] = sort(frequencies, "descend");
            components = components(idx, :);
            signal = sum(components, 1);
        end

        function [faulty_signal, fault_type] = add_faults_to_signal(obj, signal, time)
            faulty_signal = signal;
            fault_type = FaultTypes.HEALTHY;
            if obj.use_persistent_faults || rand() <= obj.impulse_probability
                impulse_signal = generate_impulse(length(signal), obj.random_state);
                faulty_signal = signal + impulse_signal;
                fault_type = FaultTypes.IMPULSE;
            end
            if obj.use_persistent_faults || rand() <= obj.fault_probability
                faults = obj.generate_signal(time, [1 1], obj.additional_component_frequency_range);
                faulty_signal = faulty_signal + faults;
                specific_fault_type = FaultTypes.ADDITIONAL_COMPONENT;
                fault_type = update_fault_type(fault_type, specific_fault_type);
            end
        end
    end

    methods (Access = private)
        function [signal, frequency] = generate_random_signal(~, time, frequency_range, amplitude_range, phase_range)
            amplitude = unifrnd(amplitude_range(1), amplitude_range(2));
            frequency = unifrnd(frequency_range(1), frequency_range(2));
            theta = unifrnd(phase_range(1), phase_range(2));
            
            signal = amplitude * sin(2*pi*frequency*time + theta);
        end
    end
end