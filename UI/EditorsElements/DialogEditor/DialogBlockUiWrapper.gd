extends PanelContainer

onready var all_holder 			= $All/Contents
onready var delete_bt			= $All/CommonSettings/DelBt
onready var blocker				= $All/Contents/Blocker
onready var connect_bt			= $All/CommonSettings/ConnectBt
onready var connect_checkbox	= $All/CommonSettings/ConnectSet

var block_ui 			: BlockInfoEditUi
var other_connect_key 	: String = ""

signal connect_mode(enabled, other_block_key)

func _ready():
	connect_checkbox.visible = false
	blocker.visible = false


func get_nodeinfo() -> EditorNodeInfo:
	if !is_instance_valid(block_ui) || !is_instance_valid(block_ui.block_path): return null
	
	return block_ui.block_path.get_node_info()
	

func get_block_key() -> String:
	if !is_instance_valid(block_ui) || !is_instance_valid(block_ui.block_path): return ""
	
	return block_ui.block_path.block


func swap_holded_block(new_block_ui : BlockInfoEditUi) -> void:
	if is_instance_valid(block_ui):
		block_ui.queue_free()
	
	block_ui = new_block_ui
	
	if is_instance_valid(block_ui):
		all_holder.add_child(block_ui)
		all_holder.move_child(block_ui, 0)
		
		block_ui.size_flags_horizontal = SIZE_EXPAND_FILL


func set_connect_checkbox_enabled(enabled : bool, other_block_key : String = "") -> void:
	var nodeinfo = get_nodeinfo()
	var block_key = get_block_key()
	
	if !is_instance_valid(nodeinfo) || block_key == "": return
	
	if enabled:
		other_connect_key = other_block_key
		connect_checkbox.pressed = nodeinfo.is_keys_sinhronized(other_connect_key, block_key)		
		if !connect_checkbox.is_connected("toggled", self, "on_connect_set_bt_toggle"):
			connect_checkbox.connect("toggled", self, "on_connect_set_bt_toggle")
	else:
		other_connect_key = ""
		if connect_checkbox.is_connected("toggled", self, "on_connect_set_bt_toggle"):
			connect_checkbox.disconnect("toggled", self, "on_connect_set_bt_toggle")
	
	var in_mode = (nodeinfo.has_block(other_connect_key) && enabled)
	
	connect_bt.visible = !in_mode
	connect_checkbox.visible = in_mode
	blocker.visible = in_mode


func on_connect_set_bt_toggle(pressed : bool) -> void:
	var nodeinfo = get_nodeinfo()
	var block_key = get_block_key()
	
	if !is_instance_valid(nodeinfo) || block_key == "" || other_connect_key == "": return
	
	if pressed: nodeinfo.connect_sinhronize_keys(other_connect_key, block_key)
	else: nodeinfo.disconnect_sinhronisze_keys(other_connect_key, block_key)


func _on_DelBt_pressed() -> void:
	var nodeinfo = get_nodeinfo()
	
	if is_instance_valid(nodeinfo):
		nodeinfo.erase_block(block_ui.block_path.block)
			
	queue_free()
	

func _on_ConnectBt_toggled(button_pressed : bool) -> void:
	if get_block_key() == "": return
	
	blocker.visible = button_pressed
	
	emit_signal("connect_mode", button_pressed, get_block_key())
