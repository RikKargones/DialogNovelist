extends Node	


func get_dialogs_dict() -> UnicDict:
	if !is_instance_valid(Project): return UnicDict.new()
	return Project.get_project_info().dialogs_data as UnicDict


func add_dialog(dialog_name : String) -> void:
	get_dialogs_dict().add_key(dialog_name, EditorDialogInfo.new())


func get_dialog(dialog_name : String) -> EditorDialogInfo:
	return get_dialogs_dict().get_value(dialog_name)


func rename_dialog(new_name : String, old_name : String) -> void:
	get_dialogs_dict().rename_key(old_name, new_name)
	
	
func remove_dialog(dialog_name : String) -> void:
	get_dialogs_dict().erase(dialog_name)
