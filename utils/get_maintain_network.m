function model = get_maintain_network(number_of_classes)
    [source_path, ~, ~] = fileparts(pwd);
    path_to_network = strcat(source_path, "/faults_classification");

    if count(py.sys.path, path_to_network) == 0
        insert(py.sys.path, int32(0), path_to_network);
    end

    torch = py.importlib.import_module('torch');
    torch.backends.mkl.enabled = true;

    model = py.MaintainNet.MaintainNet("MrMaintenance", int32(number_of_classes));
end