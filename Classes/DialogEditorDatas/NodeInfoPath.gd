extends Resource

class_name NodeInfoPath

export var dialog 	: String
export var node		: String

func _init(dialog_name = "", node_name = "") -> void:
	dialog = dialog_name
	node = node_name
	

func is_node_exist() -> bool:
	return is_instance_valid(get_node_info())

	
func get_dialog_info() -> EditorDialogData:
	return DialogsData.get_dialog(dialog)


func get_node_info() -> EditorNodeInfo:
	var dialog_data : EditorDialogData = DialogsData.get_dialog(dialog)
	
	if is_instance_valid(dialog_data):
		var node_info = dialog_data.get_node(node)
		if node_info is EditorNodeInfo: return node_info
		return EditorNodeInfo.new(node_info)
		
	return null
