extends MoodBlockFetchMsg

class_name MoodBlockFetchRequest	
	
func generate_respond(respond_name : String, respond_mood : String, respond_group : String) -> MoodBlockFetchRespond:
	var respond = MoodBlockFetchRespond.new()
	
	add_respond(respond_name)
	
	set_mood(respond_mood)
	set_group(respond_group)
	
	respond.origin = origin
	respond.person = person		
	respond.mood = mood
	respond.group = group
	respond.respond_list = respond_list
	
	return respond
