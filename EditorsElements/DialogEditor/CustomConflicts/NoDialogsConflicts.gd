extends ConflictCheck

class_name NoDialogsConflicts

func _custom_check(_nodeinfo_pcks : Array) -> bool:	
	return DialogsData.get_dialogs_dict().keys().size() < 2
