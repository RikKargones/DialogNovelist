extends Node

class NBI_Start extends NodeBlockInfo:
	var point_name : String


enum PATH_RESULTS {
	DIR_NOT_EXIST,
	FOLDER_EMPTY,
	FOLDER_HAS_FILES,
	FILE_EXIST,
	NOT_A_PATH,
	CANT_OPEN_DIR,
	}

var cur_project_folder		= "user://CurProject"

func checkout_path(path : String, is_folder : bool = false) -> int:
	var dir 			: Directory 	= Directory.new()
	var file 			: File			= File.new()
	var path_to_dir 	: String 		= path
	
	if !is_folder: path_to_dir = path.get_base_dir()
	
	if !path.is_abs_path() && !path.is_rel_path(): 	return PATH_RESULTS.NOT_A_PATH
	elif file.file_exists(path) && !is_folder:		return PATH_RESULTS.FILE_EXIST
	elif !dir.dir_exists(path): 					return PATH_RESULTS.DIR_NOT_EXIST
	
	var open_error : int = dir.open(path_to_dir)
	
	if open_error == OK:
		dir.list_dir_begin(true)
		var current_file = dir.get_next()
		dir.list_dir_end()
		
		if current_file == "":
			return PATH_RESULTS.FOLDER_EMPTY
		
		return PATH_RESULTS.FOLDER_HAS_FILES
	
	return PATH_RESULTS.CANT_OPEN_DIR


func make_string_nambered(st : String, keys : PoolStringArray) -> String:
	var final_name 		= st
	var counter			= 1
	
	while final_name in keys:
		final_name = st + "_" + str(counter)
		counter += 1
	
	return final_name
		

func erase_folder_recursive(dir_path : String) -> void:
	var dir : Directory = Directory.new()
	
	if dir.open(dir_path) != OK:
		Ui.popup_error("Can't recursivly erase folder.", "FILES_DATA")
		return
		
	dir.list_dir_begin(true)
	
	var cur_file = dir.get_next()
	
	while cur_file != "":
		var full_file_path = dir_path.trim_suffix("/") + "/" + cur_file
		if dir.current_is_dir(): erase_folder_recursive(full_file_path)
		else: dir.remove(full_file_path)
		cur_file = dir.get_next()
	
	dir.remove(dir_path)


func disconect_incoming_signals(signals : PoolStringArray, object : Object) -> void:
	if !is_instance_valid(object): return
	
	for connection in object.get_incoming_connections():
		if connection["signal_name"] in signals:
			connection["source"].disconnect(connection["signal_name"], object, connection["method_name"])


func copy_object_propertys(object_one : Object, object_two : Object) -> void:
	UnicDict.copy_object_propertys(object_one, object_two)


func duplacate_scripted_object(object : Object):
	if !is_instance_valid(object): return null
	
	var object_script = object.get_script()
	
	if !is_instance_valid(object_script) || !object_script is GDScript: return null
	
	var object_copy = object_script.new()
	
	copy_object_propertys(object, object_copy)
	
	return object_copy


func get_align_name(align_id : int) -> String:
	if align_id < 0 && PersonProfile.ALIGN_LIST.keys().size() <= align_id:
		return PersonProfile.ALIGN_LIST.keys()[PersonProfile.ALIGN_LIST.CENTER]
	return PersonProfile.ALIGN_LIST.keys()[align_id]
		

func get_align_index(align_text : String) -> int:
	var id = PersonProfile.ALIGN_LIST.keys().find(align_text)
	
	if id == -1: return -1
	
	return PersonProfile.ALIGN_LIST.values()[id]
	

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
