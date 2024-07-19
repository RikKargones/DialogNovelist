extends BlockInfoGraphUi

onready var dialog_next_name 	= $Dialog/DialogName
onready var dialog_point_name 	= $Dialog/PointName


func _update_ui() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_NextDialog:		
		emit_signal("enable_main_port", false)
		
		if blockinfo.dialog_name == "":
			dialog_next_name.text = Constants.none_key_name
		else:
			dialog_next_name.text = blockinfo.dialog_name
		
		if blockinfo.dialog_start_point == "":
			dialog_point_name.text = Constants.none_key_name
		else:
			dialog_point_name.text = blockinfo.dialog_start_point


func _exit_tree():
	emit_signal("enable_main_port", true)


func _get_blockinfo_script() -> GDScript:
	return NBI_NextDialog
	
