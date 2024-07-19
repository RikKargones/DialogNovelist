extends BlockInfoUi

class_name BlockInfoGraphUi

var other_controls 	: Array

signal enable_main_port(enabled)
signal resize_ports(by)


func send_msg_back(msg : NodeInfoMsg, to = "") -> void:
	if !is_instance_valid(block_path) || !is_instance_valid(block_path.get_dialog_info()): return
	
	if to == "": to = msg.origin
	
	block_path.get_dialog_info().send_msg_to_node(msg, to)


func set_main_port_enable(enabled : bool) -> void:
	emit_signal("enable_main_port", enabled)


func resize_ports(by : Array) -> void:
	other_controls = by
	emit_signal("resize_ports", by)


func get_port(port_id : int) -> Control:
	if port_id < 0 || port_id >= other_controls.size(): return null
	return other_controls[port_id]


func _load_blockinfo() -> void:
	EditLibraly.disconect_incoming_signals(["changed"], self)
	block_path.get_block_info().connect("changed", self, "_update_ui")
	_update_ui()
	
