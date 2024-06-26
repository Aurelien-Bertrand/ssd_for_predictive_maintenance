import torch
from faults_classification.MaintainNet import MaintainNet

CACHE_PATH = "_cache/models/"

SIMPLE_MODEL_NAME = "simplemodel.pth"
SIMPLE_MODEL_NUM_CLASSES = 4

REALISTIC_MODEL_NAME = "realisticmodel.pth"
REALISTIC_MODEL_NUM_CLASSES = 8

def get_model(use_realistic_data: bool = True):
    num_classes = REALISTIC_MODEL_NUM_CLASSES if use_realistic_data else SIMPLE_MODEL_NUM_CLASSES
    model_name = REALISTIC_MODEL_NAME if use_realistic_data else SIMPLE_MODEL_NAME
        
    model = MaintainNet(name="MrMaintenance", num_classes=num_classes)
    model.load_state_dict(torch.load(CACHE_PATH + model_name))
    model.eval()
    
    return model
