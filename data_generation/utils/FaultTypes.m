classdef FaultTypes
    properties (Constant)
        % Boolean version
        HEALTHY = 0
        FAULTY = 1

        % Multi-class version
        IMPULSE = 2
        ADDITIONAL_COMPONENT = 3 % Simple generator
        FREQUENCY_MODULATION = 4 % Advanced generator
        AMPLITUDE_MODULATION = 5 % Advanced generator
        FREQUENCY_AND_AMPLITUDE_MODULATION = 6
        
        IMPULSE_AND_ADDITIONAL_COMPONENT = 7
        
        IMPULSE_AND_FREQUENCY_MODULATION = 8
        IMPULSE_AND_AMPLITUDE_MODULATION = 9
        IMPULSE_AND_FREQUENCY_AND_AMPLITUDE_MODULATION = 10
        % ------------------------------------------------
    end
end