classdef TestTruncateSignal < matlab.unittest.TestCase
    properties
        length
        random_state
    end

    methods(TestMethodSetup)
        function setUp(testCase)
            testCase.length = 1000;
            testCase.random_state = 101;
        end
    end

    methods(Test)
        function testTruncateSignal(testCase)
            rng(testCase.random_state)

            signal = randn(1, testCase.length);
            actual_signal = truncate_signal(signal, testCase.random_state);

            expected_signal = load("./_tests/_cache/truncated_signal.mat").signal;

            testCase.verifyEqual(actual_signal, expected_signal)
        end
    end
end