function fault_type = update_fault_type(previous_fault_type, new_fault_type)
    if previous_fault_type == FaultTypes.HEALTHY
        fault_type = new_fault_type;
    elseif previous_fault_type == FaultTypes.IMPULSE
        if new_fault_type == FaultTypes.ADDITIONAL_COMPONENT
            fault_type = FaultTypes.IMPULSE_AND_ADDITIONAL_COMPONENT;
        elseif new_fault_type == FaultTypes.FREQUENCY_MODULATION
            fault_type = FaultTypes.IMPULSE_AND_FREQUENCY_MODULATION;
        elseif new_fault_type == FaultTypes.AMPLITUDE_MODULATION
            fault_type = FaultTypes.IMPULSE_AND_AMPLITUDE_MODULATION;
        elseif new_fault_type == FaultTypes.FREQUENCY_AND_AMPLITUDE_MODULATION
            fault_type = FaultTypes.IMPULSE_AND_FREQUENCY_AND_AMPLITUDE_MODULATION;
        elseif new_fault_type == FaultTypes.HEALTHY
            fault_type = FaultTypes.IMPULSE;
        end
    else
        error("Faut type %s not suported", previous_fault_type)
    end
end