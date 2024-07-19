extends Node

class_name DialogProcessor

export (Resource) 	var dialog_data 		: Resource 	= DialogInfo.new() 	setget set_dialog_data
export (bool)		var minimalist_mode 	: bool		= false


func start_dialog() -> void:
	pass


func restore_dialog(dialog_state : DialogState) -> void:
	pass


func set_dialog_data(new_dialog : DialogInfo) -> void:
	if !is_instance_valid(new_dialog):
		dialog_data = DialogInfo.new()
		return
		
	dialog_data = new_dialog
	
