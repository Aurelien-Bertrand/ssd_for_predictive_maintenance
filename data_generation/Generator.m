classdef Generator
    properties % TODO: make the default values here
        num_signals
        num_data_points
        num_components_range
        sampling_freq % TODO: check realistic values
        freq_range
        amplitude_range
        phase_range
        random_state
        intermittent_prob
        combined_prob
        allow_intermittent
        allow_combined
        allow_multiple_intermittent
        allow_multiple_combined
    end

    methods
        function obj = Generator(num_signals, num_data_points, num_components_range, sampling_freq, freq_range, amplitude_range, phase_range, random_state, intermittent_prob, combined_prob, allow_intermittent, allow_combined, allow_multiple_intermittent, allow_multiple_combined)
            obj.num_signals = num_signals;
            obj.num_data_points = num_data_points;
            obj.num_components_range = num_components_range;
            obj.sampling_freq = sampling_freq;
            obj.freq_range = freq_range;
            obj.amplitude_range = amplitude_range;
            obj.phase_range = phase_range;
            obj.random_state = random_state;
            obj.intermittent_prob = intermittent_prob;
            obj.combined_prob = combined_prob;
            obj.allow_intermittent = allow_intermittent;
            obj.allow_combined = allow_combined;
            obj.allow_multiple_intermittent = allow_multiple_intermittent;
            obj.allow_multiple_combined = allow_multiple_combined;
        end

        function [signal, freqHz] = get_random_sinusoid(obj, freq_range, random_state)
            rng(random_state);
            t = (0:obj.num_data_points-1) / obj.sampling_freq;
            amplitude = unifrnd(obj.amplitude_range(1), obj.amplitude_range(2));
            freqHz = unifrnd(freq_range(1), freq_range(2));
            theta = unifrnd(obj.phase_range(1), obj.phase_range(2));
            signal = amplitude * sin(2 * pi * freqHz * t + theta);
        end
        
        function all_components = get_decomposed_signal(obj)
            num_components = randi(obj.num_components_range);
            all_components = zeros(num_components, obj.num_data_points);
            all_frequencies = zeros(num_components, 1);
            MIN_FREQUENCY_DIFFERENCE = 0.5;
            MAX_NARROW_FREQUENCY_DIFFERENCE = 0.25;
        
            for i = 1:num_components
                generate_new_component = true;
                generate_attempts = 0;
                generate_intermittent = obj.allow_intermittent && rand() < obj.intermittent_prob;
                generate_combined = obj.allow_combined && ~generate_intermittent && rand() < obj.combined_prob;
                current_frequencies = [];
        
                while generate_new_component
                    [component, new_freq_hz] = obj.get_random_sinusoid(obj.freq_range, randi(2^31 - 1));
                    generate_attempts = generate_attempts + 1;
        
                    if generate_attempts > 100
                        all_components = [];
                        return;
                    end
        
                    generate_new_component = false;
                    for j = 1:length(all_frequencies)
                        if abs(new_freq_hz - all_frequencies(j)) < max(all_frequencies(j), new_freq_hz) * MIN_FREQUENCY_DIFFERENCE
                            generate_new_component = true;
                            break;
                        end
                    end
                    
                    if ~generate_new_component
                        current_frequencies = [current_frequencies; new_freq_hz];
                    end
                end
        
                if generate_combined % TODO: I think there is something wrong here...
                    [additional_component, additional_freq] = obj.get_random_sinusoid([new_freq_hz * (1 - MAX_NARROW_FREQUENCY_DIFFERENCE), new_freq_hz * (1 + MAX_NARROW_FREQUENCY_DIFFERENCE)], randi(2^31 - 1));
                    component = component + additional_component;
                    current_frequencies = [current_frequencies; additional_freq];
                    allow_combined = obj.allow_multiple_combined;
                end
        
                if ~generate_new_component && generate_intermittent
                    active_samples = randi([obj.num_data_points / 10, obj.num_data_points / 2]);
                    if rand() < 0.5
                        component(1:active_samples) = 0;
                    else
                        component(active_samples+1:end) = 0;
                    end
                    allow_intermittent = obj.allow_multiple_intermittent;
                end
                
                all_components(i, :) = component;
                all_frequencies(i) = max(current_frequencies);
            end
            
            [~, idx] = sort(all_frequencies, 'descend');
            all_components = all_components(idx, :);
        end
        
        
        function [original_components, combined_signals] = generate_dataset(obj)
            combined_signals = zeros(obj.num_signals, obj.num_data_points);
            original_components = cell(obj.num_signals, 1);
            rng(obj.random_state);
            
            for i = 1:obj.num_signals
                freq_comp_pairs = obj.get_decomposed_signal();
                original_components{i} = freq_comp_pairs;
                composed_signal = sum(freq_comp_pairs, 1);
                combined_signals(i, :) = composed_signal;
                if mod(i, 100) == 0
                    disp(["Generated signal ", num2str(i), "/", num2str(obj.num_signals)]);
                end
            end
        end
    end
end
