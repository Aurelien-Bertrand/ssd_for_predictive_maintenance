classdef Dataset
    properties (Constant, Access = private)
        CACHE_PATH = "./cache/dataset.mat"
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
            save(obj.CACHE_PATH, "obj");
        end
    end

    methods (Static)
        function dataset = load()
            dataset = load(Dataset.CACHE_PATH);
            dataset = dataset.obj;
        end
    end
end