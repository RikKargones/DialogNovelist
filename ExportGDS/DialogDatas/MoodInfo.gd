extends Resource

class_name MoodInfo

export var textures : Resource = UnicDict.new()

func has_group(group_name : String) -> bool:
	return group_name in get_groups_list()

func get_groups_list() -> Array:
	return textures.keys()

func get_mood_texture(group_name : String) -> Texture:
	return textures.get_value(group_name)
