extends BlockInfoEditUi

onready var dialog_pick = $Dialog/DialogPick
onready var start_pick	= $StartPoint/StartPointPick

const no_other_dialogs 	= "<No other dialogs!>"
const no_start_points 	= "<No start points!>"

func _ready():
	dialog_pick.connect_to_unicdict(DialogsData.dialogs)
	DialogsData.dialogs.connect("key_aded", self, "on_dialog_change")
	DialogsData.dialogs.connect("key_deleted", self, "on_dialog_change")
	on_dialog_change()


func on_dialog_change(_key : String = "") -> void:
	if DialogsData.dialogs.keys().size() < 2: dialog_pick.set_placeholder(no_other_dialogs)
	else: dialog_pick.set_placeholder("")


func _update_ui() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_NextDialog:
		dialog_pick.set_banned_items([block_path.dialog])
		dialog_pick.select_item(blockinfo.dialog_name)
		refresh_start_list(blockinfo.dialog_name)
		start_pick.select_item(blockinfo.dialog_start_point)
		
		if is_block_fresh():
			if blockinfo.dialog_name == "" && dialog_pick.text != "" && dialog_pick.text != no_other_dialogs:
				blockinfo.dialog_name = dialog_pick.text
			if blockinfo.dialog_start_point == "" && start_pick.text != "" && start_pick.text != no_other_dialogs && start_pick.text != no_start_points:
				blockinfo.dialog_start_point = start_pick.text
				
			save_changes(blockinfo)


func _get_blockinfo_script() -> GDScript:
	return NBI_NextDialog


func refresh_start_list(dialog_name : String) -> void:
	var dialog = DialogsData.get_dialog(dialog_name)
	
	if is_instance_valid(dialog):
		var start_points = dialog.get_start_nodes_names()
		
		if start_points.size() == 0:
			start_pick.set_placeholder(no_start_points)
		else:
			start_pick.set_placeholder("")
			
		start_pick.update_items(start_points)
	else:
		start_pick.set_placeholder(no_other_dialogs)
		start_pick.update_items([])


func _on_DialogPick_item_selected(item_name : String) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_NextDialog:		
		var dialog = DialogsData.get_dialog(item_name)
		
		if is_instance_valid(dialog): blockinfo.dialog_name = item_name
		else: blockinfo.dialog_name = ""
		
		refresh_start_list(item_name)
		
		save_changes(blockinfo)


func _on_StartPointPick_item_selected(item_name : String) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_NextDialog:
		var dialog = DialogsData.get_dialog(blockinfo.dialog_name)
		
		if is_instance_valid(dialog) && dialog.has_start_point(item_name):
			blockinfo.dialog_start_point = item_name
		else:
			blockinfo.dialog_start_point = ""
			
		save_changes(blockinfo)
