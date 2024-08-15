extends FontInfo

class_name EditorFontInfo

func set_font_type(res_file_path : String, type = TYPE.NORMAL) -> void:
	var fontdata = ResourceLoader.load(res_file_path)
	
	if !fontdata is DynamicFontData:
		return
		
	match type:
		TYPE.NORMAL:
			normal.font_data = fontdata
			if !is_instance_valid(bold.font_data): set_font_type(res_file_path, TYPE.BOLD)
			if !is_instance_valid(italic.font_data): set_font_type(res_file_path, TYPE.ITALIC)
			if !is_instance_valid(italic_bold.font_data): set_font_type(res_file_path, TYPE.ITALIC_BOLD)
		TYPE.BOLD:
			bold.font_data = fontdata
		TYPE.ITALIC:
			italic.font_data = fontdata
		TYPE.ITALIC_BOLD:
			italic_bold.font_data = fontdata
