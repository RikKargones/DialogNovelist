extends Node

var font_dict : DialogDispetcher.UnicDict = DialogDispetcher.UnicDict.new()

class EditorFontInfo extends DialogDispetcher.FontInfo:
	func _notification(what):
		if what == NOTIFICATION_PREDELETE:
			FilesData.remove_external_file(normal_fontdata_path.get_file())
			FilesData.remove_external_file(bold_fontdata_path.get_file())
			FilesData.remove_external_file(italic_fontdata_path.get_file())
			FilesData.remove_external_file(italic_bold_fontdata_path.get_file())
	
	func set_font_type(res_file_path : String, type = TYPE.NORMAL) -> void:
		var file_name = FilesData.add_external_file(res_file_path, "Fonts")
		
		if file_name == "": return
		
		var fontdata_full_path = FilesData.get_external_file_full_path(file_name)
		var fontdata = ResourceLoader.load(fontdata_full_path)
		
		if !fontdata is DynamicFontData:
			FilesData.remove_external_file(file_name)
			return
			
		match type:
			TYPE.NORMAL:
				normal.font_data = fontdata
				normal_fontdata_path = fontdata_full_path
				if !is_instance_valid(bold.font_data): set_font_type(res_file_path, TYPE.BOLD)
				if !is_instance_valid(italic.font_data): set_font_type(res_file_path, TYPE.ITALIC)
				if !is_instance_valid(italic_bold.font_data): set_font_type(res_file_path, TYPE.ITALIC_BOLD)
			TYPE.BOLD:
				bold.font_data = fontdata
				bold_fontdata_path = fontdata_full_path
			TYPE.ITALIC:
				italic.font_data = fontdata
				italic_fontdata_path = fontdata_full_path
			TYPE.ITALIC_BOLD:
				italic_bold.font_data = fontdata
				italic_bold_fontdata_path = fontdata_full_path
			_:
				FilesData.remove_external_file(file_name)
				return


func _ready():
	font_dict.connect("key_deleted", self, "on_font_delete")
	setup()
	

func setup() -> void:
	font_dict.clear()
	add_defalut_fontinfo()


func get_fonts_list() -> Array:
	return font_dict.keys()


func on_font_delete(font_name : String) -> void:
	if font_name == Constants.defalut_key_name: add_defalut_fontinfo()
	
	
func add_defalut_fontinfo() -> void:
	if font_dict.has(Constants.defalut_key_name):
		if is_instance_valid(font_dict.get_value(Constants.defalut_key_name)): return
		else: font_dict.erase_key(Constants.defalut_key_name)
	
	var defalut_fontinfo = EditorFontInfo.new()
	defalut_fontinfo.set_font_type("res://UI/Fonts/FinladicaFont/Finlandica-Regular.ttf")
	defalut_fontinfo.set_font_type("res://UI/Fonts/FinladicaFont/Finlandica-Italic.ttf", EditorFontInfo.TYPE.ITALIC)
	defalut_fontinfo.set_font_type("res://UI/Fonts/FinladicaFont/Finlandica-Bold.ttf", EditorFontInfo.TYPE.BOLD)
	defalut_fontinfo.set_font_type("res://UI/Fonts/FinladicaFont/Finlandica-BoldItalic.ttf", EditorFontInfo.TYPE.ITALIC_BOLD)
	add_fontinfo(Constants.defalut_key_name, defalut_fontinfo)


func add_fontinfo(font_name : String, font_info : EditorFontInfo) -> void:
	font_dict.add_key(font_name, font_info)


func get_fontinfo(font_name : String) -> EditorFontInfo:
	return font_dict.get_value(font_name)

	
func rename_fontinfo(font_name : String, new_fontname : String) -> void:
	font_dict.rename_key(font_name, new_fontname)

	
func erase_fontinfo(font_name : String) -> void:
	font_dict.erase(font_name)
