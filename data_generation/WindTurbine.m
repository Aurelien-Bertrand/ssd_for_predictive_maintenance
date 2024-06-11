classdef WindTurbine
    properties (Access = private, Constant)
        PHASE_ANGLE_FIRST_PLANETARY_GEAR = 0;
        PHASE_ANGLE_SECOND_PLANETARY_GEAR = 120;
        PHASE_ANGLE_THIRD_PLANETARY_GEAR = 240;

        DAMPING_WRT_SUN = 0.9;
        DAMPING_WRT_FIRST_PARALLEL_GEAR = 0.4;
        DAMPING_WRT_SECOND_PARALLEL_GEAR = 0.3;
    end

    properties
        number_of_blades
        blade_frequency
        carrier_frequency
        number_of_teeth_by_gear
        system_frequencies
    end

    methods
        function obj = WindTurbine(number_of_blades, blade_frequency, number_of_teeth_by_gear)
            obj.number_of_blades = number_of_blades;
            obj.blade_frequency = blade_frequency;
            obj.carrier_frequency = number_of_blades * blade_frequency;
            obj.number_of_teeth_by_gear = number_of_teeth_by_gear;
            obj.system_frequencies = obj.compute_system_frequencies();
        end
    end

    methods
        function signal = generate_signal(obj, time)
            vsp_11 = 0.004; % First Harmonic
            vrp_11 = 0.004;
            vsp_12 = 0.002; % Second Harmonic
            vrp_12 = 0.002;
            vsp_13 = 0.0015; % Third Harmonic
            vrp_13 = 0.0015;
            v_21 = 0.1; % Fundamental Meshing Harmonic
            v_31 = 0.5; % Fundamental Meshing Harmonic

            phase_term_1 = obj.PHASE_ANGLE_FIRST_PLANETARY_GEAR / (obj.system_frequencies(2) - obj.system_frequencies(1));
            phase_term_2 = obj.PHASE_ANGLE_SECOND_PLANETARY_GEAR / (obj.system_frequencies(2) - obj.system_frequencies(1));
            phase_term_3 = obj.PHASE_ANGLE_THIRD_PLANETARY_GEAR / (obj.system_frequencies(2) - obj.system_frequencies(1));

            % Sun-Planetary gear signal over the first 3 harmonics
            x_sp1 = vsp_11*cos(pi*obj.system_frequencies(3)*(time + phase_term_1)) + ...
                    vsp_12*cos(2*pi*obj.system_frequencies(3)*(time + phase_term_1)) + ...
                    vsp_13*cos(3*pi*obj.system_frequencies(3)*(time + phase_term_1));
            x_sp2 = vsp_11*cos(pi*obj.system_frequencies(3)*(time + phase_term_2)) + ...
                    vsp_12*cos(2*pi*obj.system_frequencies(3)*(time + phase_term_2)) + ...
                    vsp_13*cos(3*pi*obj.system_frequencies(3)*(time + phase_term_2));
            x_sp3 = vsp_11*cos(pi*obj.system_frequencies(3)*(time + phase_term_3)) + ...
                    vsp_12*cos(2*pi*obj.system_frequencies(3)*(time + phase_term_3)) + ...
                    vsp_13*cos(3*pi*obj.system_frequencies(3)*(time + phase_term_3));

            % Ring-Planetary gear signal over the first 3 harmonics
            x_rp1 = vrp_11*cos(pi*obj.system_frequencies(3)*(time - obj.PHASE_ANGLE_FIRST_PLANETARY_GEAR / obj.system_frequencies(1))) + ...
                    vrp_12*cos(2*pi*obj.system_frequencies(3)*(time - obj.PHASE_ANGLE_FIRST_PLANETARY_GEAR / obj.system_frequencies(1))) + ...
                    vrp_13*cos(3*pi*obj.system_frequencies(3)*(time - obj.PHASE_ANGLE_FIRST_PLANETARY_GEAR / obj.system_frequencies(1)));
            x_rp2 = vrp_11*cos(pi*obj.system_frequencies(3)*(time - obj.PHASE_ANGLE_SECOND_PLANETARY_GEAR / obj.system_frequencies(1))) + ...
                    vrp_12*cos(2*pi*obj.system_frequencies(3)*(time - obj.PHASE_ANGLE_SECOND_PLANETARY_GEAR / obj.system_frequencies(1))) + ...
                    vrp_13*cos(3*pi*obj.system_frequencies(3)*(time - obj.PHASE_ANGLE_SECOND_PLANETARY_GEAR / obj.system_frequencies(1)));
            x_rp3 = vrp_11*cos(pi*obj.system_frequencies(3)*(time - obj.PHASE_ANGLE_THIRD_PLANETARY_GEAR / obj.system_frequencies(1))) + ...
                    vrp_12*cos(2*pi*obj.system_frequencies(3)*(time - obj.PHASE_ANGLE_THIRD_PLANETARY_GEAR / obj.system_frequencies(1))) + ...
                    vrp_13*cos(3*pi*obj.system_frequencies(3)*(time - obj.PHASE_ANGLE_THIRD_PLANETARY_GEAR / obj.system_frequencies(1)));

            % Parallel gear signals
            x_2 = v_21*cos(pi*obj.system_frequencies(4)*time);
            x_3 = v_31*cos(pi*obj.system_frequencies(5)*time);

            % Combined signal
            signal = obj.DAMPING_WRT_SUN*(x_sp1 + x_sp2 + x_sp3) + ...
                     x_rp1 + x_rp2 + x_rp3 + ...
                     obj.DAMPING_WRT_FIRST_PARALLEL_GEAR*x_2 + ...
                     obj.DAMPING_WRT_SECOND_PARALLEL_GEAR*x_3;
        end
    end

    methods (Access = private)
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