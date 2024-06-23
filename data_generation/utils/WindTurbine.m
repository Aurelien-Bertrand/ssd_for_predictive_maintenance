classdef WindTurbine
    % This generator simulates vibration signals in a specific gearbox of a wind turbine
    % TODO: mention what wind turbine it is!
    properties (Access = private, Constant)
        NUM_HARMONICS = 3

        MODULATING_SIGNAL_PHASE_SHIFT = 0;
        ADDITIONAL_PHASE_SHIFT = pi/3;
    end

    properties
        carrier_frequency
        number_of_teeth_by_gear
        system_frequencies
        random_state
    end

    methods
        function obj = WindTurbine(carrier_frequency, range_n_teeth, random_state)
            obj.carrier_frequency = carrier_frequency;
            obj.number_of_teeth_by_gear = obj.randomize_gear_teeth(range_n_teeth);
            obj.system_frequencies = obj.compute_system_frequencies();
            obj.random_state = random_state;
        end

        function signal = generate_signal(obj, time, previous_A, previous_B)
            if nargin < 3 || isempty(previous_A)
                previous_A = 0;
            end
            if nargin < 4 || isempty(previous_B)
                previous_B = 0;
            end

            if ~isempty(obj.random_state)
                rng(obj.random_state);
            end

            A = unifrnd(previous_A, 1);
            B = unifrnd(previous_B, 1);
            meshing_frequency_parallel_gears = sum(obj.system_frequencies(4:5));
            
            signal = zeros(size(time));
            for k = 1:obj.NUM_HARMONICS
                signal = signal + ...
                    (1 + A*cos(2*pi*obj.system_frequencies(3)*time)) .* ...
                    cos(k*2*pi*meshing_frequency_parallel_gears*time + ...
                        B*cos(2*pi*obj.system_frequencies(3)*time + obj.MODULATING_SIGNAL_PHASE_SHIFT) +  ...
                        obj.ADDITIONAL_PHASE_SHIFT...
                    );
            end
            ring_frequency = obj.system_frequencies(3) / obj.number_of_teeth_by_gear(1);
            pass_effect_vibration_signal = 1 - cos(2*pi*3*time*ring_frequency);

            signal = signal .* pass_effect_vibration_signal;
        end
    end

    methods (Access = private)
        function n_teeth_by_gear = randomize_gear_teeth(obj, range_n_teeth)
            if ~isempty(obj.random_state)
                rng(obj.random_state);
            end

            ps_ring_n_teeth = randi(range_n_teeth);
            ps_planets_n_teeth = randi([round(ps_ring_n_teeth/4), round(ps_ring_n_teeth/3)]);
            ps_sun_n_teeth = randi([round(ps_ring_n_teeth/5), round(ps_ring_n_teeth/4)]);

            iss_g1 = randi(range_n_teeth);
            iss_g2 = randi([round(iss_g1/6), round(iss_g1/4)]);

            hss_g3 = randi(range_n_teeth);
            hss_g4 = randi([round(iss_g1/6), round(iss_g1/4)]);

            n_teeth_by_gear = [ps_ring_n_teeth, ps_sun_n_teeth, ps_planets_n_teeth, iss_g1, iss_g2, hss_g3, hss_g4];
        end

        function system_frequencies = compute_system_frequencies(obj)
            ring_to_sun_teeth_ratio = (1+obj.number_of_teeth_by_gear(1)/obj.number_of_teeth_by_gear(2));
            
            sun_frequency = ring_to_sun_teeth_ratio*obj.carrier_frequency;
            planetary_gear_meshing_frequency = obj.number_of_teeth_by_gear(1)*obj.carrier_frequency;
            first_parallel_gear_meshing_frequency = ring_to_sun_teeth_ratio*obj.number_of_teeth_by_gear(4)*obj.carrier_frequency;
            second_parallel_gear_meshing_frequency = ring_to_sun_teeth_ratio*(obj.number_of_teeth_by_gear(4)/obj.number_of_teeth_by_gear(5))*obj.number_of_teeth_by_gear(6)*obj.carrier_frequency;

            system_frequencies = [
                obj.carrier_frequency, sun_frequency, planetary_gear_meshing_frequency, first_parallel_gear_meshing_frequency, second_parallel_gear_meshing_frequency
            ];
        end
    end
end