extends BlockInfoGraphUi

onready	var person_label 	= $Settings/NameLabel
onready var font_label		= $Settings/FontLabel
onready var text_label		= $TextPanel/TextLabel

func _update_ui() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_Text:
		var personinfo = PersonsData.get_personinfo(blockinfo.person)
		
		person_label.text = blockinfo.person
		
		if is_instance_valid(personinfo):
			var localased_name = personinfo.get_person_localased_name(Project.current_edit_locale)
			
			if blockinfo.person != localased_name: person_label.text += " (Localed as: " + localased_name + ")"
			
		font_label.text = LocalesData.get_locale_msg_text(Project.current_edit_locale, blockinfo.font_locale_key)
		
		var fontinfo = FontsData.get_fontinfo(font_label.text)
		
		text_label.remove_font_override("normal_font")
		text_label.remove_font_override("bold_font")
		text_label.remove_font_override("italics_font")
		text_label.remove_font_override("bold_italics_font")
		
		if is_instance_valid(fontinfo):
			text_label.add_font_override("normal_font", fontinfo.normal)
			text_label.add_font_override("bold_font", fontinfo.bold)
			text_label.add_font_override("italics_font", fontinfo.italic)
			text_label.add_font_override("bold_italics_font", fontinfo.italic_bold)
		
		text_label.bbcode_text 		= LocalesData.get_locale_msg_text(Project.current_edit_locale, blockinfo.text_locale_key)
		
		hint_tooltip = "PERSON: " + blockinfo.person + "\n"
		hint_tooltip += "FONT: " + font_label.text + "\n"
		hint_tooltip += "TEXT: " + text_label.text


func _get_blockinfo_script() -> GDScript:
	return NBI_Text
