extends VBoxContainer

class_name BlockInfoGraphUi

var path_to_block 	: NodeBlockPath 	= NodeBlockPath.new()
var other_controls 	: Array

signal add_port(control)
signal replace_port(old_control, new_control)
signal erase_port(control)


func _update_ui() -> void:
	pass


func _on_msg_recive(msg : NodeInfoMsg) -> void:
	pass


func _on_msg_recive_from_next(msg : NodeInfoMsg) -> void:
	pass


func _on_msg_recive_from_back(msg : NodeInfoMsg) -> void:
	pass


func _on_connections_update() -> void:
	pass
	

func _get_blockinfo_script() -> GDScript:
	return null


func add_port(new_port : Control) -> Control:
	emit_signal("add_port", new_port)
	
	if new_port.is_inside_tree():
		other_controls.append(new_port)
		return new_port
	
	new_port.queue_free()
	
	return null


func has_port(pos : int) -> bool:
	return pos >= 0 && pos < other_controls.size() && is_instance_valid(other_controls[pos])


func get_port(pos : int) -> Control:
	if !has_port(pos): return null
	
	return other_controls[pos]

	
func erase_port(control : Control) -> void:
	if !control in other_controls: return
	
	emit_signal("erase_port", control)
	other_controls.erase(control)


func clear_ports() -> void:
	for control in other_controls:
		emit_signal("erase_port", control)
	
	other_controls.clear()


func send_msg_back(msg : NodeInfoMsg, to = "") -> void:
	if to == "": to = msg.origin
	path_to_block.get_dialog_info().send_msg_to_node(msg, to)


func resize_ports(by : Array) -> void:
	if by.size() == 0:
		clear_ports()
		return
	
	for port_id in by.size():
		if !by[port_id] is Control: by[port_id] = Control.new()
		
		if other_controls.size() > port_id:
			emit_signal("replace_port", other_controls[port_id], by[port_id])
			other_controls[port_id] = by[port_id]
		else:
			add_port(by[port_id])
	
	if other_controls.size() > by.size():
		var unnecessary_list = []
		
		for unnecessary_id in range(other_controls.size()-1, by.size() - 1, -1):
			erase_port(other_controls[unnecessary_id])
		

func bound_to_block(nodeinfo_path : NodeInfoPath, block_key : String) -> void:
	path_to_block.dialog 	= nodeinfo_path.dialog
	path_to_block.node 		= nodeinfo_path.node
	path_to_block.block 	= block_key
	name = block_key
	
	var blockinfo = path_to_block.get_block_info()
	
	if is_instance_valid(blockinfo):
		var nodeinfo = path_to_block.get_node_info()
		
		EditLibraly.disconect_incoming_signals(["changed", "msg_recived", "msg_recived_from_back", "msg_recived_from_next", "connections_updated"], self)
		
		blockinfo.connect("changed", self, "_update_ui")
		nodeinfo.connect("connections_updated", self, "_update_ui")
		nodeinfo.connect("msg_recived", self,"_on_msg_recive")
		nodeinfo.connect("msg_recived_from_back", self, "_on_msg_recive_from_back")
		nodeinfo.connect("msg_recived_from_next", self, "_on_msg_recive_from_next")
		
	_update_ui()
