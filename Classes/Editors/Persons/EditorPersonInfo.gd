extends PersonProfile

class_name EditorPersonInfo

signal group_list_update(groups_list)

func _notification(what) -> void:
	if what == NOTIFICATION_PREDELETE:
		LocalesData.erase_locales_msg(person_name_locale_key)
		LocalesData.erase_locales_msg(defalut_font_locale_key)


func _init(person_name : String) -> void:
	person_name_locale_key = "DD_PERSON_NAME_" + person_name.to_upper()
	defalut_font_locale_key = "DD_PERSON_FONT_" + person_name.to_upper()
	LocalesData.add_locales_msg(person_name_locale_key, person_name.replace("_", " "))
	LocalesData.add_locales_msg(defalut_font_locale_key, Constants.defalut_key_name)
	add_mood(Constants.none_key_name)
	

func get_person_localased_name(locale_long : String) -> String:
	return LocalesData.get_locale_msg_text(locale_long, person_name_locale_key)
	
	
func get_person_localased_font(locale_long : String) -> String:
	return LocalesData.get_locale_msg_text(locale_long, defalut_font_locale_key)


func set_person_localsed_name(locale_long : String, new_name : String) -> void:
	LocalesData.set_locale_msg(locale_long, person_name_locale_key, new_name)
	
	
func set_person_localsed_font(locale_long : String, new_font_name : String) -> void:
	LocalesData.set_locale_msg(locale_long, defalut_font_locale_key, new_font_name)


func add_mood_group(mood_group : String) -> void:
	var list = get_groups_list()
	
	if mood_group in list: return
	
	list.append(mood_group)
	
	emit_signal("group_list_update", list)
	

func add_mood(mood_name : String) -> void:
	if mood_name in get_mood_list(): return
	
	var mood_info = EditorMoodInfo.new()
	
	connect("group_list_update", mood_info, "update_groups")
	mood_info.update_groups(get_groups_list())
	
	moods.add_key(mood_name, mood_info)
	

func rename_mood(old_mood_name : String, new_mood_name : String) -> void:
	moods.rename_key(old_mood_name, new_mood_name)


func set_mood_texture(mood : String, mood_group : String, path_to : String) -> void:
	if !mood in get_mood_list(): return
	
	var mood_info : EditorMoodInfo = get_mood_info(mood)
	
	mood_info.set_texture(mood_group, path_to)


func get_groups_unicdict() -> UnicDict:
	var none_info = get_mood_info(Constants.none_key_name)
	
	if is_instance_valid(none_info): return none_info.textures
	
	return UnicDict.new()
	
	
func erase_group(mood_group : String) -> void:		
	var list = get_groups_list()
	
	if !mood_group in list: return
	
	list.erase(mood_group)
	
	emit_signal("group_list_update", list)
	
		
func erase_mood(mood_name : String) -> void:
	if !mood_name in get_mood_list(): return
	
	moods.erase(mood_name)
