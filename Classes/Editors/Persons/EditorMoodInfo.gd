extends MoodInfo

class_name EditorMoodInfo	
	
func _init() -> void:
	add_group(Constants.defalut_key_name)


func add_group(group_name : String) -> void:
	if textures.has(group_name): return 
	textures.add_key(group_name, null)


func update_groups(groups_list : Array) -> void:
	for group in textures.keys():
		if !group in groups_list: erase_group(group)
		if group in groups_list: groups_list.erase(group)
		
	for group in groups_list:
		add_group(group)


func erase_group(group_name : String) -> void:
	if !group_name in textures.keys() || group_name == Constants.defalut_key_name: return 
	textures.erase(group_name)
	
	
func set_texture(group_name : String, file_path : String) -> void:
	if !group_name in textures.keys(): return
	
	var image	= Image.new()
	var texture = ImageTexture.new()
	
	if image.load(file_path) == OK:
		texture.create_from_image(image)
		textures.set_key(group_name, texture)
