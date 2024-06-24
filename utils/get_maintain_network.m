function model = get_maintain_network(number_of_classes)
    path_to_network = strcat(pwd, "/faults_classification");
    if count(py.sys.path, path_to_network) == 0
        insert(py.sys.path, int32(0), path_to_network);
    end
    model = py.MaintainNet.MaintainNet("MrMaintenance", int32(number_of_classes));
end