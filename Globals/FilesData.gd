extends Node

var cur_project_folder		= "user://CurProject"
var external_files  		: Dictionary

class ExternalRes:
	export var file_path_in_project : String
	export var md5 					: String
	export var ref_count 			: int 		= 1
	
	signal ref_count_zero(file_path)
	
	func _init(file_path : String, project_path : String) -> void:
		var file = File.new()
		
		if file.file_exists(file_path):
			file_path_in_project = project_path
			md5 = file.get_md5(file_path)
		else:
			sub_ref_count()
	
	func add_ref_count() -> void:
		ref_count += 1
		
	func sub_ref_count() -> void:
		ref_count -= 1
		if ref_count < 1:
			emit_signal("ref_count_zero", file_path_in_project)
	
	func is_file_exist(project_folder_path : String) -> bool:
		var full_path = project_folder_path + "/" + file_path_in_project
		var file = File.new()
		
		return file.file_exists(full_path)
		
	func is_md5_same(project_folder_path : String) -> bool:
		var full_path = project_folder_path + "/" + file_path_in_project
		var file = File.new()
		
		return file.file_exists(full_path) && md5 == file.get_md5(full_path)
		
	func is_other_md5_same(other_file_full_path : String) -> bool:
		var file = File.new()
		
		return file.file_exists(other_file_full_path) && md5 == file.get_md5(other_file_full_path)


func has_external_file(file_name : String) -> bool:
	return file_name in external_files.keys()


func make_string_nambered(st : String, keys : PoolStringArray) -> String:
	var final_name 		= st
	var counter			= 1
	
	while final_name in keys:
		final_name = st + "_" + str(counter)
		counter += 1
	
	return final_name


func add_external_file(path_to_file : String, project_directory : String) -> String:
	var dir_manager 		= Directory.new()
	var file_name 			= path_to_file.get_file()
	
	if !dir_manager.file_exists(path_to_file):
		Ui.popup_error("Can't find file on path: " + path_to_file)
		return ""
	
	for ext_file in external_files.keys():
		var res : ExternalRes = external_files[ext_file]		
		if res.is_file_exist(cur_project_folder):
			if res.is_other_md5_same(path_to_file):
				res.add_ref_count()
				return ext_file
		else:
			external_files.erase(ext_file)
	
	file_name = make_string_nambered(file_name, external_files.keys())
	
	dir_manager.make_dir_recursive(cur_project_folder + "/" + project_directory)
	
	var full_end_path = cur_project_folder + "/" + project_directory + "/" + file_name
	
	if dir_manager.file_exists(full_end_path):
		dir_manager.remove(full_end_path)
	
	if dir_manager.copy(path_to_file, full_end_path) == OK:
		var new_res = ExternalRes.new(full_end_path, project_directory + "/" + file_name)
		new_res.connect("ref_count_zero", self, "on_file_zero_ref_count")
		
		if new_res.ref_count > 0:
			external_files[file_name] = new_res
			return file_name
		else:
			external_files.erase(file_name)
	else:
		Ui.popup_error("Can't copy file from original path. Maybe program doesn't have acess?..")
		
	return ""

	
func remove_external_file(file_name : String) -> void:
	if !has_external_file(file_name): return
	
	var res : ExternalRes = external_files[file_name]
	
	res.sub_ref_count()


func get_external_file_full_path(file_name : String) -> String:
	if has_external_file(file_name): return cur_project_folder + "/" + external_files[file_name].file_path_in_project
	return ""


func get_external_file_project_path(file_name : String) -> String:
	if has_external_file(file_name): return external_files[file_name].file_path_in_project
	return ""


func on_file_zero_ref_count(file_path_in_project : String) -> void:
	external_files.erase(file_path_in_project.get_file())
	
	var dir_manager = Directory.new()
	
	if dir_manager.file_exists(cur_project_folder + "/" + file_path_in_project):
		dir_manager.remove(cur_project_folder + "/" + file_path_in_project)
		
