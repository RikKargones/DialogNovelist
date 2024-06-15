extends NodeInfoMsg

class_name MoodBlockFetchMsg

export var person 	: String
export var mood 	: String
export var group 	: String


func set_mood(mood_name : String) -> void:
	if mood == "" && mood_name != Constants.keep_key_name:
		mood = mood_name
		check_completion()
	

func set_group(group_name : String) -> void:
	if group == "" && group_name != Constants.keep_key_name:
		group = group_name
		check_completion()

	
func check_completion() -> void:
	if mood != "" && group != "": disable_pass()
