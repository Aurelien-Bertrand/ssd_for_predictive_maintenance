classdef NoiseGenerator
    properties
        signal_to_noise_ratio
    end
    methods
        function obj = NoiseGenerator(signal_to_noise_ratio)
            obj.signal_to_noise_ratio = signal_to_noise_ratio;
        end

        function noisy_signal = add_noise_to_signal(obj, signal)
            if obj.signal_to_noise_ratio == 0
                noisy_signal = signal;
            else
                noisy_signal = awgn(signal, obj.signal_to_noise_ratio, "measured");
            end
        end
    end

end