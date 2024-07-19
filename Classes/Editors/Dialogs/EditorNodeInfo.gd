extends NodeInfo

class_name EditorNodeInfo

export var fresh_blocks			: Array
export var block_pcks 			: Resource = UnicDict.new()
export var offset 				: Vector2
export var sinhronize_connects	: Resource = UnicDict.new()

signal block_aded
signal block_sinhronized
signal block_erased

signal connections_updated
signal msg_recived(msg)
signal msg_recived_from_next(msg)
signal msg_recived_from_back(msg)


func _init(node_info = NodeInfo.new()) -> void:
	if !is_instance_valid(node_info): return
	
	for key in node_info.blocks.keys():
		blocks.add_key(key, node_info.blocks.get_value(key))


func get_edit_pck_path(block_key : String) -> DialogEditorUiPathBase:
	var path = block_pcks.get_value(block_key)
	
	if path is DialogEditorUiPathBase: return path
	return null


func is_keys_sinhronized(first_key : String, second_key : String) -> bool:
	if !sinhronize_connects.has(first_key) || !sinhronize_connects.has(second_key): return false
	
	return sinhronize_connects.get_value(first_key).has(second_key)


func get_key_sinhronize_list(key : String) -> Array:
	if !sinhronize_connects.has(key): return []
	
	return sinhronize_connects.get_value(key)


func sinhronize_keys(key : String) -> void:
	if !sinhronize_connects.has(key): return
	
	var first_blockinfo = get_block(key)
	
	if !is_instance_valid(first_blockinfo): return
	
	for second_key in get_key_sinhronize_list(key):
		var second_blockinfo = get_block(second_key)
		
		if !is_instance_valid(second_blockinfo): continue
		
		EditLibraly.copy_object_propertys(first_blockinfo, second_blockinfo)
		
		var silent_change = second_blockinfo.is_connected("changed", self, "sinhronize_keys")
		if silent_change: second_blockinfo.disconnect("changed", self, "sinhronize_keys")
		second_blockinfo.emit_changed()
		emit_signal("block_sinhronized", second_key)
		if silent_change: second_blockinfo.connect("changed", self, "sinhronize_keys", [second_key])


func connect_sinhronize_keys(first_key : String, second_key : String) -> void:
	if first_key == second_key || is_keys_sinhronized(first_key, second_key): return
	
	var first_blockinfo = get_block(first_key)
	var second_blockinfo = get_block(second_key)
	
	if is_instance_valid(first_blockinfo) && is_instance_valid(second_blockinfo):
		if !first_blockinfo.is_connected("changed", self, "sinhronize_keys"):
			first_blockinfo.connect("changed", self, "sinhronize_keys", [first_key])
		if !second_blockinfo.is_connected("changed", self, "sinhronize_keys"):
			second_blockinfo.connect("changed", self, "sinhronize_keys", [second_key])
		
		if sinhronize_connects.has(first_key):
			if !sinhronize_connects.get_value(first_key).has(second_key):
				sinhronize_connects.get_value(first_key).append(second_key)
		else:
			sinhronize_connects.add_key(first_key, [second_key])
			
		if sinhronize_connects.has(second_key):
			if !sinhronize_connects.get_value(second_key).has(first_key):
				sinhronize_connects.get_value(second_key).append(first_key)
		else:
			sinhronize_connects.add_key(second_key, [first_key])
			
		sinhronize_keys(first_key)


func disconnect_sinhronisze_keys(first_key : String, second_key : String) -> void:
	if first_key == second_key || !is_keys_sinhronized(first_key, second_key): return
	
	var first_blockinfo = get_block(first_key)
	var second_blockinfo = get_block(second_key)
	
	if is_instance_valid(first_blockinfo) && is_instance_valid(second_blockinfo):
		if sinhronize_connects.has(first_key):
			var connect_info : Array = sinhronize_connects.get_value(first_key)
			connect_info.erase(second_key)
			if connect_info.size() == 1: sinhronize_connects.erase(first_key)
			
		if sinhronize_connects.has(second_key):
			var connect_info : Array = sinhronize_connects.get_value(second_key)
			connect_info.erase(first_key)
			if connect_info.size() == 1: sinhronize_connects.erase(second_key)
		
		if first_blockinfo.is_connected("changed", self, "sinhronize_keys") && !sinhronize_connects.has(first_key):
			first_blockinfo.disconnect("changed", self, "sinhronize_keys")
		if second_blockinfo.is_connected("changed", self, "sinhronize_keys") && !sinhronize_connects.has(second_key):
			second_blockinfo.disconnect("changed", self, "sinhronize_keys")


func recive_msg(msg : NodeInfoMsg) -> void:
	emit_signal("msg_recived", msg)


func recive_msg_from_next(msg : NodeInfoMsg) -> void:
	recive_msg(msg)
	emit_signal("msg_recived_from_next", msg)


func recive_msg_from_back(msg : NodeInfoMsg) -> void:
	recive_msg(msg)
	emit_signal("msg_recived_from_back", msg)


func init_block(block_key : String) -> void:
	var paths = get_edit_pck_path(block_key)
	
	if !EditLibraly.is_dialog_editor_ui_path_valid(paths) || is_instance_valid(get_block(block_key)): return
	
	var graph_ui = paths.graph_node_ui_scene.instance()
	var new_script = graph_ui._get_blockinfo_script().new()
	
	new_script.resource_local_to_scene = true
	blocks.set_key(block_key, new_script)
	fresh_blocks.append(block_key)


func is_block_fresh(block_key : String) -> bool:
	return block_key in fresh_blocks
	

func add_block(pck_path : DialogEditorUiPathBase, set_data : NodeBlockInfo = null) -> String:
	if !EditLibraly.is_dialog_editor_ui_path_valid(pck_path): return ""
	
	var final_key : String = FilesData.make_string_nambered(pck_path.base_key, get_blocks_list())
	
	block_pcks.add_key(final_key, pck_path)
	blocks.add_key(final_key, set_data)
	
	if !is_instance_valid(set_data):
		init_block(final_key)
		
	sort_blocks()
	
	emit_signal("block_aded", final_key)
	
	return final_key


func sort_blocks() -> void:
	var first_offset = 0
	
	for block in block_pcks.keys():
		var block_pck : DialogEditorUiPathBase = block_pcks.get_value(block)
		
		if !is_instance_valid(block_pck): continue
		
		match block_pck.order_flag:
			DialogEditorUiPathBase.OrderFlag.ALWAYS_FIRST:
				block_pcks.move_key_position(block, first_offset)
				blocks.move_key_position(block, first_offset)
				first_offset += 1
			DialogEditorUiPathBase.OrderFlag.ALWAYS_LAST:
				block_pcks.move_key_position(block, block_pcks.keys().size())
				blocks.move_key_position(block, blocks.keys().size())


func save_block(block_key : String, from_data : NodeBlockInfo) -> void:
	var block = get_block(block_key)
	
	if !is_instance_valid(block) || !is_instance_valid(from_data) || block.get_script() != from_data.get_script(): return
	
	fresh_blocks.erase(block_key)
	
	EditLibraly.copy_object_propertys(from_data, block)
	block.emit_changed()

	
func erase_block(key : String) -> void:
	if !blocks.has(key): return
	blocks.erase(key)
	block_pcks.erase(key)
	sinhronize_connects.erase(key)
	fresh_blocks.erase(key)
	
	for other_key in sinhronize_connects.keys():
		sinhronize_connects.get_value(other_key).erase(key)
	
	emit_signal("block_erased", key)
