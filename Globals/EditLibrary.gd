extends Node


func disconect_incoming_signals(signals : PoolStringArray, object : Object) -> void:
	if !is_instance_valid(object): return
	
	for connection in object.get_incoming_connections():
		if connection["signal_name"] in signals:
			connection["source"].disconnect(connection["signal_name"], object, connection["method_name"])


func copy_object_propertys(object_one : Object, object_two : Object) -> void:
	if !is_instance_valid(object_one) || !is_instance_valid(object_two): return
	
	var is_in_script_vars = false
	var var_list = []
	
	for property in object_one.get_property_list():
		if is_in_script_vars:
			var_list.append([property["name"], property["type"]])
		else:
			is_in_script_vars = (property["name"] == "Script Variables")
	
	for property in object_two.get_property_list():
		if [property["name"], property["type"]] in var_list:
			object_two.set(property["name"], object_one.get(property["name"]))


func duplacate_scripted_object(object : Object):
	if !is_instance_valid(object): return null
	
	var object_script = object.get_script()
	
	if !is_instance_valid(object_script) || !object_script is GDScript: return null
	
	var object_copy = object_script.new()
	
	copy_object_propertys(object, object_copy)
	
	return object_copy


func get_align_name(align_id : int) -> String:
	if align_id < 0 && DialogDispetcher.PersonProfile.ALIGN_LIST.keys().size() <= align_id:
		return DialogDispetcher.PersonProfile.ALIGN_LIST.keys()[DialogDispetcher.PersonProfile.ALIGN_LIST.CENTER]
	return DialogDispetcher.PersonProfile.ALIGN_LIST.keys()[align_id]
		

func get_align_index(align_text : String) -> int:
	var id = DialogDispetcher.PersonProfile.ALIGN_LIST.keys().find(align_text)
	
	if id == -1: return -1
	
	return DialogDispetcher.PersonProfile.ALIGN_LIST.values()[id]
	

func is_dialog_editor_ui_path_valid(path : DialogEditorUiPathBase, error_trower_name = "") -> bool:
	if !is_instance_valid(path):
		if error_trower_name != "": Ui.popup_error("DialogEditorUiPath not initalased or null!", error_trower_name)
		return false
	
	if path.base_key.strip_edges() == "":
		if error_trower_name != "": Ui.popup_error("DialogEditorPath should be saved with non-empty base key.", error_trower_name)
		return false
	
	var edit_ui_scene = path.edit_ui_scene
	var graph_node_ui_scene = path.graph_node_ui_scene
	
	if !is_instance_valid(edit_ui_scene) || !is_instance_valid(graph_node_ui_scene):
		if error_trower_name != "": Ui.popup_error("Not all scenes in DialogEditorUiPath seted!", error_trower_name)
		return false
	
	var edit_inst = edit_ui_scene.instance()
	var show_inst = graph_node_ui_scene.instance()
	
	if !edit_inst is BlockInfoEditUi || !show_inst is BlockInfoGraphUi:
		if error_trower_name != "": Ui.popup_error("One or both scenes in DialogEditorUiPath not extends correct clases (BlockInfoEditUi and BlockInfoGraphUi)!", error_trower_name)
		return false
	
	if !is_instance_valid(edit_inst._get_blockinfo_script()) || !is_instance_valid(show_inst._get_blockinfo_script()):
		if error_trower_name != "": Ui.popup_error("BlockInfo clases in scenes from DialogEditorUiPath not seted! Rewrite \"_get_blockinfo_script()\" function in both scenes!", error_trower_name)
		return false
	
	if edit_inst._get_blockinfo_script() != show_inst._get_blockinfo_script():
		if error_trower_name != "": Ui.popup_error("Scenes in DialogEditorUiPath works with different BlockInfo clases!", error_trower_name)
		return false
	
	return true


func get_script_from_dialog_editor_ui_path(path : DialogEditorUiPathBase, error_trower_name = "") -> GDScript:
	if !is_dialog_editor_ui_path_valid(path, error_trower_name): return null
	
	return path.edit_ui_scene.instance()._get_blockinfo_script()
