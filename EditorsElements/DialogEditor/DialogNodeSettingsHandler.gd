extends VBoxContainer

class_name DialogNodeSettingsHandler

const error_trow_name = "DIALOG_NODE_SETTINGS_HANDLER"

var node_path : NodeInfoPath = NodeInfoPath.new()

var wrapper_pck = preload("res://EditorsElements/DialogEditor/DialogBlockUiWrapper.tscn")


func load_block(block_key : String, move_to_pos = -1) -> void:
	var node_info : EditorNodeInfo = node_path.get_node_info()
	
	if !is_instance_valid(node_info):
		Ui.popup_error("Node info not seted!", error_trow_name)
		return
	
	var pck_path 	: DialogEditorUiPathBase 	= node_info.get_edit_pck_path(block_key)
	
	if !EditLibraly.is_dialog_editor_ui_path_valid(pck_path):
		Ui.popup_error("Packed scenes paths in nodeinfo not seted/incorrect!", error_trow_name)
		return
			
	var element = pck_path.edit_ui_scene.instance()
	
	if element is BlockInfoEditUi:
		var wrapper = wrapper_pck.instance()
		
		add_child(wrapper)
		wrapper.swap_holded_block(element)
		
		wrapper.name = block_key
		
		element.set_blockinfo_path(NodeBlockPath.new(node_path.dialog, node_path.node, block_key))
		
		if move_to_pos > -1 && move_to_pos < get_child_count(): move_child(wrapper, move_to_pos)
		
		wrapper.size_flags_horizontal = SIZE_EXPAND_FILL
		
		for child in get_children():
			if wrapper.get_script() == child.get_script() && wrapper != child:
				wrapper.connect("connect_mode", child, "set_connect_checkbox_enabled")
				child.connect("connect_mode", wrapper, "set_connect_checkbox_enabled")
		
		place_blocks_by_order()
	else:
		Ui.popup_error("Loaded packed scene not extends BlockInfoEditUi!", error_trow_name)
		element.queue_free()
		return


func place_blocks_by_order() -> void:
	var nodeinfo = node_path.get_node_info()
	
	if !is_instance_valid(nodeinfo): return
	
	var block_list = nodeinfo.get_blocks_list()
	
	for block_idx in block_list.size():
		var block = get_node_or_null(block_list[block_idx])
		
		if is_instance_valid(block):
			if block.get_index() == block_idx: continue
			else: move_child(block, block_idx)


func clear_handler() -> void:
	for child in get_children():
		child.queue_free()
	

func connect_to_nodeinfo(nodeinfo_path : NodeInfoPath) -> void:
	node_path.dialog 	= nodeinfo_path.dialog
	node_path.node 		= nodeinfo_path.node
	
	clear_handler()
	
	var nodeinfo : EditorNodeInfo = node_path.get_node_info()
	
	if !is_instance_valid(nodeinfo):
		Ui.popup_error("Can't find node " + node_path.node + " in dialog " + node_path.dialog + ".", error_trow_name)
		return
	
	EditLibraly.disconect_incoming_signals(["block_aded", "block_erased"], self)
	
	nodeinfo.connect("block_aded", self, "load_block")
	nodeinfo.connect("block_erased", self, "on_block_erase")
	
	for block_key in nodeinfo.get_blocks_list():
		load_block(block_key)
	

func on_block_erase(block_key : String) -> void:
	var element = get_node_or_null(block_key)
	
	if is_instance_valid(element):
		element.queue_free()
