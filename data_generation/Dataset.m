classdef Dataset
    properties (Constant, Access = private)
        CACHE_PATH = "../cache/"
        DATASET_PATH = strcat(Dataset.CACHE_PATH, "dataset.mat")
        DATA_PATH = strcat(Dataset.CACHE_PATH, "data.csv")
    end

    properties
        generator
        time
        signals
        fault_flags
        components
    end
    
    methods
        function obj = Dataset(generator, time, signals, fault_flags, components)
            obj.generator = generator;
            obj.time = time;
            obj.signals = signals;
            obj.fault_flags = fault_flags;
            if nargin < 5
                obj.components = [];
            else
                obj.components = components;
            end
        end

        function save(obj)
            disp("Saving dataset...")
            save(obj.DATASET_PATH, "obj", "-v7.3");
        end

        function save_data(obj)
            disp("Saving data...")
            data = array2table([obj.signals obj.fault_flags]);
            save(obj.DATA_PATH, "data");
        end

        function plot(obj)
            addpath("../plotting")
            if size(obj.signals, 1) <= 10
                disp("Plotting signals...")
                plot_raw_signals(obj.time, obj.signals)                
            end
        end
    end

    methods (Static)
        function dataset = load()
            file_name = Dataset.DATASET_PATH;
            if isfile(file_name)
                dataset = load(file_name);
                dataset = dataset.obj;
            else
                dataset = [];
            end
        end
    end
end