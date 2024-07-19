extends PanelContainer

onready var mood_name_label 	= $Settings/NameLine/Name
onready var texture_frame		= $Settings/AspectRatioContainer/TextureRect

var my_person 		= ""
var my_mood 		= ""
var my_mood_group 	= ""


func change_track_mood_group(group : String) -> void:
	my_mood_group = group
	update_ui()


func set_track_mood(person : String, mood : String) -> void:
	my_person 	= person
	my_mood 	= mood
	
	update_ui()


func update_ui() -> void:
	var person_info : EditorPersonInfo = PersonsData.get_personinfo(my_person)
	
	if is_instance_valid(person_info):
		texture_frame.texture = person_info.get_mood_texture(my_mood, my_mood_group)
		mood_name_label.text = my_mood
	else:
		texture_frame.texture = null
		mood_name_label.text = "<Error: Lost Person Data>"


func on_mood_texture_update() -> void:
	update_ui()


func on_mood_new_texture_pick(path : String) -> void:
	var person_info : EditorPersonInfo = PersonsData.get_personinfo(my_person)
	
	if !is_instance_valid(person_info): return
	
	person_info.set_mood_texture(my_mood, my_mood_group, path)
	
	update_ui()


func on_mood_delete() -> void:
	var person_info : EditorPersonInfo = PersonsData.get_personinfo(my_person)
	
	if !is_instance_valid(person_info): return
	
	person_info.erase_mood(my_mood)


func search_call(search_text : String) -> void:
	if search_text.strip_edges() == "":
		visible = true
		return
	
	visible = mood_name_label.text.begins_with(search_text)
	

func _on_ChangeBt_pressed() -> void:
	var connect_info = Ui.ConnectInfo.new(self, "on_mood_new_texture_pick")
	Ui.popup_fileshow(connect_info, "Pick new mood texture...", ["*.png, *.jpg, *.jpeg, *.bmp; Supported images"])


func _on_DeleteBt_pressed() -> void:
	var connect_info = Ui.ConnectInfo.new(self, "on_mood_delete")
	Ui.popup_confirm(connect_info, "Are you sure you want to delete this mood?")
