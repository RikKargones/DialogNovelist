extends VBoxContainer

class_name BlockInfoUi

var block_path : NodeBlockPath = NodeBlockPath.new()


func _init() -> void:
	size_flags_horizontal = SIZE_EXPAND_FILL


func set_blockinfo_path(new_block_path : NodeBlockPath) -> void:
	if !is_instance_valid(new_block_path): return
	
	EditLibraly.disconect_incoming_signals(["block_sinhronized", "connections_updated", "msg_recived", "msg_recived_from_back", "msg_recived_from_next"], self)
	
	var nodeinfo = new_block_path.get_node_info()
	
	if !is_instance_valid(nodeinfo): return
	
	block_path = new_block_path
	name = new_block_path.block
	
	_load_blockinfo()
	
	nodeinfo.connect("msg_recived", self, "_on_msg_recive")
	nodeinfo.connect("msg_recived_from_back", self, "_on_msg_recive_from_back")
	nodeinfo.connect("msg_recived_from_next", self, "_on_msg_recive_from_next")
	nodeinfo.connect("block_sinhronized", self, "on_block_sinhronization", [block_path.node])
	nodeinfo.connect("connections_updated", self, "_on_connections_update")
	

func on_block_sinhronization(block_key : String, node_key : String) -> void:
	if block_path.block != block_key || block_path.node != node_key: return
	
	_update_ui()


func is_block_fresh() -> bool:
	var nodeinfo = block_path.get_node_info()
	
	return is_instance_valid(nodeinfo) && nodeinfo.is_block_fresh(block_path.block)


func get_nodeinfo_copy() -> EditorNodeInfo:
	return EditLibraly.duplacate_scripted_object(block_path.get_node_info())


func get_blockinfo_copy() -> NodeBlockInfo:
	return EditLibraly.duplacate_scripted_object(block_path.get_block_info())


func _load_blockinfo() -> void:
	pass
	
	
func _update_ui() -> void:
	pass
	
	
func _on_connections_update() -> void:
	_update_ui()


func _on_msg_recive(msg : NodeInfoMsg) -> void:
	pass


func _on_msg_recive_from_next(msg : NodeInfoMsg) -> void:
	pass


func _on_msg_recive_from_back(msg : NodeInfoMsg) -> void:
	pass


func _get_blockinfo_script() -> GDScript:
	return null
