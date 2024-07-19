extends BlockInfoUi

class_name BlockInfoEditUi

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


func _load_blockinfo() -> void:
	on_load = !get_nodeinfo_copy().is_block_fresh(block_path.block) #Prevents changes while loading alredy edited block
	
	_update_ui()
	
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


func is_loading() -> bool:
	return on_load


func save_changes(save_blockinfo : NodeBlockInfo) -> void:
	var nodeinfo = get_nodeinfo_copy()
	
	if !is_instance_valid(nodeinfo) || is_loading(): return
	
	nodeinfo.save_block(block_path.block, save_blockinfo)
	

func save_changes_forced(save_blockinfo : NodeBlockInfo) -> void:
	var nodeinfo = get_nodeinfo_copy()
	
	if !is_instance_valid(nodeinfo): return
	
	nodeinfo.save_block(block_path.block, save_blockinfo)
