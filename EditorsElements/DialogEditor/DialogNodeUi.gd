extends GraphNode

class_name DialogNodeUi

var nodeinfo_path 		: NodeInfoPath 		= NodeInfoPath.new()
var update_size_timer 	: SceneTreeTimer

var block_uis : Dictionary

signal need_disconect(index)


class FreeGridContainer extends Container:
	var columns 		= 1 setget on_colums_set
	var h_separation 	= 1 setget on_h_separation_set
	var v_separation	= 1 setget on_v_separation_set
	
	func _notification(what):
		if what == NOTIFICATION_SORT_CHILDREN:			
			var sorted_controls : Array = []
			var min_v_size		: Array = []
			var min_h_size		: Array = []
			var current_line	: int	= 1
			
			for column in columns:
				min_h_size.append(0)
			
			for child in get_children():
				if !child is Control: continue
				
				if sorted_controls.size() < current_line:
					sorted_controls.append([])
					min_v_size.append(0)
				
				var current_line_arr : Array = sorted_controls[current_line - 1]
				var child_minsize : Vector2 = child.get_combined_minimum_size() 
				
				current_line_arr.append(child)
				
				if min_h_size[current_line_arr.size() - 1] < child_minsize.x:
					min_h_size[current_line_arr.size() - 1] = child_minsize.x
				if min_v_size[current_line - 1] < child_minsize.y:
					min_v_size[current_line - 1] = child_minsize.y
				
				if current_line_arr.size() == columns:
					current_line += 1
			
			if sorted_controls.size() == 0: return
			
			var v_pos	: Array = []
			var h_pos	: Array = []
			
			var last_row_idx = min_v_size.size() - 1
			var last_col_idx = min_h_size.size() - 1
			
			for pos in min_h_size.size():
				if pos == 0: h_pos.append(0)
				else: h_pos.append(h_pos[pos - 1] + min_h_size[pos - 1] + h_separation)
				
			for pos in min_v_size.size():
				if pos == 0: v_pos.append(0)
				else: v_pos.append(v_pos[pos - 1] + min_v_size[pos - 1] + v_separation)
			
			var v_combined_size = v_pos[last_row_idx] + min_v_size[last_row_idx]
			var h_combined_size = h_pos[last_col_idx] + min_h_size[last_col_idx]
			var v_diff = rect_size.y - v_combined_size
			var h_diff = rect_size.x - h_combined_size
			
			if v_diff > 0:
				for pos in min_v_size.size():
					min_v_size[pos] += v_diff / min_v_size.size()
					if pos != 0: v_pos[pos] += v_diff / min_v_size.size()
					
			if h_diff > 0:
				for pos in min_h_size.size():
					min_h_size[pos] += h_diff / min_h_size.size()
					if pos != 0: h_pos[pos] += h_diff / min_h_size.size()
			
			rect_min_size = Vector2(h_combined_size + min(0, -h_diff), v_combined_size + min(0, -v_diff))
			
			var last_row_h_pos		: Array
			var last_row_min_h_size : Array
			var last_row_count		: int	= sorted_controls[sorted_controls.size() - 1].size()
			
			if columns > last_row_count:
				for last_column in last_row_count:
					var diff_size = (h_combined_size - (min_h_size[last_row_count - 1] + h_pos[last_row_count - 1])) / last_row_count
					last_row_min_h_size.append(min_h_size[last_column] + diff_size)
					if last_column == 0: last_row_h_pos.append(0)
					else: last_row_h_pos.append(last_row_h_pos[last_column - 1] + last_row_min_h_size[last_column - 1])
			
			for row in sorted_controls.size():
				for column in sorted_controls[row].size():
					var control : Control = sorted_controls[row][column]
					var rect 	: Rect2
					
					if row == sorted_controls.size() - 1 && columns > last_row_count:
						rect = Rect2(last_row_h_pos[column], v_pos[row], last_row_min_h_size[column], min_v_size[row])
					else:
						rect = Rect2(h_pos[column], v_pos[row], min_h_size[column], min_v_size[row])
					
					fit_child_in_rect(control, rect)
		

	func on_colums_set(new_colums_set : int) -> void:
		columns = max(new_colums_set, 1)
		queue_sort()
		
	func on_h_separation_set(new_separation : int) -> void:
		h_separation = new_separation
		queue_sort()
	
	func on_v_separation_set(new_separation : int) -> void:
		v_separation = new_separation
		queue_sort()


func _ready():
	show_close = true
	resizable = true
	rect_min_size = Vector2(100, 50)
	
	connect("offset_changed", self, "on_dargging")


func _exit_tree():
	if is_instance_valid(update_size_timer):
		update_size_timer.disconnect("timeout", self, "on_timer_size_update")


func clear_node() -> void:
	for child in get_children():
		child.queue_free()
		
	block_uis.clear()


func get_info_block_wrapper() -> FreeGridContainer:
	var old_wrapper = get_node_or_null("BlockInfoWrapper")
	
	if is_instance_valid(old_wrapper):
		if old_wrapper is FreeGridContainer: return old_wrapper
		else: old_wrapper.queue_free()
	
	var new_wrapper = FreeGridContainer.new()
	new_wrapper.columns = 2
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


func get_blockui_controls_array(block : BlockInfoGraphUi) -> Array:
	if !has_block(block) || !block_uis.has(block): return []
	
	return block_uis[block].duplicate(true)


func clear_all_blockui_ports(bounded_block : BlockInfoGraphUi) -> void:
	for control in get_blockui_controls_array(bounded_block):
		if control is Control:
			control.get_parent().get_parent().queue_free()
			
	block_uis.erase(bounded_block)
	on_block_ui_resize()


func resize_port_controls(controls : Array, block_to_bound : BlockInfoGraphUi) -> void:
	var block_ui_controls = get_blockui_controls_array(block_to_bound)
	
	if controls.size() == 0:
		clear_all_blockui_ports(block_to_bound)
		return
	
	for control_idx in controls.size():
		if control_idx < block_ui_controls.size():
			replace_port_control(block_ui_controls[control_idx], controls[control_idx], block_to_bound)
		else:
			add_port_control(controls[control_idx], block_to_bound)
	
	if controls.size() < block_ui_controls.size():
		for control_idx in block_ui_controls.size() - controls.size():
			erase_port_control(block_ui_controls[block_ui_controls.size() - 1 - control_idx], block_to_bound)
	

func add_port_control(control : Control, block_to_bound : BlockInfoGraphUi) -> void:
	if !has_block(block_to_bound) || has_blockui(control, block_to_bound) || !is_instance_valid(control): return
	
	var new_wrapper = PanelContainer.new()
	var new_label	= Label.new()
	var new_vbox	= VBoxContainer.new()
	
	if block_uis.has(block_to_bound): block_uis[block_to_bound].append(control)
	else: block_uis[block_to_bound] = [control]
	
	add_child(new_wrapper, true)
	new_wrapper.add_child(new_vbox, true)
	new_vbox.add_child(new_label, true)
	new_vbox.add_child(control, true)
	
	if block_uis[block_to_bound].size() > 1:
		var prev_child : Control = block_uis[block_to_bound][block_uis[block_to_bound].size() - 2]
		move_child(new_wrapper, prev_child.get_parent().get_parent().get_index() + 1)
	
	new_label.text = block_to_bound.block_path.block + " block port"
	
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
	
	block_uis[bounded_block].erase(control)
	wrapper.queue_free()
	
	if block_uis[bounded_block].size() == 0:
		block_uis.erase(bounded_block)
	
	on_block_ui_resize()


func on_enable_main_port(enabled : bool) -> void:
	if !enabled: emit_signal("need_disconect", 0)
	
	set_slot_enabled_right(0, enabled)


func place_blocks_by_order() -> void:
	var wrapper = get_info_block_wrapper()
	var nodeinfo = nodeinfo_path.get_node_info()
	
	if !is_instance_valid(wrapper) || !is_instance_valid(nodeinfo): return
	
	var block_list = nodeinfo.get_blocks_list()
	
	for block_idx in block_list.size():
		if block_idx >= wrapper.get_child_count(): continue
		
		var panel_child = wrapper.get_child(block_idx)
		
		if is_instance_valid(panel_child) && is_instance_valid(panel_child.get_node_or_null(block_list[block_idx])):
			continue
			
		for child in wrapper.get_children():
			if is_instance_valid(child.get_node_or_null(block_list[block_idx])):
				wrapper.move_child(child, block_idx)
				break
	
	
func add_info_block(infoblock : BlockInfoGraphUi) -> void:
	var wrapper = get_info_block_wrapper()
	var new_panel = PanelContainer.new()
	
	infoblock.connect("item_rect_changed", self, "on_block_ui_resize")
	infoblock.connect("enable_main_port", self, "on_enable_main_port")
	
	wrapper.add_child(new_panel)
	new_panel.add_child(infoblock)
	
	infoblock.connect("resize_ports", self, "resize_port_controls", [infoblock])
	
	place_blocks_by_order()
	
	on_block_ui_resize()


func erase_info_block(infoblock : BlockInfoGraphUi) -> void:
	if !has_block(infoblock): return
	
	for control in get_blockui_controls_array(infoblock):
		erase_port_control(control, infoblock)
		
	infoblock.get_parent().queue_free()
	
	var wrapper = get_info_block_wrapper()
	
	if wrapper.get_child_count() == 0 || (wrapper.get_child_count() == 1 && wrapper.get_child(0).is_queued_for_deletion()):
		emit_signal("need_disconect", wrapper.get_index())
		set_slot_enabled_left(0, false)
		set_slot_enabled_right(0, false)
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
	
	offset = nodeinfo.offset
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
		add_info_block(new_info_block)
		new_info_block.set_blockinfo_path(NodeBlockPath.new(nodeinfo_path.dialog, nodeinfo_path.node, block_key))


func erase_block(block_key : String) -> void:
	var node = null
	
	for child in get_info_block_wrapper().get_children():
		node = child.get_node_or_null(block_key)
		if is_instance_valid(node):
			erase_info_block(node)
			break


func on_dargging() -> void:
	var nodeinfo = get_nodeinfo()
	
	if is_instance_valid(nodeinfo):
		nodeinfo.offset = offset
	

func on_block_ui_resize() -> void:
	if is_instance_valid(update_size_timer):
		update_size_timer.disconnect("timeout", self, "on_timer_size_update")
		
	update_size_timer = get_tree().create_timer(0.01)
	update_size_timer.connect("timeout", self, "on_timer_size_update")
	
	
func on_timer_size_update() -> void:
	rect_size = Vector2()
