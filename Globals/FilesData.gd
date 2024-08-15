extends Node


func get_external_files_dict() -> UnicDict:
	if !is_instance_valid(Project):
		return UnicDict.new()
	return Project.project_info.external_files_data as UnicDict
	
	
func load_external_file(path : String) -> String:
	var files_dict 	: UnicDict 	= get_external_files_dict()
	var file 		: File		= File.new()
	
	if !file.file_exists(path): return ""
	
	for res_key in files_dict.keys():
		var res : ExternalRes = files_dict.get_value(res_key)
		if !is_instance_valid(res) || !res.is_other_md5_same(path): continue
		res.add_ref_count()
		return res_key
	
	var ext_res = ExternalRes.new(path)
	
	if ext_res.ref_count == 0: return ""
	
	var file_name = EditLibraly.make_string_nambered(path.get_file().trim_suffix("." + path.get_extension()), files_dict.keys())
	
	files_dict.add_key(file_name, ext_res)
	ext_res.connect("ref_count_zero", self, "sub_ref_reached_zero", [file_name])
	
	return file_name


func delete_external_file(file_name : String) -> void:
	var res : ExternalRes = get_external_files_dict().get_value(file_name)
	
	if !is_instance_valid(res): return
	
	res.sub_ref_count()
	

func sub_ref_reached_zero(file_name : String) -> void:
	get_external_files_dict().erase(file_name)
