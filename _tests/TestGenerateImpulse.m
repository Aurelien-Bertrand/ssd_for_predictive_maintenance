classdef TestGenerateImpulse < matlab.unittest.TestCase
    properties
        length
        random_state
    end

    methods(TestMethodSetup)
        function setUp(testCase)
            testCase.length = 300;
            testCase.random_state = 101;
        end
    end

    methods(Test)
        function testImpulseSignal(testCase)
            actual_impulse = generate_impulse(testCase.length, testCase.random_state);
            expected_impulse = load("./_tests/_cache/impulse_signal.mat").impulse;

            testCase.verifyEqual(length(actual_impulse), testCase.length, ...
                "The length of the impulse signal does not match.");

            actual_impulse_strength = max(actual_impulse);
            expected_impulse_strength = max(expected_impulse);
            testCase.verifyEqual(actual_impulse_strength, expected_impulse_strength);

            testCase.verifyEqual(actual_impulse, expected_impulse)
        end
    end
end