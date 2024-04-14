import matplotlib.pyplot as plt
import numpy as np
import math

SIZE_FACTOR = 1.5

def plot_signal(components, num_data_points=1000, sampling_freq=1000):
    composed_signal = np.sum([component for _, component in components], axis=0)
    y_lim = int(np.ceil(max(abs(np.min(composed_signal)), abs(np.max(composed_signal)))*1.1))
    num_plots = len(components) + 1
    
    fig, axs = plt.subplots(num_plots, 1, sharex=True, figsize=((5*SIZE_FACTOR, num_plots*SIZE_FACTOR)), constrained_layout=True)
    fig.subplots_adjust(hspace=0.5)
    # fig.suptitle('Simple sinusoidal signal')

    # Plot the components
    for i in range(len(components)):
        axs[i].set_ylim(-y_lim, y_lim)
        axs[i].plot(components[i][1], color='black')
        axs[i].set_ylabel('Amplitude')
        axs[i].set_title(f"Component {i+1} ({', '.join([str(round(frequency, 1)) + ' Hz' for frequency in components[i][0]])})")

    # Plot the composed signal
    axs[-1].plot(composed_signal, color='black')
    axs[-1].set_xlabel('Time')
    axs[-1].set_ylabel('Amplitude')
    axs[-1].set_ylim(-y_lim, y_lim)
    axs[-1].set_title('Composed signal')

    plt.show()

def plot_example(components, num_data_points=1000, sampling_freq=1000):
    t = np.arange(num_data_points) / sampling_freq
    num_plots = len(components) + 2
    fig, axs = plt.subplots(num_plots, 1, sharex=True, figsize=((5*SIZE_FACTOR, num_plots*SIZE_FACTOR)))
    fig.subplots_adjust(hspace=0.5)
    fig.suptitle('Simple sinusoidal signal', y=1)

    
    # Make sure all plots have the same scale
    ymin = min(np.min(comp) for comp in components)
    ymax = max(np.max(comp) for comp in components)
    ymin = min(ymin, np.min(components[0]-components[1]), np.min(components[0]-components[2])) - 0.1
    ymax = max(ymax, np.max(components[0]-components[1]), np.max(components[0]-components[2])) + 0.1

    axs[0].plot(components[0], color='black')
    axs[0].set_ylim([ymin, ymax])
    axs[0].set_ylabel('Amplitude')
    axs[0].set_title('Input')

    axs[1].plot(components[1], color = 'r')
    axs[1].set_ylim([ymin, ymax])
    axs[1].set_ylabel('Amplitude')
    axs[1].set_title('Output')

    axs[2].plot(components[2], color='r')
    axs[2].set_ylim([ymin, ymax])
    axs[2].set_ylabel('Amplitude')
    axs[2].set_title('Target')

    axs[3].plot(components[0]-components[1], color='b')
    axs[3].set_ylim([ymin, ymax])
    axs[3].set_ylabel('Amplitude')
    axs[3].set_title('Residual')

    axs[4].plot(components[0]-components[2], color='b')
    axs[4].set_ylim([ymin, ymax])
    axs[4].set_ylabel('Amplitude')
    axs[4].set_title('Target Residual')

    plt.show()

def plot_components(components, freq_comp_pairs=None, reconstructed = None, num_data_points=1000, sampling_freq=1000,
                    y_minmax=True):
    SIZE_FACTOR = 1.5
    t = np.arange(num_data_points) / sampling_freq
    num_plots = len(components)

    component_color = (0, 162/255, 219/255)

    if reconstructed != None:
        num_plots += 1

    fig, axs = plt.subplots(num_plots, 1, sharex=True, figsize=((5*SIZE_FACTOR, num_plots*SIZE_FACTOR)))
    fig.subplots_adjust(hspace=0.5)
    # fig.suptitle('Simple sinusoidal signal', y=1)

    # Make sure all plots have the same scale
    ymin = -1.1
    ymax = 1.1
 
    axs[0].plot(components[0], color='black', label='Original')
    if y_minmax:
        axs[0].set_ylim([ymin, ymax])
    axs[0].set_ylabel('Amplitude')
    axs[0].set_title('Input')
    
    i = 1
    while i < len(components):
        if(freq_comp_pairs != None):
            axs[i].plot(freq_comp_pairs[i-1][1], color='black')
        axs[i].plot(components[i], color=component_color, label='Model Output' if i == 1 else None)
        if y_minmax:
            axs[i].set_ylim([ymin, ymax])
        axs[i].set_ylabel('Amplitude')
        axs[i].set_title(f'Component {i}')
        i += 1

        

    # Same plot for reconstructed signal
    if reconstructed != None:
        axs[-1].plot(components[0], color='black')
        axs[-1].plot(reconstructed, color=component_color)
        if y_minmax:
            axs[-1].set_ylim([ymin, ymax])
        axs[-1].set_ylabel('Amplitude')
        axs[-1].set_title('Reconstruction')

    plt.subplots_adjust(bottom=0.2)
    fig.legend(loc='upper center', bbox_to_anchor=(0.5, 0.15), fancybox=True, shadow=True, ncol=2)
    return fig

def plot_components_residual(components, residuals=[], reconstructed = None, num_data_points=1000, sampling_freq=1000):
    SIZE_FACTOR = 1.5
    t = np.arange(num_data_points) / sampling_freq
    num_plots = len(components) + len(residuals)
    if reconstructed != None:
        num_plots += 1
    fig, axs = plt.subplots(num_plots, 1, sharex=True, figsize=((5*SIZE_FACTOR, num_plots*SIZE_FACTOR)))
    fig.subplots_adjust(hspace=0.5)
    fig.suptitle('Simple sinusoidal signal', y=1)
    
    colors = ['b', 'g', 'r', 'c', 'm']

    # Make sure all plots have the same scale
    ymin = min(np.min(comp) for comp in components)
    ymax = max(np.max(comp) for comp in components)
    # ymin = min(ymin, np.min(components[0]-components[1]), np.min(components[0]-components[2])) - 0.1
    # ymax = max(ymax, np.max(components[0]-components[1]), np.max(components[0]-components[2])) + 0.1
    
    axs[0].plot(components[0], color='black')
    axs[0].set_ylim([ymin, ymax])
    axs[0].set_ylabel('Amplitude')
    axs[0].set_title('Input')
    
    i = 1
    while i < len(residuals)*2:
        n = math.ceil(i/2)-1
        print(n)
        axs[i].plot(components[n+1], color=colors[n])
        axs[i].set_ylim([ymin, ymax])
        axs[i].set_ylabel('Amplitude')
        axs[i].set_title(f'Component {n}')
        i += 1
        axs[i].plot(residuals[n], color=colors[n])
        axs[i].set_ylim([ymin, ymax])
        axs[i].set_ylabel('Amplitude')
        axs[i].set_title(f'Residual {n}')
        i += 1

    if reconstructed != None:
        axs[-1].plot(components[0], color='black')
        axs[-1].plot(reconstructed, color='red')
        axs[-1].set_ylim([ymin, ymax])
        axs[-1].set_ylabel('Amplitude')
        axs[-1].set_title('Reconstructed')
        axs[-1].legend()
