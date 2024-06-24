function truncated_signal = truncate_signal(signal, random_state)
    if ~isempty(random_state)
        rng(random_state);
    end

    start_index = randi([0, length(signal)]);
    truncated_signal = signal;
    truncated_signal(1:start_index) = 0;
end