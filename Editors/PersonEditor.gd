extends HBoxContainer

onready var person_name_id		= $EditZone/PersonLine/PersonName
onready var locale_selector 	= $EditZone/PersonLine/LocaleMenu

onready var person_main_info	= $EditZone/Settings/PersonMain/Settings/PersonData
onready var person_main_label	= $EditZone/Settings/PersonMain/Settings/ShortShow
onready var locale_name_line	= $EditZone/Settings/PersonMain/Settings/PersonData/LocaleName
onready var font_selector		= $EditZone/Settings/PersonMain/Settings/PersonData/FontMenu
onready var align_selector		= $EditZone/Settings/PersonMain/Settings/PersonData/AlignMenu

onready var mood_search_line 	= $EditZone/Settings/MoodPanel/Moods/SearchLine
onready var mood_add_bt			= $EditZone/Settings/MoodPanel/Moods/AddBts/AddMoodBt
onready var mood_mass_add_bt	= $EditZone/Settings/MoodPanel/Moods/AddBts/AddMoodsMassBt
onready var mood_list			= $EditZone/Settings/MoodPanel/Moods/Scroll/MoodList
onready var mood_panel			= $EditZone/Settings/MoodPanel

onready var person_list			= $PersonList
onready var group_selector		= $EditZone/Settings/MoodPanel/Moods/Buttons/GroupList
onready var add_group_bt		= $EditZone/Settings/MoodPanel/Moods/Buttons/AddBt
onready var del_group_bt		= $EditZone/Settings/MoodPanel/Moods/Buttons/DeleteBt

var pck_mood					= preload("res://UI/EditorsElements/Mood.tscn")

var cur_person_edit 			= ""
var cur_locale_edit				= ""
var cur_mood_group				= ""
var file_filters 				= ["*.png, *.jpg, *.jpeg, *.bmp; Supported images"]

signal cur_mood_group_changed(mood_group)


func _ready():
	person_list.connect_to_unicdict(PersonsData.person_dict)
	locale_selector.connect_to_unicdict(LocalesData.locale_dict)
	font_selector.connect_to_unicdict(FontsData.font_dict)
	align_selector.update_items(DialogDispetcher.get_align_names_list())
	person_main_label.visible = false
	

func get_cur_personinfo() -> EditorPersonInfo:
	return PersonsData.get_personinfo(cur_person_edit)

	
func load_person_data(person_name : String) -> void:
	var person_info : EditorPersonInfo = PersonsData.get_personinfo(person_name)
	
	if is_instance_valid(person_info):
		cur_person_edit 	= person_name
		mood_panel.visible 	= true
		
		font_selector.select_item(person_info.get_person_localased_font(cur_locale_edit))
		align_selector.select_item(DialogDispetcher.get_align_name(person_info.defalut_align))
		group_selector.connect_to_unicdict(person_info.get_groups_unicdict())
		
		load_mood_list()
	else:
		cur_person_edit 	= ""
		mood_panel.visible 	= false
		
		font_selector.select_item(Constants.defalut_key_name)
		align_selector.select_item_by_index(0)
		group_selector.disconect_from_unicdict()
		group_selector.update_items(PoolStringArray([]))
		
		clear_mood_list()


func update_ui() -> void:
	var person_info : EditorPersonInfo = get_cur_personinfo()
	var person_in_list = is_instance_valid(person_info)
	
	mood_add_bt.disabled 		= !person_in_list
	mood_mass_add_bt.disabled	= !person_in_list
	font_selector.disabled 		= !person_in_list
	align_selector.disabled 	= !person_in_list
	add_group_bt.disabled		= !person_in_list
	del_group_bt.disabled		= !person_in_list
	locale_name_line.editable 	= person_in_list
	
	if person_in_list:
		person_name_id.text = cur_person_edit
		var pers_name = person_info.get_person_localased_name(cur_locale_edit)
		var font_name = person_info.get_person_localased_font(cur_locale_edit)
		var align_name = DialogDispetcher.get_align_name(person_info.defalut_align)
		
		var old_pos = locale_name_line.get_cursor_position()
		locale_name_line.text = pers_name
		locale_name_line.set_cursor_position(old_pos)
		person_main_label.text = "Localazed name: " + pers_name + " - Font: " + font_name + " - Align: " + align_name
	else:
		person_name_id.text = "Create/pick person!"
		locale_name_line.text = ""
		person_main_label.text = "No person info!"


func add_group(group_name : String) -> void:
	var person_info : EditorPersonInfo = get_cur_personinfo()
	
	if !is_instance_valid(person_info): return
	
	person_info.add_mood_group(group_name)
	
	group_selector.select_item(group_name)


func set_group(mood_group : String) -> void:
	cur_mood_group = mood_group
	
	del_group_bt.disabled = (cur_mood_group == Constants.defalut_key_name)
	
	emit_signal("cur_mood_group_changed", cur_mood_group)
	
	
func erase_group() -> void:
	var person_info : EditorPersonInfo = get_cur_personinfo()
	
	if !is_instance_valid(person_info): return
	
	person_info.erase_group(cur_mood_group)


func clear_mood_list() -> void:
	for child in mood_list.get_children():
		if child.is_in_group("MoodUI"):
			child.queue_free()


func load_mood_list() -> void:
	clear_mood_list()
	
	var person_info : EditorPersonInfo = get_cur_personinfo()
	
	if !is_instance_valid(person_info): return
	
	for mood_name in person_info.get_mood_list():
		if mood_name != Constants.none_key_name:
			var new_mood_ui = pck_mood.instance()
	
			mood_list.add_child(new_mood_ui)
			new_mood_ui.set_track_mood(cur_person_edit, mood_name)
			new_mood_ui.change_track_mood_group(cur_mood_group)
			mood_search_line.connect("search_entered", new_mood_ui, "search_call")
			connect("cur_mood_group_changed", new_mood_ui, "change_track_mood_group")

	
func on_mood_name_confirm(mood_name : String) -> void:
	var popup = FilePopup.new("Chose image for mood texture", file_filters)
	Ui.add_popup(popup, "file_selected", self, "call_mood_add", [mood_name])


func call_mood_add(path : String, mood_name : String, call_load = true) -> void:
	var person_info : EditorPersonInfo = get_cur_personinfo()
	
	if !is_instance_valid(person_info):	return
	
	person_info.add_mood(mood_name)
	person_info.set_mood_texture(mood_name, cur_mood_group, path)
	
	if call_load: load_mood_list()


func call_mass_mood_add(paths : PoolStringArray) -> void:
	var person_info : EditorPersonInfo = get_cur_personinfo()
	
	if !is_instance_valid(person_info): return
	
	for path in paths:
		var file_name = path.get_file().trim_suffix("." + path.get_extension())
		var mood_name = FilesData.make_string_nambered(file_name, person_info.get_mood_list())
		
		call_mood_add(path, mood_name, false)
	
	load_mood_list()


func call_person_add(new_person : String) -> void:
	PersonsData.add_person(new_person)


func _on_AddMoodBt_pressed() -> void:
	var person_info : EditorPersonInfo = get_cur_personinfo()
	if !is_instance_valid(person_info): return
	
	var popup = NameDialog.new("Name mood for person", person_info.get_mood_list())
	Ui.add_popup(popup, "name_confurmed", self, "on_mood_name_confirm")


func _on_AddMoodsMassBt_pressed():
	var person_info : EditorPersonInfo = get_cur_personinfo()
	if !is_instance_valid(person_info): return
	
	var popup = FilePopup.new("Pick several files for mood textures", file_filters, FileDialog.MODE_OPEN_FILES)
	Ui.add_popup(popup, "files_selected", self, "call_mass_mood_add")


func _on_PersonList_add_item_request() -> void:
	var popup = NameDialog.new("Make new person", PersonsData.get_persons_list(), "New person ID:", true)
	Ui.add_popup(popup, "name_confurmed", self, "call_person_add")


func on_person_erase_confirm() -> void:
	PersonsData.erase_person(cur_person_edit)
	if person_list.get_selected_item() == "":
		load_person_data("")


func _on_PersonList_delete_item_request(_item_name : String) -> void:
	var popup = ConfirmPopup.new("Are you sure you want to delete this person?")
	Ui.add_popup(popup, "confirmed", self, "on_person_erase_confirm")


func _on_PersonList_item_selected(item_name : String) -> void:
	load_person_data(item_name)


func on_person_rename_confirm(new_name : String) -> void:
	PersonsData.rename_person(cur_person_edit, new_name)
	

func _on_PersonList_rename_item_request(item_name : String) -> void:
	var popup = NameDialog.new("Rename person ID", PersonsData.get_persons_list(), "New person ID:", true)
	Ui.add_popup(popup, "name_confurmed", self, "on_person_rename_confirm")


func _on_LocaleName_text_changed(new_text : String) -> void:
	var person_info : EditorPersonInfo = get_cur_personinfo()
	
	if is_instance_valid(person_info):
		person_info.set_person_localsed_name(cur_locale_edit, new_text)
	
	
func _on_FontMenu_item_selected(font_name : String) -> void:
	var person_info : EditorPersonInfo = get_cur_personinfo()
	
	if is_instance_valid(person_info):
		person_info.set_person_localsed_font(cur_locale_edit, font_name)
		
	update_ui()


func _on_AlignMenu_item_selected(item_name : String) -> void:
	var align_num = EditLibraly.get_align_index(item_name)
	var person_info : EditorPersonInfo = get_cur_personinfo()

	if is_instance_valid(person_info) && align_num != -1:
		person_info.defalut_align = align_num
	
	update_ui()


func _on_LocaleMenu_item_selected(item_name : String) -> void:
	cur_locale_edit = item_name
	update_ui()


func _on_DeleteBt_pressed():
	var confirm = ConfirmPopup.new("Are you sure you want to delete this mood group?")
	Ui.add_popup(confirm, "confirmed", self, "erase_group")


func _on_AddBt_pressed():
	var person_info : EditorPersonInfo = get_cur_personinfo()

	if !is_instance_valid(person_info): return
	
	var name_popup = NameDialog.new("Name new mood group", person_info.get_groups_list(), "", true)
	Ui.add_popup(name_popup, "name_confurmed", self, "add_group")
	

func _on_GroupList_item_selected(item_name : String) -> void:
	set_group(item_name)
