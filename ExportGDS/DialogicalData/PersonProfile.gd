extends Resource

class_name PersonProfile

enum ALIGN_LIST {LEFT, CENTER, RIGHT}

export (ALIGN_LIST) var defalut_align
export 				var defalut_font_locale_key	: String
export				var person_name_locale_key 	: String
export 				var moods 					: Resource = UnicDict.new()

func get_mood_list() -> Array:
	return moods.keys()

func get_mood_info(mood_name : String) -> MoodInfo:
	return moods.get_value(mood_name)

func get_mood_texture(mood_name : String, group_name : String) -> Texture:
	var mood_info = get_mood_info(mood_name)
	
	if !is_instance_valid(mood_info): return null
	
	return mood_info.get_mood_texture(group_name)
	
func get_groups_list() -> Array:
	var groups = []
	
	for mood in moods.keys():
		var mood_info = get_mood_info(mood)
		for group_name in mood_info.get_groups_list():
			if !groups.has(group_name): groups.append(group_name)
	
	return groups
