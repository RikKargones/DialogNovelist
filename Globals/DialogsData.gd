extends Node	

var dialogs : DialogDispetcher.UnicDict = DialogDispetcher.UnicDict.new()

func _ready():
	pass


func add_dialog(dialog_name : String) -> void:
	dialogs.add_key(dialog_name, EditorDialogData.new())


func get_dialog(dialog_name : String) -> EditorDialogData:
	return dialogs.get_value(dialog_name)


func rename_dialog(old_name : String, new_name : String) -> void:
	dialogs.rename_key(old_name, new_name)
	
	
func remove_dialog(dialog_name : String) -> void:
	dialogs.erase(dialog_name)
