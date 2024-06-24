function impulse_signal = generate_impulse(n)
    impulse_strength = unifrnd(0, 10);

    step_size = randi([floor(n / 30), floor(n / 15)]);

    impulse_signal = ones(1, n);
    impulse_signal(1:step_size:n) = impulse_strength;
    impulse_signal = truncate_signal(impulse_signal);
end