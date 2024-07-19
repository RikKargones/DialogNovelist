extends Node	

var dialogs : UnicDict = UnicDict.new()

func _ready():
	pass


func add_dialog(dialog_name : String) -> void:
	dialogs.add_key(dialog_name, EditorDialogInfo.new())


func get_dialog(dialog_name : String) -> EditorDialogInfo:
	return dialogs.get_value(dialog_name)


func rename_dialog(new_name : String, old_name : String) -> void:
	dialogs.rename_key(old_name, new_name)
	
	
func remove_dialog(dialog_name : String) -> void:
	dialogs.erase(dialog_name)
