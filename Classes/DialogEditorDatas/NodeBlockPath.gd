extends NodeInfoPath

class_name NodeBlockPath

export var block : String

func _init(dialog_name = "", node_name = "", block_key = "") -> void:
	dialog = dialog_name
	node = node_name
	block = block_key


func get_block_info() -> NodeBlockInfo:
	var node_info : EditorNodeInfo = get_node_info()
	if is_instance_valid(node_info): return node_info.get_block(block)
	return null


func _to_string() -> String:
	return dialog + "\\" + node + "\\" + block
