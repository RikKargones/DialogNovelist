extends DialogDispetcher.MoodInfo

class_name EditorMoodInfo

func _notification(what) -> void:
	if what == NOTIFICATION_PREDELETE && is_instance_valid(self): 
		for group_name in textures.keys():
			FilesData.remove_external_file(get_mood_file_path(group_name).get_file())
	
	
func _init() -> void:
	resource_local_to_scene = true
	add_group(Constants.defalut_key_name)


func add_group(group_name : String) -> void:
	if textures.has(group_name): return 
	textures.add_key(group_name, [null, ""])


func update_groups(groups_list : Array) -> void:
	for group in textures.keys():
		if !group in groups_list: erase_group(group)
		if group in groups_list: groups_list.erase(group)
		
	for group in groups_list:
		add_group(group)


func erase_group(group_name : String) -> void:
	if !group_name in textures.keys() || group_name == Constants.defalut_key_name: return 
	FilesData.remove_external_file(get_mood_file_path(group_name).get_file())
	textures.erase(group_name)
	
	
func set_texture(group_name : String, path_to : String) -> void:
	if !group_name in textures.keys(): return
	
	var file = FilesData.add_external_file(path_to, "Textures")
	
	if file == "": return
	
	var image	= Image.new()
	var texture = ImageTexture.new()
	
	if image.load(FilesData.get_external_file_full_path(file)) == OK:
		FilesData.remove_external_file(get_mood_file_path(group_name).get_file())
		texture.create_from_image(image)
	else:
		FilesData.remove_external_file(file)
		return
	
	textures.set_key(group_name, [texture, FilesData.get_external_file_full_path(file)])
