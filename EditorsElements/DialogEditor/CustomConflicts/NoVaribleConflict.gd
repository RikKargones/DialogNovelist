tool
extends ConflictCheck

class_name NoVaribleConflictCheck

func _custom_check(_nodeinfo_pcks : Array) -> bool:
	return VariblesData.get_varibles_list().size() == 0
