extends Resource

class_name MoodInfo

export var textures : Resource = UnicDict.new()

func has_group(group_name : String) -> bool:
	return group_name in get_groups_list()

func get_groups_list() -> Array:
	return textures.keys()

func get_mood_texture(group_name : String) -> Texture:
	var group_info = textures.get_value(group_name)
	
	if !group_info is Array: return null
	
	if group_name in textures.keys(): return group_info[0]
	return null

func get_mood_file_path(group_name : String) -> String:
	var group_info = textures.get_value(group_name)
	
	if !group_info is Array: return ""
	
	if group_name in textures.keys(): return group_info[1]
	return ""
