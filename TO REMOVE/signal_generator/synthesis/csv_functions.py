import csv
import pandas as pd
import numpy as np

def save_to_csv(signals, filename='signals.csv'):
    with open(filename, mode='w', newline='') as file:
        writer = csv.writer(file)
    
        for signal_id, signal in enumerate(signals):
            for data_point_index in range(len(signal[0])):
                row = [signal_id, signal[0][data_point_index], signal[1][data_point_index]]
                writer.writerow(row)

# converts dataframe to an array of signals
# e.g. 
# dataset = [
#   [component_data_1, signal_1],
#   [component_data_2, signal_2],
#   ...
# ]
def list_from_df(df):
    dataset = []
    component = []
    signal = []

    # helper function to extract data from a row
    prev_id = None
    def extract_data(row):
        nonlocal prev_id, component, signal
        signal_id, component_value, signal_value = row
        if(signal_id != prev_id and prev_id != None):
            dataset.append([component, signal])
            component = []
            signal = []
        component.append(component_value)
        signal.append(signal_value)
        prev_id = signal_id

    # apply the helper function to each row
    df.apply(extract_data, axis=1)

    # also append the last row
    dataset.append([component, signal])

    return np.array(dataset)

def load_from_csv(filename='signals.csv'):
    signals_df = pd.read_csv(filename, header=None)
    return list_from_df(signals_df)