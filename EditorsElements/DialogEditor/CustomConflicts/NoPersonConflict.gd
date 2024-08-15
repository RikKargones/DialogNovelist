tool
extends ConflictCheck

class_name NoPersonConflictCheck

func _custom_check(_nodeinfo_pcks : Array) -> bool:
	return PersonsData.get_person_dict().keys().size() == 0
