import torch
from faults_classification.MaintainNet import MaintainNet

CACHE_PATH = "_cache/models/"

def get_model(model_name="simplemodel.pth"):
    model = MaintainNet('MrMaintenance', 4)
    model.load_state_dict(torch.load(CACHE_PATH + model_name))
    model.eval()
    
    return model
