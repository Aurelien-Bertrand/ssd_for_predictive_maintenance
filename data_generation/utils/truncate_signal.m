function truncated_signal = truncate_signal(signal, is_impulse)
    if nargin < 2 || isempty(is_impulse) || ~is_impulse
        value_to_replace = 0;
    else
        value_to_replace = 1;
    end
    start_index = randi([0, length(signal)]);
    truncated_signal = signal;
    truncated_signal(1:start_index) = value_to_replace;
end