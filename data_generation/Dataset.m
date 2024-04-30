classdef Dataset
    properties (Constant, Access = private)
        CACHE_PATH = "./cache/"
        DATASET_PATH = strcat(Dataset.CACHE_PATH, "dataset.mat")
        DATA_PATH = strcat(Dataset.CACHE_PATH, "data.mat")
    end

    properties
        generator
        components
        signals
        fault_flags
    end
    
    methods
        function obj = Dataset(generator, components, signals, fault_flags)
            obj.generator = generator;
            obj.components = components;
            obj.signals = signals;
            obj.fault_flags = fault_flags;
        end

        function save(obj)
            save(obj.DATASET_PATH, "obj");
        end

        function save_data(obj)
            data = [obj.signals obj.fault_flags];
            save(obj.DATA_PATH, "data")
        end
    end

    methods (Static)
        function dataset = load()
            dataset = load(Dataset.CACHE_PATH);
            dataset = dataset.obj;
        end
    end
end