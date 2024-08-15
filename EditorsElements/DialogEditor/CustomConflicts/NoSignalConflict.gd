tool
extends ConflictCheck

class_name NoSignalConflictCheck

func _custom_check(_nodeinfo_pcks : Array) -> bool:
	return VariblesData.get_signals_dict().keys().size() == 0
