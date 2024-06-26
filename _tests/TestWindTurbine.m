classdef TestWindTurbine < matlab.unittest.TestCase
    properties (Constant)
        EXPECTED_N_TEETH_BY_GEAR = [111 22 33 97 22 124 18]
        EXPECTED_SYSTEM_FREQUENCIES = [0.3300 1.9950 36.6300 193.5150 1090.7209]
    end

    properties
        carrier_frequency
        number_of_teeth_by_gear
        system_frequencies
        random_state
        dynamic_update
    end

    methods(TestMethodSetup)
        function setUp(testCase)
            testCase.carrier_frequency = 0.33;
            testCase.number_of_teeth_by_gear = [90 130];
            testCase.random_state = 101;
            testCase.dynamic_update = false;
        end
    end

    methods(Test)
        function testWindTurbine(testCase)
            wind_turbine = WindTurbine(...
                testCase.carrier_frequency,...
                testCase.number_of_teeth_by_gear,...
                testCase.random_state,...
                testCase.dynamic_update...
            );
            testCase.verifyWindTurbineEquals(wind_turbine);
        end
    end

    methods
        function verifyWindTurbineEquals(testCase, wind_turbine)
            testCase.verifyEqual(wind_turbine.random_state, testCase.random_state);
            testCase.verifyEqual(wind_turbine.carrier_frequency, testCase.carrier_frequency);
            testCase.verifyEqual(wind_turbine.system_frequencies, testCase.EXPECTED_SYSTEM_FREQUENCIES, "AbsTol", 1e-4);
            testCase.verifyEqual(wind_turbine.number_of_teeth_by_gear, testCase.EXPECTED_N_TEETH_BY_GEAR);
            testCase.verifyEqual(wind_turbine.dynamic_update, testCase.dynamic_update)
        end
    end
end