classdef SimpleGenerator < DataGenerator
    properties (Constant, Access = private)
        MIN_FREQUENCY_DIFFERENCE = 0.2
        MAX_NARROW_FREQUENCY_DIFFERENCE = 0.25
    end
    
    properties
        num_components_range
        frequency_range
        amplitude_range
        phase_range
        signal_to_noise_ratio
        random_state
        intermittent_prob
        combined_prob
        allow_intermittent
        allow_combined
        allow_multiple_intermittent
        allow_multiple_combined
        additional_component_frequency_range
    end

    methods
        function obj = SimpleGenerator(...
            num_components_range,...
            sampling_frequency,...
            frequency_range,...
            amplitude_range,...
            phase_range,...
            signal_to_noise_ratio,...
            random_state,...
            intermittent_prob,...
            combined_prob,...
            allow_intermittent,...
            allow_combined,...
            allow_multiple_intermittent,...
            allow_multiple_combined,...
            additional_component_frequency_range...
        )
            obj@DataGenerator(sampling_frequency, signal_to_noise_ratio);
            
            obj.num_components_range = num_components_range;
            obj.frequency_range = frequency_range;
            obj.amplitude_range = amplitude_range;
            obj.phase_range = phase_range;
            obj.signal_to_noise_ratio = signal_to_noise_ratio;
            obj.random_state = random_state;
            obj.intermittent_prob = intermittent_prob;
            obj.combined_prob = combined_prob;
            obj.allow_intermittent = allow_intermittent;
            obj.allow_combined = allow_combined;
            obj.allow_multiple_intermittent = allow_multiple_intermittent;
            obj.allow_multiple_combined = allow_multiple_combined;
            if nargin < 14
                additional_component_frequency_range = [];
            end
            obj.additional_component_frequency_range = additional_component_frequency_range;
        end

        function dataset = generate_dataset(...
            obj,...
            num_signals,...
            start_time,...
            end_time...
        )
            time = obj.generate_time_vector(start_time, end_time);
            components = cell(num_signals, 1);
            signals = zeros(num_signals, length(time));
            fault_types = zeros(num_signals, 1);

            % parfor i = 1:num_signals
            for i = 1:num_signals
                [signal, signal_components] = obj.generate_signal(time);
                [signal, fault_type] = obj.add_noise_and_faults_to_signal(signal, time, obj.additional_component_frequency_range, obj.amplitude_range, obj.phase_range);

                signals(i, :) = signal;
                components{i} = signal_components;
                fault_types(i) = fault_type;
            end
            dataset = Dataset(obj, time, signals, fault_types, components);
        end
    end

    methods (Access = private)
        function [signal, components] = generate_signal(obj, time)
            num_components = randi(obj.num_components_range);
            components = zeros(num_components, length(time));
            frequencies = zeros(num_components, 1);
            
            for i = 1:num_components
                generate_new_component = true;
                generate_attempts = 0;
                generate_intermittent = obj.allow_intermittent && rand() < obj.intermittent_prob;
                generate_combined = obj.allow_combined && ~generate_intermittent && rand() < obj.combined_prob;
                current_frequencies = [];

                while generate_new_component
                    [component, new_freq_hz] = generate_random_signal(time, obj.frequency_range, obj.amplitude_range, obj.phase_range);
                    generate_attempts = generate_attempts + 1;
                    if generate_attempts > 100
                        components = [];
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
                if ~generate_new_component && generate_intermittent
                    component = truncate_signal(component);
                    allow_intermittent = obj.allow_multiple_intermittent;
                end
                components(i, :) = component;
                frequencies(i) = max(current_frequencies);
            end
            [~, idx] = sort(frequencies, "descend");
            components = components(idx, :);
            signal = sum(components, 1);
        end
    end
end
