extends GraphNode

class_name DialogNodeUi

var nodeinfo_path 		: NodeInfoPath = NodeInfoPath.new()
var update_size_timer 	: SceneTreeTimer

var block_uis = {}

signal need_disconect(index)


func _ready():
	show_close = true
	resizable = true
	rect_min_size = Vector2(100, 50)
	connect("dragged", self, "on_dargging")


func _exit_tree():
	if is_instance_valid(update_size_timer):
		update_size_timer.disconnect("timeout", self, "on_timer_size_update")


func clear_node() -> void:
	for child in get_children():
		child.queue_free()
		
	block_uis.clear()


func get_info_block_wrapper() -> VBoxContainer:
	var old_wrapper = get_node_or_null("BlockInfoWrapper")
	
	if is_instance_valid(old_wrapper):
		if old_wrapper is VBoxContainer: return old_wrapper
		else: old_wrapper.queue_free()
	
	var new_wrapper = VBoxContainer.new()
	new_wrapper.name = "BlockInfoWrapper"
	
	add_child(new_wrapper)
	move_child(new_wrapper, 0)
	set_slot_enabled_left(0, true)
	set_slot_enabled_right(0, true)
	
	return new_wrapper


func has_block(block : BlockInfoGraphUi) -> bool:
	if !is_instance_valid(block): return false
	
	for child in get_info_block_wrapper().get_children():
		if child.get_child(0) == block: return true
		
	return false


func has_blockui(control : Control, block : BlockInfoGraphUi) -> bool:
	return has_block(block) && block_uis.has(block) && control in block_uis[block]


func add_port_control(control : Control, block_to_bound : BlockInfoGraphUi) -> void:
	if !has_block(block_to_bound) || has_blockui(control, block_to_bound) || !is_instance_valid(control): return
	
	var new_wrapper = PanelContainer.new()
	var new_label	= Label.new()
	var new_vbox	= VBoxContainer.new()
	
	if block_uis.has(block_to_bound): block_uis[block_to_bound].append(control)
	else: block_uis[block_to_bound] = [control]
	
	add_child(new_wrapper)
	new_wrapper.add_child(new_vbox)
	new_vbox.add_child(new_label)
	new_vbox.add_child(control)
	
	if block_uis[block_to_bound].size() > 1:
		var prev_child : Control = block_uis[block_to_bound][block_uis[block_to_bound].size() - 2]
		move_child(new_wrapper, prev_child.get_parent().get_parent().get_index() + 1)
	
	new_label.text = block_to_bound.path_to_block.block + " block port"
	
	set_slot_enabled_right(new_wrapper.get_index(), true)
	
	on_block_ui_resize()
	

func replace_port_control(old_control : Control, new_control : Control, bounded_block : BlockInfoGraphUi) -> void:
	if !has_blockui(old_control, bounded_block) || has_blockui(new_control, bounded_block): return
	
	old_control.replace_by(new_control)
	
	block_uis[bounded_block][block_uis[bounded_block].find(old_control)] = new_control

	
func erase_port_control(control : Control, bounded_block : BlockInfoGraphUi) -> void:
	if !has_blockui(control, bounded_block): return
	
	var wrapper = control.get_parent().get_parent()
	
	emit_signal("need_disconect", wrapper.get_index())
	
	wrapper.queue_free()
	
	block_uis[bounded_block].erase(control)
	
	if block_uis[bounded_block].size() == 0: block_uis.erase(bounded_block)
	
	on_block_ui_resize()
	
	
func add_info_block(infoblock : BlockInfoGraphUi) -> void:
	var wrapper = get_info_block_wrapper()
	var new_panel = PanelContainer.new()
	
	wrapper.add_child(new_panel)
	new_panel.add_child(infoblock)
	
	infoblock.connect("add_port", self, "add_port_control", [infoblock])
	infoblock.connect("replace_port", self, "replace_port_control", [infoblock])
	infoblock.connect("erase_port", self, "erase_port_control", [infoblock])
	infoblock.connect("item_rect_changed", self, "on_block_ui_resize")
	
	on_block_ui_resize()


func erase_info_block(infoblock : BlockInfoGraphUi) -> void:
	if !has_block(infoblock): return
	
	if block_uis.has(infoblock):
		for control in block_uis[infoblock]:
			erase_port_control(control, infoblock)
		
	infoblock.get_parent().queue_free()
	
	var wrapper = get_info_block_wrapper()
	
	if wrapper.get_child_count() == 0:
		emit_signal("need_disconect", wrapper.get_index())
		wrapper.queue_free()
		
	on_block_ui_resize()
		
		
func bound_to_nodeinfo(path_to_nodeinfo : NodeInfoPath) -> void:
	if !is_instance_valid(path_to_nodeinfo) || !is_instance_valid(path_to_nodeinfo.get_node_info()): return
	
	nodeinfo_path = path_to_nodeinfo
	
	reload_ui()


func get_nodeinfo() -> EditorNodeInfo:
	if is_instance_valid(nodeinfo_path): return nodeinfo_path.get_node_info()
	return null

	
func reload_ui() -> void:
	clear_node()
		
	var nodeinfo : EditorNodeInfo = get_nodeinfo()
	
	if !is_instance_valid(nodeinfo): return
	
	EditLibraly.disconect_incoming_signals(["block_aded", "block_erased"], self)
	
	nodeinfo.offset = offset
	nodeinfo.connect("block_aded", self, "add_block")
	nodeinfo.connect("block_erased", self, "erase_block")
	
	for block_key in nodeinfo.get_blocks_list():
		add_block(block_key)


func add_block(block_key : String) -> void:
	var nodeinfo : EditorNodeInfo = get_nodeinfo()
	
	if !is_instance_valid(nodeinfo): return
	
	var block_pck = nodeinfo.get_edit_pck_path(block_key)
	
	if !EditLibraly.is_dialog_editor_ui_path_valid(block_pck): return
	
	var new_info_block = block_pck.graph_node_ui_scene.instance()
	
	if new_info_block is BlockInfoGraphUi:
		nodeinfo.connect("msg_recived_from_next", new_info_block, "_on_msg_recive_from_next")
		nodeinfo.connect("msg_recived_from_back", new_info_block, "_on_msg_recive_from_back")
		nodeinfo.connect("msg_recived_from_back", new_info_block, "_on_msg_recive")
		nodeinfo.connect("msg_recived_from_next", new_info_block, "_on_msg_recive")
		add_info_block(new_info_block)
		new_info_block.bound_to_block(nodeinfo_path, block_key)


func erase_block(block_key : String) -> void:
	var node = null
	
	for child in get_info_block_wrapper().get_children():
		node = child.get_node_or_null(block_key)
		if is_instance_valid(node):
			erase_info_block(node)
			break


func on_dargging(_from : Vector2, _to : Vector2) -> void:
	var nodeinfo = get_nodeinfo()
	
	if is_instance_valid(nodeinfo): nodeinfo.offset = offset
	

func on_block_ui_resize() -> void:
	if is_instance_valid(update_size_timer):
		update_size_timer.disconnect("timeout", self, "on_timer_size_update")
		
	update_size_timer = get_tree().create_timer(0.01)
	update_size_timer.connect("timeout", self, "on_timer_size_update")
	
	
func on_timer_size_update() -> void:
	rect_size = Vector2()
