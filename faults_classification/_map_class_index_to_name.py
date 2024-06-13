_CLASS_INDEX_TO_NAME = {
    0: "healthy",
    1: "faulty",
} # TODO: edit this for multi-class later

def map_class_index_to_name(class_index: int) -> str:
    assert class_index in _CLASS_INDEX_TO_NAME.keys(), f"Class {class_index} is not known."
    
    return _CLASS_INDEX_TO_NAME[class_index]
