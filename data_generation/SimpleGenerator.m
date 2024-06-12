classdef SimpleGenerator
    properties (Constant, Access = private)
        MIN_FREQUENCY_DIFFERENCE = 0.2
        MAX_NARROW_FREQUENCY_DIFFERENCE = 0.25

        IMPULSE_PROBABILITY = 0.5
    end
    
    properties % TODO: make the default values here
        num_signals
        num_data_points % TODO: get rid of this
        num_components_range
        sampling_freq
        freq_range
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
    end

    methods
        function obj = SimpleGenerator(num_signals,...
            num_data_points,...
            num_components_range,...
            sampling_freq,...
            freq_range,...
            amplitude_range,...
            phase_range,...
            signal_to_noise_ratio,...
            random_state,...
            intermittent_prob,...
            combined_prob,...
            allow_intermittent,...
            allow_combined,...
            allow_multiple_intermittent,...
            allow_multiple_combined...
        )
            obj.num_signals = num_signals;
            obj.num_data_points = num_data_points;
            obj.num_components_range = num_components_range;
            obj.sampling_freq = sampling_freq;
            obj.freq_range = freq_range;
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
        end

        function dataset = generate_dataset(obj, additional_component_frequency_range, probability)
            if nargin < 2 || isempty(additional_component_frequency_range)
                additional_component_frequency_range = 0;
            end
            if nargin < 3 || isempty(probability)
                probability = (additional_component_frequency_range ~= 0) * 0.5;
            end

            components = cell(obj.num_signals, 1);
            signals = zeros(obj.num_signals, obj.num_data_points);
            fault_flags = false(obj.num_signals, 1);
            
            parfor i = 1:obj.num_signals
                freq_comp_pairs = obj.generate_signal();
                components{i} = freq_comp_pairs;
                composed_signal = sum(freq_comp_pairs, 1);
                if rand() < probability
                    fault_signal = obj.generate_fault_as_additional_component(additional_component_frequency_range);
                    composed_signal = composed_signal + fault_signal;
                    fault_flags(i) = true;
                end
                if obj.signal_to_noise_ratio ~= 0
                    noise = obj.generate_noise(composed_signal);
                    composed_signal = composed_signal + noise;
                end
                signals(i, :) = composed_signal;
            end
            time = (0:obj.num_data_points-1) / obj.sampling_freq;
            dataset = Dataset(obj, time, signals, fault_flags, components);
        end
    end

    methods (Access = private)
        function [signal, frequency] = generate_random_signal(obj, frequency_range, random_state)
            time = (0:obj.num_data_points-1) / obj.sampling_freq;

            rng(random_state);
            
            amplitude = unifrnd(obj.amplitude_range(1), obj.amplitude_range(2));
            frequency = unifrnd(frequency_range(1), frequency_range(2));
            theta = unifrnd(obj.phase_range(1), obj.phase_range(2));
            
            signal = amplitude * sin(2*pi*frequency*time + theta);
        end

        function signal = truncate_signal(obj, signal, include_end)
            if nargin < 3 || isempty(include_end)
                include_end = false;
            end
            
            active_samples = randi([obj.num_data_points / 10, obj.num_data_points / 2]);
            
            if include_end || rand() < 0.5
                signal(1:active_samples) = 0;
            else
                signal(active_samples+1:end) = 0;
            end
        end

        function components = generate_signal(obj)
            num_components = randi(obj.num_components_range);
            components = zeros(num_components, obj.num_data_points);
            frequencies = zeros(num_components, 1);
            
            for i = 1:num_components
                generate_new_component = true;
                generate_attempts = 0;
                generate_intermittent = obj.allow_intermittent && rand() < obj.intermittent_prob;
                generate_combined = obj.allow_combined && ~generate_intermittent && rand() < obj.combined_prob;
                current_frequencies = [];
        
                while generate_new_component
                    [component, new_freq_hz] = obj.generate_random_signal(obj.freq_range, randi(2^31 - 1));
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
                
                if generate_combined % TODO: I think there is something wrong here...
                    frequency_range = [new_freq_hz * (1 - obj.MAX_NARROW_FREQUENCY_DIFFERENCE), new_freq_hz * (1 + obj.MAX_NARROW_FREQUENCY_DIFFERENCE)];
                    [additional_component, additional_freq] = obj.generate_random_signal(frequency_range, randi(2^31 - 1));
                    component = component + additional_component;
                    current_frequencies = [current_frequencies; additional_freq];
                    allow_combined = obj.allow_multiple_combined;
                end
                
                if ~generate_new_component && generate_intermittent
                    component = obj.truncate_signal(component);
                    allow_intermittent = obj.allow_multiple_intermittent;
                end

                components(i, :) = component;
                frequencies(i) = max(current_frequencies);
            end
            
            [~, idx] = sort(frequencies, 'descend');
            components = components(idx, :);
        end

        function fault_signal = generate_fault_as_additional_component(obj, frequency)
            [fault_signal, ~] = obj.generate_random_signal(frequency, randi(2^31 - 1));
            fault_signal = obj.truncate_signal(fault_signal, true);
        end

        function impulse_signal = generate_impulse(obj)
            impulse_strength = randi(10);
            step_size = randi([floor(obj.num_data_points / 15), floor(obj.num_data_points / 5)]);
            impulse_signal = zeros(1, obj.num_data_points);
            impulse_signal(1:step_size:obj.num_data_points) = impulse_strength;
            if rand() < 0.5
                impulse_signal = obj.truncate_signal(impulse_signal, true);
            end
        end

        function noise_signal = generate_noise(obj, signal)
            signal_power = mean(signal.^2);
            noise_power = signal_power / (10^(obj.signal_to_noise_ratio / 10));
            
            % Default Gaussian white noise
            noise_signal = sqrt(noise_power) * randn(1, obj.num_data_points);

            % Add impulses if needed
            if rand() < obj.IMPULSE_PROBABILITY
                impulse_signal = obj.generate_impulse();
                noise_signal = noise_signal + impulse_signal;
            end
        end
    end
end
