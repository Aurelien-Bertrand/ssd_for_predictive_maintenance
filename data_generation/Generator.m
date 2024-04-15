classdef Generator
    properties
        num_signals
        num_components_range
        num_data_points
        sampling_freq
        freq_range
        amplitude_range
        phase_range
        random_state
        intermittent_prob
        combined_prob
        allow_multiple_intermittent
        allow_multiple_combined
    end
    
    methods
        function obj = Generator(num_signals, num_data_points, num_components_range, sampling_freq, freq_range, amplitude_range, phase_range, random_state, intermittent_prob, combined_prob, allow_multiple_intermittent, allow_multiple_combined)
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
        
        function [signal, freqHz] = get_random_fm_sinusoid(obj, freq_range, random_state)
            rng(random_state);
            t = (0:obj.num_data_points-1) / obj.sampling_freq;
            amplitude = unifrnd(obj.amplitude_range(1), obj.amplitude_range(2));
            freqHz = unifrnd(freq_range(1), freq_range(2));
            theta = unifrnd(obj.phase_range(1), obj.phase_range(2));
            modulation_freq = unifrnd(0.1, 2);
            modulation_theta = unifrnd(0, 1000);
            modulated_freq = freqHz + amplitude * sin(2 * pi * modulation_freq * t + modulation_theta);
            signal = amplitude * sin(2 * pi * modulated_freq * t + theta);
        end
        
        function components = get_decomposed_signal(obj)
            rng(obj.random_state);
            num_components = randi(obj.num_components_range);
            components = cell(1, num_components);
            frequencies = zeros(num_components, 1);
            
            for i = 1:num_components
                [component, freqHz] = obj.get_random_sinusoid(obj.freq_range, randi(2^31 - 1));
                components{i} = component;
                frequencies(i) = freqHz;
            end
            
            [~, idx] = sort(frequencies, 'descend');
            components = components(idx);
        end
        
        function components = get_decomposed_signal_improved(obj)
            rng(obj.random_state);
            num_components = randi(obj.num_components_range);
            components = cell(1, num_components);
            frequencies = zeros(num_components, 1);
            allow_intermittent = true;
            allow_combined = true;
            MIN_FREQUENCY_DIFFERENCE = 0.5;
            MAX_NARROW_FREQUENCY_DIFFERENCE = 0.25;
            
            for i = 1:num_components
                generate_new_component = true;
                generate_attempts = 0;
                generate_intermittent = allow_intermittent && rand() < obj.intermittent_prob;
                generate_combined = allow_combined && ~generate_intermittent && rand() < obj.combined_prob;
                current_frequencies = [];
                
                while generate_new_component
                    [component, new_freq_hz] = obj.get_random_sinusoid(obj.freq_range, randi(2^31 - 1));
                    generate_attempts = generate_attempts + 1;
                    
                    if generate_attempts > 100
                        components = {};
                        return;
                    end
                    
                    generate_new_component = false;
                    for j = 1:length(frequencies)
                        if abs(new_freq_hz - frequencies(j)) < max(frequencies(j), new_freq_hz) * MIN_FREQUENCY_DIFFERENCE
                            generate_new_component = true;
                            break;
                        end
                    end
                    
                    if ~generate_new_component
                        current_frequencies = [current_frequencies; new_freq_hz];
                    end
                end
                
                if generate_combined
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
                
                components{i} = component;
                frequencies(i) = current_frequencies;
            end
            
            [~, idx] = sort(frequencies, 'descend');
            components = components(idx);
        end
        
        function signals = generate_dataset(obj, use_original_algorithm)
            signals = cell(1, obj.num_signals);
            rng(obj.random_state);
            
            for i = 1:obj.num_signals
                freq_comp_pairs = [];
                while isempty(freq_comp_pairs)
                    if use_original_algorithm
                        freq_comp_pairs = obj.get_decomposed_signal();
                    else
                        freq_comp_pairs = obj.get_decomposed_signal_improved();
                    end
                end
                
                highest_freq_component = freq_comp_pairs{1};
                composed_signal = sum(cell2mat(freq_comp_pairs));
                signals{i} = {highest_freq_component, composed_signal};
                if mod(i, 100) == 0
                    disp(['Generated signal ', num2str(i), '/', num2str(obj.num_signals)]);
                end
            end
        end
        
        function signals = generate_test_set(obj)
            signals = cell(1, obj.num_signals);
            rng(obj.random_state);
            
            for i = 1:obj.num_signals
                freq_comp_pairs = obj.get_decomposed_signal_improved();
                composed_signal = sum(cell2mat(freq_comp_pairs));
                signals{i} = {freq_comp_pairs, composed_signal};
            end
        end
    end
end
