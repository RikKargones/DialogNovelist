extends VBoxContainer

class_name BlockInfoEditUi

var block_path : NodeBlockPath = NodeBlockPath.new()

var prev_nodes = []

var on_load = false

func form_locale_key(end_key : String) -> String:
	return PoolStringArray([block_path.dialog, block_path.node, block_path.block, end_key]).join("_").replace(" ", "_")


func add_locale_key(end_key : String, defalut : String = "") -> String:
	var locale_key = form_locale_key(end_key)
	LocalesData.add_locales_msg(locale_key, defalut)
	return locale_key


func rename_locale_key(old_full_key : String, new_key_end : String) -> String:
	var new_locale_key = form_locale_key(new_key_end)
	
	if !LocalesData.has_locale_msg(old_full_key) && LocalesData.has_locale_msg(new_locale_key): return ""
	
	LocalesData.rename_locale_msg(old_full_key, new_locale_key)
	return new_locale_key


func erase_locale_key(end_key : String) -> void:
	LocalesData.erase_locales_msg(form_locale_key(end_key))


func set_blockinfo_path(new_block_path : NodeBlockPath) -> void:
	if !is_instance_valid(new_block_path): return
	
	EditLibraly.disconect_incoming_signals(["block_sinhronized", "connections_updated", "msg_recived", "msg_recived_from_back", "msg_recived_from_next"], self)
	
	var nodeinfo = new_block_path.get_node_info()
	
	if !is_instance_valid(nodeinfo): return
	
	block_path = new_block_path
	
	on_load = !nodeinfo.is_block_fresh(block_path.block) #Prevents changes while loading alredy edited block
	
	nodeinfo.connect("msg_recived", self, "_on_msg_recive")
	nodeinfo.connect("msg_recived_from_back", self, "_on_msg_recive_from_back")
	nodeinfo.connect("msg_recived_from_next", self, "_on_msg_recive_from_next")
	
	_update_ui()
	
	nodeinfo.connect("block_sinhronized", self, "on_block_sinhronization", [block_path.node])
	nodeinfo.connect("connections_updated", self, "_on_connections_update")
	
	on_load = false


func send_msg_to_next_nodes(msg : NodeInfoMsg) -> void:
	var diainfo	= block_path.get_dialog_info()
	
	if !is_instance_valid(diainfo): return
	
	msg.origin = block_path.node
	
	diainfo.send_msg_to_next_nodes(msg)
	
	
func send_msg_to_back_nodes(msg : NodeInfoMsg) -> void:
	var diainfo	= block_path.get_dialog_info()
	
	if !is_instance_valid(diainfo): return
	
	msg.origin = block_path.node
	
	diainfo.send_msg_to_back_nodes(msg)


func is_block_fresh() -> bool:
	var nodeinfo = block_path.get_node_info()
	
	return is_instance_valid(nodeinfo) && nodeinfo.is_block_fresh(block_path.block)


func get_nodeinfo_copy() -> EditorNodeInfo:
	return EditLibraly.duplacate_scripted_object(block_path.get_node_info())


func get_blockinfo_copy() -> DialogDispetcher.NodeBlockInfo:
	return EditLibraly.duplacate_scripted_object(block_path.get_block_info())


func is_loading() -> bool:
	return on_load


func save_changes(save_blockinfo : DialogDispetcher.NodeBlockInfo) -> void:
	var nodeinfo = get_nodeinfo_copy()
	
	if !is_instance_valid(nodeinfo) || is_loading(): return
	
	nodeinfo.save_block(block_path.block, save_blockinfo)
	

func save_changes_forced(save_blockinfo : DialogDispetcher.NodeBlockInfo) -> void:
	var nodeinfo = get_nodeinfo_copy()
	
	if !is_instance_valid(nodeinfo): return
	
	nodeinfo.save_block(block_path.block, save_blockinfo)


func on_block_sinhronization(block_key : String, node_key : String) -> void:
	if block_path.block != block_key || block_path.node != node_key: return
	
	_update_ui()


func _update_ui() -> void:
	pass
	
	
func _on_connections_update() -> void:
	pass


func _on_msg_recive(msg : NodeInfoMsg) -> void:
	pass


func _on_msg_recive_from_next(msg : NodeInfoMsg) -> void:
	pass


func _on_msg_recive_from_back(msg : NodeInfoMsg) -> void:
	pass


func _get_blockinfo_script() -> GDScript:
	return null
