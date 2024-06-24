_CLASS_INDEX_TO_NAME = {
    # Binary
    0: "healthy",
    1: "faulty",
    
    # Multi-class
    2: "impulse",
    3: "additional component",
    4: "frequency modulation",
    5: "amplitude modulation",
    6: "frequency and amplitude modulation",
    7: "impulse and additional component",
    8: "impulse and frequency modulation",
    9: "impulse and amplitude modulation",
    10: "impulse, frequency and amplitude modulation"
}

def map_class_index_to_name(class_index: int) -> str:
    assert class_index in _CLASS_INDEX_TO_NAME.keys(), f"Class {class_index} is not known."
    
    return _CLASS_INDEX_TO_NAME[class_index]
