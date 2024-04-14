import numpy as np
from tqdm import tqdm

class Generator:
    def __init__(self, num_signals, num_data_points, num_components_range, sampling_freq, freq_range, amplitude_range, phase_range, random_state, intermittent_prob, combined_prob, allow_multiple_intermittent, allow_multiple_combined, **kwargs):
        self.num_signals = num_signals
        self.num_components_range = num_components_range
        self.num_data_points = num_data_points
        self.sampling_freq = sampling_freq
        self.freq_range = freq_range
        self.amplitude_range = amplitude_range
        self.phase_range = phase_range
        self.random_state = random_state
        self.intermittent_prob = intermittent_prob
        self.combined_prob = combined_prob
        self.allow_multiple_intermittent = allow_multiple_intermittent
        self.allow_multiple_combined = allow_multiple_combined

    def get_random_sinusoid(self, freq_range, random_state=None):
        np.random.seed(random_state)
        t = np.arange(self.num_data_points) / self.sampling_freq
        amplitude = np.random.uniform(*self.amplitude_range)
        freqHz = np.random.uniform(*freq_range)
        theta = np.random.uniform(*self.phase_range)
        return amplitude * np.sin(2 * np.pi * freqHz * t + theta), freqHz
    
    def get_random_fm_sinusoid(self, freq_range, random_state=None):
        np.random.seed(random_state)
        t = np.arange(self.num_data_points) / self.sampling_freq
        amplitude = np.random.uniform(*self.amplitude_range)
        freqHz = np.random.uniform(*freq_range)
        theta = np.random.uniform(*self.phase_range)
    
        # Frequency modulation equation
        modulation_freq = np.random.uniform(0.1, 2)
        modulation_theta = np.random.uniform(0, 1000)
        modulated_freq = freqHz + amplitude * np.sin(2 * np.pi * modulation_freq * t + modulation_theta)

        signal = amplitude * np.sin(2 * np.pi * modulated_freq * t + theta)
        return signal, freqHz

    def get_decomposed_signal(self, random_state=None):
        np.random.seed(random_state)
        num_components = np.random.randint(*self.num_components_range)
        components = []
        frequencies = []

        for i in range(num_components):
            component, freqHz = self.get_random_sinusoid(self.freq_range, random_state=np.random.randint(2**31 - 1))
            components.append(component)
            frequencies.append([freqHz])

        # sort components by frequency descending
        components = [[frequency, component] for frequency, component in sorted(zip(frequencies, components), key=lambda pair: pair[0], reverse=True)]
        return components
    
    def get_decomposed_signal_improved(self, random_state=None):
        np.random.seed(random_state)
        num_components = np.random.randint(*self.num_components_range)
        all_components = []
        all_frequencies = []
        allow_intermittent = True
        allow_combined = True
        MIN_FREQUENCY_DIFFERENCE = 0.5
        MAX_NARROW_FREQUENCY_DIFFERENCE = 0.25

        for i in range(num_components):
            generate_new_component = True
            generate_attempts = 0
            generate_intermittent = allow_intermittent and np.random.uniform() < self.intermittent_prob
            generate_combined = allow_combined and not generate_intermittent and np.random.uniform() < self.combined_prob
            current_frequencies = []

            # find a new frequency that is not too close to an existing frequency
            while(generate_new_component):
                global component
                global new_freq_hz
                component, new_freq_hz = self.get_random_sinusoid(self.freq_range, random_state=np.random.randint(2**31 - 1))
                generate_attempts += 1

                if generate_attempts > 100:
                    return None

                generate_new_component = False
                for component_frequencies in all_frequencies:
                    # check if the new frequency is too close to an existing frequency
                    if abs(new_freq_hz - component_frequencies[0]) < max(component_frequencies[0], new_freq_hz) * MIN_FREQUENCY_DIFFERENCE:
                        generate_new_component = True
                        break
                    
                if(generate_new_component == False):
                    current_frequencies.append(new_freq_hz)

            # generate additional narrow frequency component
            if (generate_combined):
                additional_component, additional_freq = self.get_random_sinusoid(freq_range=(new_freq_hz * (1 - MAX_NARROW_FREQUENCY_DIFFERENCE), new_freq_hz * (1 + MAX_NARROW_FREQUENCY_DIFFERENCE)), random_state=np.random.randint(2**31 - 1))
                component = component + additional_component
                current_frequencies.append(additional_freq)
                allow_combined = True if self.allow_multiple_combined else False

            # generate intermittent component
            if not generate_new_component and generate_intermittent:
                active_samples = int(np.random.uniform(self.num_data_points // 10, self.num_data_points // 2))
                if np.random.uniform() < 0.5:
                    component[:active_samples] = 0
                else:
                    component[active_samples:] = 0
                allow_intermittent = True if self.allow_multiple_intermittent else False
            
            all_components.append(component)
            all_frequencies.append(current_frequencies)

        # sort components by frequency descending
        all_components = [[frequency, component] for frequency, component in sorted(zip(all_frequencies, all_components), key=lambda pair: pair[0], reverse=True)]
        return all_components

    def generate_dataset(self, use_original_algorithm=False):
        signals = []
        np.random.seed(self.random_state)

        for i in range(self.num_signals):
            freq_comp_pairs = None
            while(freq_comp_pairs == None):
                freq_comp_pairs = self.get_decomposed_signal(random_state=np.random.randint(2**31 - 1)) if use_original_algorithm else self.get_decomposed_signal_improved(random_state=np.random.randint(2**31 - 1))

            highest_freq_component = freq_comp_pairs[0][1]
            composed_signal = np.sum([component for _, component in freq_comp_pairs], axis=0)
            signals.append([highest_freq_component, composed_signal])
            if (i+1) % 100 == 0:
                print(f"Generated signal {i+1}/{self.num_signals}")

        return np.array(signals)
    
    def generate_test_set(self):
        signals = []
        np.random.seed(self.random_state)

        for i in range(self.num_signals):
            freq_comp_pairs = self.get_decomposed_signal_improved(random_state=np.random.randint(2**31 - 1))
            composed_signal = np.sum([component for _, component in freq_comp_pairs], axis=0)
            signals.append([freq_comp_pairs, composed_signal])

        return signals