tool
extends ResourceFormatSaver

class_name ProjectFomatSaver


func get_recognized_extensions(resource : Resource) -> PoolStringArray:
	return PoolStringArray(["dnpd"])
	
	
func recognize(resource : Resource) -> bool:
	return resource is ProjectData
	

func save(path : String, resource : Resource, flags : int) -> int:
	if !resource is ProjectData: 		return ERR_INVALID_DATA
	if path.get_extension() != "dnpd": 	return ERR_FILE_BAD_PATH
	
	var file 		: File 	= File.new()
	var open_err 	: int 	= file.open_compressed(path, File.WRITE, File.COMPRESSION_GZIP)
	
	if open_err != OK: return open_err
	
	var work_dict 		: UnicDict 		= resource.external_files_data
	var ext_res_dict 	: Dictionary 	= {}
	
	for ext_res_name in work_dict.keys():
		var ext_res : ExternalRes = work_dict.get_value(ext_res_name)
		if is_instance_valid(ext_res): ext_res_dict[ext_res_name] = inst2dict(ext_res)
	
	work_dict 						= resource.dialogs_data
	var dialogs_dict : Dictionary 	= {}
	
	for dialog_name in work_dict:
		var dialog_data : EditorDialogInfo = work_dict.get_value(dialog_name)
		if is_instance_valid(dialog_data): dialogs_dict[dialog_name] = dialog_data.to_dict()
		
	work_dict						 = resource.persons_data
	var persons_dict : Dictionary 	= {}
	
	file.close()
	
	return OK

