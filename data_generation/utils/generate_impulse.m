function [impulse_signal, impulse_strength] = generate_impulse(n, random_state, impulse_strength)
    if ~isempty(random_state)
        rng(random_state);
    end
    
    if impulse_strength == 0
        upper_bound_impulse_strength = 10;
    else
        upper_bound_impulse_strength = impulse_strength + (10 - impulse_strength) * 0.2 * rand();
    end
    impulse_strength = unifrnd(impulse_strength, upper_bound_impulse_strength);

    step_size = randi([floor(n / 30), floor(n / 15)]);

    impulse_signal = ones(1, n);
    impulse_signal(1:step_size:n) = impulse_strength;
    impulse_signal = truncate_signal(impulse_signal, random_state);
end