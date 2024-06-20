classdef DataGenerator
    properties
        sampling_frequency
        faults_generator
        noise_generator
    end

    methods
        function obj = DataGenerator(sampling_frequency, signal_to_noise_ratio)
            obj.sampling_frequency = sampling_frequency;
            obj.faults_generator = FaultsGenerator();
            obj.noise_generator = NoiseGenerator(signal_to_noise_ratio);
        end

        function time = generate_time_vector(obj, start_time, end_time)
            time = start_time:1/obj.sampling_frequency:end_time;
        end

        function [noisy_and_faulty_signal, fault_type] = add_noise_and_faults_to_signal(obj, signal, time, varargin)
            [faulty_signal, fault_type] = obj.faults_generator.add_faults_to_signal(signal, time, varargin{:});
            noisy_and_faulty_signal = obj.noise_generator.add_noise_to_signal(faulty_signal);
        end
    end
    
    methods (Abstract)
        % Start_time and end_time are assumed to be in seconds
        dataset = generate_dataset(obj, num_signals, start_time, end_time)
    end
end
