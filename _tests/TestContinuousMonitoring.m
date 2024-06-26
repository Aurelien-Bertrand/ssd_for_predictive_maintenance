classdef TestContinuousMonitoring < matlab.unittest.TestCase
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
        num_windows
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
            testCase.use_persistent_faults = true;
            testCase.num_windows = 20;
        end
    end
    
    methods(Test)
        function testMonitoringSimpleDataGenerator(testCase)
            [start_times, end_times] = testCase.generate_time_windows();
            previous_additional_component_frequency_range = [];
            previous_impulse_strength = 0;
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
                testCase.random_state,...
                testCase.use_persistent_faults...
            );
            for i=1:length(start_times)
                [~] = generator.generate_dataset(1, start_times(i), end_times(i));
                additional_component_frequency_range = generator.additional_component_frequency_range;
                impulse_strength = generator.impulse_strength;
                if ~isempty(previous_additional_component_frequency_range)
                    testCase.verifyGreaterThanOrEqual(additional_component_frequency_range(1), previous_additional_component_frequency_range(1))
                    testCase.verifyGreaterThanOrEqual(impulse_strength, previous_impulse_strength)

                    testCase.verifyEqual(generator.use_persistent_faults, true)
                end
                previous_impulse_strength = impulse_strength;
                previous_additional_component_frequency_range = additional_component_frequency_range;
            end
        end

        function testMonitoringRealisticDataGenerator(testCase)
            [start_times, end_times] = testCase.generate_time_windows();
            previous_wind_turbine = [];
            previous_impulse_strength = 0;
            generator = RealisticGenerator(...
                testCase.sampling_frequency,...
                testCase.signal_to_noise_ratio,...
                testCase.range_n_teeth,...
                testCase.impulse_probability,...
                testCase.fault_probability,...
                testCase.random_state,...
                testCase.use_persistent_faults...
            );
            for i=1:length(start_times)
                [~] = generator.generate_dataset(1, start_times(i), end_times(i));
                wind_turbine = generator.wind_turbine;
                impulse_strength = generator.impulse_strength;
                if ~isempty(previous_wind_turbine)
                    testCase.verifyEqual(wind_turbine.dynamic_update, true)
                    testCase.verifyGreaterThanOrEqual(wind_turbine.A, previous_wind_turbine.A)
                    testCase.verifyGreaterThanOrEqual(wind_turbine.B, previous_wind_turbine.B)

                    testCase.verifyEqual(generator.use_persistent_faults, true)
                    testCase.verifyGreaterThanOrEqual(impulse_strength, previous_impulse_strength)
                end
                previous_wind_turbine = wind_turbine;
                previous_impulse_strength = impulse_strength;
            end
        end
    end
    
    methods (Access = private)
        function [start_times, end_times] = generate_time_windows(testCase)
            start_times = 0:1:testCase.num_windows;
            end_times = start_times + 1;
        end
    end
end