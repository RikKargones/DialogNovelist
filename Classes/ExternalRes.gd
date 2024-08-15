extends Resource

class_name ExternalRes

export var extention			: String
export var md5 					: String
export var file_data			: PoolByteArray
export var ref_count 			: int 				= 1

signal ref_count_zero(file_path)

#It's a general file data resource handler

#It stores a file data what cannot be exported from engine without keeping dependency
#for external file (like ".ttf" and other font files for DynamicFontData).

#It still needs to be saved as original file before loading data what depends on it (like DynamicFont),
#but at least I can store files then needed without depending on file from disc.

func _init(file_path : String) -> void:
	var file = File.new()
	
	if file.file_exists(file_path):
		var open_err = file.open(file_path, File.READ)
		
		if open_err != OK:
			sub_ref_count()
			return
		
		file_data = file.get_buffer(file.get_len())
		
		file.close()
		
		md5 = file.get_md5(file_path)
		extention = file_path.get_extension()
	else:
		sub_ref_count()


func add_ref_count() -> void:
	ref_count += 1
	

func sub_ref_count() -> void:
	ref_count -= 1
	if ref_count < 1:
		emit_signal("ref_count_zero")
	

func is_other_md5_same(other_file_full_path : String) -> bool:
	var file = File.new()
	
	return file.file_exists(other_file_full_path) && md5 == file.get_md5(other_file_full_path)


func save_res_as(path_to_dir : String, file_name : String) -> int:
	var file 				= File.new()
	var full_file_path 		= path_to_dir.plus_file(file_name) + "." + extention
	var file_err 			= file.open(full_file_path, File.WRITE)
	
	if file_err != OK: return file_err
	
	file.store_buffer(file_data)
	file.close()
	
	return OK
