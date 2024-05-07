classdef Dataset
    properties (Constant, Access = private)
        CACHE_PATH = "./cache/"
        DATASET_PATH = strcat(Dataset.CACHE_PATH, "dataset.mat")
        DATA_PATH = strcat(Dataset.CACHE_PATH, "data.csv")
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
            save(obj.DATASET_PATH, "obj", "-v7.3");
        end

        function save_data(obj)
            data = array2table([obj.signals obj.fault_flags]);
            save(obj.DATA_PATH, "data");
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