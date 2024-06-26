classdef TestDataGenerator < matlab.unittest.TestCase
    properties
        num_components_range
        sampling_frequency
        frequency_range
        amplitude_range
        phase_range
        signal_to_noise_ratio
        intermittent_prob
        combined_prob
        allow_intermittent
        allow_combined
        allow_multiple_intermittent
        allow_multiple_combined
        impulse_probability
        additional_component_frequency_range
        fault_probability
        random_state
        range_n_teeth
        start_time
        end_time
        use_persistent_faults
        time
    end
    
    methods(TestMethodSetup)
        function setUp(testCase)
            testCase.num_components_range = [5 10];
            testCase.sampling_frequency = 5120;
            testCase.frequency_range = [1 100];
            testCase.amplitude_range = [1 5];
            testCase.phase_range = [0 1];
            testCase.signal_to_noise_ratio = 10;
            testCase.intermittent_prob = 0.33;
            testCase.combined_prob = 0.33;
            testCase.allow_intermittent = true;
            testCase.allow_combined = true;
            testCase.allow_multiple_intermittent = true;
            testCase.allow_multiple_combined = true;
            testCase.impulse_probability = 1;
            testCase.additional_component_frequency_range = [300 600];
            testCase.fault_probability = 1;
            testCase.random_state = 101;
            testCase.range_n_teeth = [90 100];
            testCase.start_time = 0;
            testCase.end_time = 1;
            testCase.use_persistent_faults = false;
            testCase.time = testCase.start_time:1/testCase.sampling_frequency:testCase.end_time;
        end
    end
    
    methods(Test)
        function testSimpleDataGenerator(testCase)
            generator = SimpleGenerator(...
                testCase.num_components_range,...
                testCase.sampling_frequency,...
                testCase.frequency_range,...
                testCase.amplitude_range,...
                testCase.phase_range,...
                testCase.signal_to_noise_ratio,...
                testCase.intermittent_prob,...
                testCase.combined_prob,...
                testCase.allow_intermittent,...
                testCase.allow_combined,...
                testCase.allow_multiple_intermittent,...
                testCase.allow_multiple_combined,...
                testCase.impulse_probability,...
                testCase.additional_component_frequency_range,...
                testCase.fault_probability,...
                testCase.random_state...
            );
            actual_dataset = generator.generate_dataset(1, testCase.start_time, testCase.end_time);
            expected_dataset = Dataset.load("./_tests/_cache/simple_dataset.mat");

            testCase.verifyEqual(generator.num_components_range, testCase.num_components_range)
            testCase.verifyEqual(generator.sampling_frequency, testCase.sampling_frequency)
            testCase.verifyEqual(generator.frequency_range, testCase.frequency_range)
            testCase.verifyEqual(generator.amplitude_range, testCase.amplitude_range)
            testCase.verifyEqual(generator.phase_range, testCase.phase_range)
            testCase.verifyEqual(generator.signal_to_noise_ratio, testCase.signal_to_noise_ratio)
            testCase.verifyEqual(generator.intermittent_prob, testCase.intermittent_prob)
            testCase.verifyEqual(generator.combined_prob, testCase.combined_prob)
            testCase.verifyEqual(generator.allow_intermittent, testCase.allow_intermittent)
            testCase.verifyEqual(generator.allow_combined, testCase.allow_combined)
            testCase.verifyEqual(generator.allow_multiple_intermittent, testCase.allow_multiple_intermittent)
            testCase.verifyEqual(generator.allow_multiple_combined, testCase.allow_multiple_combined)
            testCase.verifyEqual(generator.impulse_probability, testCase.impulse_probability)
            testCase.verifyEqual(generator.additional_component_frequency_range, testCase.additional_component_frequency_range)
            testCase.verifyEqual(generator.fault_probability, testCase.fault_probability)
            testCase.verifyEqual(generator.random_state, testCase.random_state)
            testCase.verifyEqual(generator.use_persistent_faults, testCase.use_persistent_faults)

            testCase.verifyDatasetsEqual(actual_dataset, expected_dataset);
        end

        function testRealisticDataGenerator(testCase)
            generator = RealisticGenerator(...
                testCase.sampling_frequency,...
                testCase.signal_to_noise_ratio,...
                testCase.range_n_teeth,...
                testCase.impulse_probability,...
                testCase.fault_probability,...
                testCase.random_state,...
                testCase.use_persistent_faults...
            );
            actual_dataset = generator.generate_dataset(1, testCase.start_time, testCase.end_time);
            expected_dataset = Dataset.load("./_tests/_cache/realistic_dataset.mat");

            testCase.verifyEqual(generator.sampling_frequency, testCase.sampling_frequency)
            testCase.verifyEqual(generator.signal_to_noise_ratio, testCase.signal_to_noise_ratio)
            testCase.verifyEqual(generator.range_n_teeth, testCase.range_n_teeth)
            testCase.verifyEqual(generator.impulse_probability, testCase.impulse_probability)
            testCase.verifyEqual(generator.fault_probability, testCase.fault_probability)
            testCase.verifyEqual(generator.random_state, testCase.random_state)
            testCase.verifyEqual(generator.use_persistent_faults, testCase.use_persistent_faults)
            
            testCase.verifyDatasetsEqual(actual_dataset, expected_dataset);
        end
    end
    
    methods
        function verifyDatasetsEqual(testCase, actual_dataset, expected_dataset)
            testCase.verifyEqual(actual_dataset.time, expected_dataset.time, ...
                "Time arrays do not match.");
            testCase.verifyEqual(actual_dataset.healthy_signals, expected_dataset.healthy_signals, ...
                "Healthy signals do not match.");
            testCase.verifyEqual(actual_dataset.faulty_signals, expected_dataset.faulty_signals, ...
                "Faulty signals do not match.");
            testCase.verifyEqual(actual_dataset.noisy_signals, expected_dataset.noisy_signals, ...
                "Noisy signals do not match.");
            testCase.verifyEqual(actual_dataset.fault_types, expected_dataset.fault_types, ...
                "Fault types do not match.");
            testCase.verifyEqual(actual_dataset.components, expected_dataset.components, ...
                "Components do not match.");
            testCase.verifyEqual(actual_dataset.time, testCase.time, ...
                "Time vectors do not match.");
        end
    end
end
