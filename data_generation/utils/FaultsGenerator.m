classdef FaultsGenerator
    properties (Constant, Access = private)
        % Boolean version
        HEALTHY = 0
        FAULTY = 1

        % Multi-class version
        IMPULSE = 2
        ADDITIONAL_SIGNAL = 3
        IMPULSE_AND_ADDITIONAL_SIGNAL = 4
    end

    properties
        impulse_probability
        additional_component_probability
    end

    methods
        function obj = FaultsGenerator(impulse_probability, additional_component_probability)
            if nargin < 1 || isempty(impulse_probability)
                impulse_probability = 0.3;
            end
            if nargin < 2 || isempty(additional_component_probability)
                additional_component_probability = 0.3;
            end
            obj.impulse_probability = impulse_probability;
            obj.additional_component_probability = additional_component_probability;
        end

        function [faulty_signal, fault_type] = add_faults_to_signal(...
            obj,...
            signal,...
            time,...
            component_frequency,...
            component_amplitude,...
            component_phase...
        )
            faulty_signal = signal;
            fault_type = obj.HEALTHY;
            if rand() < obj.impulse_probability
                faulty_signal = signal .* obj.generate_impulse(signal);
                fault_type = obj.IMPULSE;
            end
            if rand() < obj.additional_component_probability
                if nargin < 4
                    additional_component = obj.generate_realistic_faults(time);
                else
                    additional_component = obj.generate_simple_faults(time, component_frequency, component_amplitude, component_phase);
                end
                faulty_signal = faulty_signal + additional_component;
                if fault_type == obj.HEALTHY
                    fault_type = obj.ADDITIONAL_SIGNAL;
                else
                    fault_type = obj.IMPULSE_AND_ADDITIONAL_SIGNAL;
                end
            end
        end
    end

    methods (Access = private)
        function impulse_signal = generate_impulse(obj, signal)
            impulse_strength = unifrnd(1, 10);

            n = length(signal);
            step_size = randi([floor(n / 30), floor(n / 15)]);

            impulse_signal = ones(1, n);
            impulse_signal(1:step_size:n) = impulse_strength;
            impulse_signal = truncate_signal(impulse_signal, true);
        end

        function additional_component = generate_simple_faults(...
            obj,...
            time,...
            component_frequency,...
            component_amplitude,...
            component_phase...
        )
            if isempty(component_frequency)
                additional_component = zeros(1, length(time));
            else
                [additional_component, ~] = generate_random_signal(time, component_frequency, component_amplitude, component_phase);
                additional_component = truncate_signal(additional_component);
            end
        end

        % TODO
        function additional_component = generate_realistic_faults(obj, time)
            additional_component = zeros(1, length(time));
        end
    end
end