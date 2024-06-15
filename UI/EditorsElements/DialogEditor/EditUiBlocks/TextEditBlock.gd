extends BlockInfoEditUi

onready var person_pick 	= $Person/PersonPick
onready var font_pick		= $Person/FontPick
onready var preview_font 	= $FontShow
onready var text_edit		= $Editor

const text_locale_end_key : String = "text"
const font_locale_end_key : String = "font"


func _ready() -> void:
	person_pick.set_placeholder(Constants.none_key_name)
	font_pick.set_placeholder(Constants.defalut_key_name)
	person_pick.connect_to_unicdict(PersonsData.person_dict)
	font_pick.connect_to_unicdict(FontsData.font_dict)


func _update_ui() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is DialogDispetcher.NBI_Text:
		if is_block_fresh():
			blockinfo.person = Constants.none_key_name
			blockinfo.text_locale_key = add_locale_key(text_locale_end_key)
			blockinfo.font_locale_key = add_locale_key(font_locale_end_key, Constants.defalut_key_name)
			save_changes(blockinfo)
			
		person_pick.select_item(blockinfo.person)
		text_edit.text = LocalesData.get_locale_msg_text(Project.current_edit_locale, blockinfo.text_locale_key)
	
	update_text_edit_font()


func _get_blockinfo_script() -> GDScript:
	return DialogDispetcher.NBI_Text


func update_text_edit_font() -> void:
	text_edit.remove_font_override("font")
	
	if preview_font.pressed:
		var blockinfo = get_blockinfo_copy()
		
		if blockinfo is DialogDispetcher.NBI_Text:
			var font_name : String = LocalesData.get_locale_msg_text(Project.current_edit_locale, blockinfo.font_locale_key)
			
			text_edit.set_font(FontsData.get_fontinfo(font_name))


func _on_PersonPick_item_selected(item_name : String) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is DialogDispetcher.NBI_Text:
		if item_name == Constants.none_key_name: font_pick.set_placeholder(Constants.defalut_key_name)
		else: font_pick.set_placeholder("<Person font>")
		
		if blockinfo.person == item_name: return
		
		blockinfo.person = item_name
		
		font_pick.select_item_by_index(0)
		
		save_changes(blockinfo)


func _on_FontPick_item_selected(item_name : String) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is DialogDispetcher.NBI_Text:
		LocalesData.set_locale_msg(Project.current_edit_locale, blockinfo.font_locale_key, item_name)
		save_changes(blockinfo)
	
	update_text_edit_font()


func _on_FontShow_toggled(_button_pressed : bool) -> void:	
	update_text_edit_font()


func _on_Editor_text_changed():
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is DialogDispetcher.NBI_Text:
		LocalesData.set_locale_msg(Project.current_edit_locale, blockinfo.text_locale_key, text_edit.text)
		save_changes(blockinfo)
