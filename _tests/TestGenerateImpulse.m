classdef TestGenerateImpulse < matlab.unittest.TestCase
    properties
        n
        random_state
        impulse_strength
    end

    methods(TestMethodSetup)
        function setUp(testCase)
            testCase.n = 300;
            testCase.random_state = 101;
            testCase.impulse_strength = 0;
        end
    end

    methods(Test)
        function testImpulseSignal(testCase)
            actual_impulse = generate_impulse(testCase.n, testCase.random_state, testCase.impulse_strength);
            expected_impulse = load("./_tests/_cache/impulse_signal.mat").impulse;

            testCase.verifyEqual(length(actual_impulse), testCase.n, ...
                "The length of the impulse signal does not match.");

            actual_impulse_strength = max(actual_impulse);
            expected_impulse_strength = max(expected_impulse);
            testCase.verifyEqual(actual_impulse_strength, expected_impulse_strength);

            testCase.verifyEqual(actual_impulse, expected_impulse)
        end
    end
end