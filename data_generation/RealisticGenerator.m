classdef RealisticGenerator
    % This generator simulates vibration signals in a specific gearbox of a wind turbine
    % TODO: mention what wind turbine it is!
    properties (Constant, Access = private)
        IMPULSE_PROBABILITY = 0.5 % TODO: not sure if we need this?
    end

    properties
        sampling_frequency
        signal_to_noise_ratio
        rotor_speed_range
        range_n_teeth
    end

    methods
        function obj = RealisticGenerator(...
            sampling_frequency,...
            signal_to_noise_ratio,...
            rotor_speed_range,...
            range_n_teeth...
        )
            if nargin < 4 || isempty(rotor_speed_range)
                % Rotor speed ranges from 120 to 210 m/s
                % TODO: find paper to proof this
                rotor_speed_range = [120 210];
            end
            if nargin < 5 || isempty(range_n_teeth) % TODO: find realistic values with article!
                range_n_teeth = [90 130];
            end

            obj.sampling_frequency = sampling_frequency;
            obj.signal_to_noise_ratio = signal_to_noise_ratio;
            obj.rotor_speed_range = rotor_speed_range;
            obj.range_n_teeth = range_n_teeth;
        end

        function dataset = generate_dataset(obj, num_signals, time)
            signals = zeros(num_signals, length(time));
            fault_flags = false(num_signals, 1);
            
            % parfor i = 1:num_signals
            for i = 1:num_signals
                % Compute random blade frequency, based on rotor speed (in m/s) and convert to Hz
                blade_frequency = 1/unifrnd(obj.rotor_speed_range(1), obj.rotor_speed_range(2))*1000;
                % Generate random number of teeth for each gear
                n_teeth_by_gear = obj.randomize_gear_teeth();

                % Generate a wind turbine with random characteristics and its signal for a given time
                wind_turbine = WindTurbine(blade_frequency, n_teeth_by_gear);
                disp(wind_turbine)
                signal = wind_turbine.generate_signal(time);

                % Add noise if needed
                if obj.signal_to_noise_ratio ~= 0
                    noise = obj.generate_noise(signal);
                    signal = signal + noise;
                end
                signals(i, :) = signal;
            end

            dataset = Dataset(obj, time, signals, fault_flags);
            disp("Data generated")
        end
    end

    methods (Access = private)
        function n_teeth_by_gear = randomize_gear_teeth(obj)
            ps_ring_n_teeth = randi(obj.range_n_teeth);
            ps_planets_n_teeth = randi([round(ps_ring_n_teeth/4), round(ps_ring_n_teeth/3)]);
            ps_sun_n_teeth = randi([round(ps_ring_n_teeth/5), round(ps_ring_n_teeth/4)]);

            iss_g1 = randi(obj.range_n_teeth);
            iss_g2 = randi([round(iss_g1/6), round(iss_g1/4)]);

            hss_g3 = randi(obj.range_n_teeth);
            hss_g4 = randi([round(iss_g1/6), round(iss_g1/4)]);

            n_teeth_by_gear = [ps_ring_n_teeth, ps_sun_n_teeth, ps_planets_n_teeth, iss_g1, iss_g2, hss_g3, hss_g4];
        end

        function noise_signal = generate_noise(obj, signal)
            signal_power = mean(signal.^2);
            noise_power = signal_power / (10^(obj.signal_to_noise_ratio / 10));
            
            noise_signal = sqrt(noise_power) * randn(1, size(signal, 1));
        end
    end
end