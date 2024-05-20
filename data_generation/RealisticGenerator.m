classdef RealisticGenerator
    % This generator simulates vibration signals in a specific gearbox of a wind turbine
    % TODO: detail what mesh we have etc.
    properties (Constant, Access = private)
        PHASE_ANGLE_FIRST_PLANETARY_GEAR = 0;
        PHASE_ANGLE_SECOND_PLANETARY_GEAR = 120;
        PHASE_ANGLE_THIRD_PLANETARY_GEAR = 240;

        DAMPING_WRT_SUN = 0.9;
        DAMPING_WRT_FIRST_PARALLEL_GEAR = 0.4;
        DAMPING_WRT_SECOND_PARALLEL_GEAR = 0.3;

        IMPULSE_PROBABILITY = 0.5
    end

    properties
        sampling_frequency
        n_teeths_by_gear
        signal_to_noise_ratio
        system_frequencies
    end

    methods
        function obj = RealisticGenerator(...
            sampling_frequency,...
            n_teeths_by_gear,...
            carrier_frequency,...
            signal_to_noise_ratio...
        )
            obj.sampling_frequency = sampling_frequency;
            obj.n_teeths_by_gear = n_teeths_by_gear;
            obj.system_frequencies = obj.compute_system_frequencies(carrier_frequency);
            obj.signal_to_noise_ratio = signal_to_noise_ratio;
        end

        function dataset = generate_dataset(obj, num_signals, start_time, end_time)
            time = start_time:1/obj.sampling_frequency:end_time;
            
            signals = zeros(num_signals, length(time));
            fault_flags = false(num_signals, 1);

            % TODO: where do these come from?
            vsp_11 = 0.004; % First Harmonic
            vrp_11 = 0.004;
            vsp_12 = 0.002; % Second Harmonic
            vrp_12 = 0.002;
            vsp_13 = 0.0015; % Third Harmonic
            vrp_13 = 0.0015;
            v_21 = 0.1; % Fundamental Meshing Harmonic
            v_31 = 0.5; % Fundamental Meshing Harmonic

            % Sun-Planetary gear signal over the first 3 harmonics
            x_sp1 = vsp_11*cos(pi*obj.system_frequencies(3)*(time+(obj.PHASE_ANGLE_FIRST_PLANETARY_GEAR/(obj.system_frequencies(2)-obj.system_frequencies(1))))) + vsp_12*cos(2*pi*obj.system_frequencies(3)*(time+(obj.PHASE_ANGLE_FIRST_PLANETARY_GEAR/(obj.system_frequencies(2)-obj.system_frequencies(1))))) + vsp_13*cos(3*pi*obj.system_frequencies(3)*(time+(obj.PHASE_ANGLE_FIRST_PLANETARY_GEAR/(obj.system_frequencies(2)-obj.system_frequencies(1)))));
            x_sp2 = vsp_11*cos(pi*obj.system_frequencies(3)*(time+(obj.PHASE_ANGLE_SECOND_PLANETARY_GEAR/(obj.system_frequencies(2)-obj.system_frequencies(1))))) + vsp_12*cos(2*pi*obj.system_frequencies(3)*(time+(obj.PHASE_ANGLE_SECOND_PLANETARY_GEAR/(obj.system_frequencies(2)-obj.system_frequencies(1))))) + vsp_13*cos(3*pi*obj.system_frequencies(3)*(time+(obj.PHASE_ANGLE_SECOND_PLANETARY_GEAR/(obj.system_frequencies(2)-obj.system_frequencies(1)))));
            x_sp3 = vsp_11*cos(pi*obj.system_frequencies(3)*(time+(obj.PHASE_ANGLE_THIRD_PLANETARY_GEAR/(obj.system_frequencies(2)-obj.system_frequencies(1))))) + vsp_12*cos(2*pi*obj.system_frequencies(3)*(time+(obj.PHASE_ANGLE_THIRD_PLANETARY_GEAR/(obj.system_frequencies(2)-obj.system_frequencies(1))))) + vsp_13*cos(3*pi*obj.system_frequencies(3)*(time+(obj.PHASE_ANGLE_THIRD_PLANETARY_GEAR/(obj.system_frequencies(2)-obj.system_frequencies(1)))));

            % Ring-Planetary gear signal over the first 3 harmonics
            x_rp1 = vrp_11*cos(pi*obj.system_frequencies(3)*(time-(obj.PHASE_ANGLE_FIRST_PLANETARY_GEAR/obj.system_frequencies(1)))) + vrp_12*cos(2*pi*obj.system_frequencies(3)*(time-(obj.PHASE_ANGLE_FIRST_PLANETARY_GEAR/obj.system_frequencies(1)))) + vrp_13*cos(3*pi*obj.system_frequencies(3)*(time-(obj.PHASE_ANGLE_FIRST_PLANETARY_GEAR/obj.system_frequencies(1))));
            x_rp2 = vrp_11*cos(pi*obj.system_frequencies(3)*(time-(obj.PHASE_ANGLE_SECOND_PLANETARY_GEAR/obj.system_frequencies(1)))) + vrp_12*cos(2*pi*obj.system_frequencies(3)*(time-(obj.PHASE_ANGLE_SECOND_PLANETARY_GEAR/obj.system_frequencies(1)))) + vrp_13*cos(3*pi*obj.system_frequencies(3)*(time-(obj.PHASE_ANGLE_SECOND_PLANETARY_GEAR/obj.system_frequencies(1))));
            x_rp3 = vrp_11*cos(pi*obj.system_frequencies(3)*(time-(obj.PHASE_ANGLE_THIRD_PLANETARY_GEAR/obj.system_frequencies(1)))) + vrp_12*cos(2*pi*obj.system_frequencies(3)*(time-(obj.PHASE_ANGLE_THIRD_PLANETARY_GEAR/obj.system_frequencies(1)))) + vrp_13*cos(3*pi*obj.system_frequencies(3)*(time-(obj.PHASE_ANGLE_THIRD_PLANETARY_GEAR/obj.system_frequencies(1))));

            % First Parallel gear signal
            x_2 = v_21*cos(pi*obj.system_frequencies(4)*time);

            % Second Parallel gear signal
            x_3 = v_31*cos(pi*obj.system_frequencies(5)*time);

            % Overall Signal
            combined_signal = obj.DAMPING_WRT_SUN*x_sp1 +...
                              obj.DAMPING_WRT_SUN*x_sp2 +...
                              obj.DAMPING_WRT_SUN*x_sp3 +...
                              x_rp1 +...
                              x_rp2 +...
                              x_rp3 +...
                              obj.DAMPING_WRT_FIRST_PARALLEL_GEAR*x_2 +...
                              obj.DAMPING_WRT_SECOND_PARALLEL_GEAR*x_3;
            
            parfor i = 1:num_signals
                if obj.signal_to_noise_ratio ~= 0
                    noise = obj.generate_noise(combined_signal);
                    signals(i, :) = combined_signal + noise;
                else 
                    signals(i, :) = combined_signal;
                end
            end
            dataset = Dataset(obj, time, signals, fault_flags);
        end
    end

    methods (Access = private)
        function system_frequencies = compute_system_frequencies(obj, carrier_frequency)
            temp = (1+obj.n_teeths_by_gear(1)/obj.n_teeths_by_gear(2));
            
            sun_frequency = temp*carrier_frequency;
            planetary_gear_meshing_frequency = obj.n_teeths_by_gear(1)*carrier_frequency;
            first_parallel_gear_meshing_frequency = temp*obj.n_teeths_by_gear(3)*carrier_frequency;
            second_parallel_gear_meshing_frequency = temp*(obj.n_teeths_by_gear(3)/obj.n_teeths_by_gear(4))*obj.n_teeths_by_gear(5)*carrier_frequency;

            system_frequencies = [
                carrier_frequency, sun_frequency, planetary_gear_meshing_frequency, first_parallel_gear_meshing_frequency, second_parallel_gear_meshing_frequency
            ];
        end

        function noise_signal = generate_noise(obj, signal)
            signal_power = mean(signal.^2);
            noise_power = signal_power / (10^(obj.signal_to_noise_ratio / 10));
            
            noise_signal = sqrt(noise_power) * randn(1, size(signal, 1));
        end
    end
end