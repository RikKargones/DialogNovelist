extends Node


func _ready():
	get_font_dict().connect("key_deleted", self, "on_font_delete")
	setup()


func get_font_dict() -> UnicDict:
	return Project.get_project_info().fonts_data as UnicDict


func setup() -> void:
	get_font_dict().clear()
	add_defalut_fontinfo()


func get_fonts_list() -> Array:
	return get_font_dict().keys()


func on_font_delete(font_name : String) -> void:
	if font_name == Constants.defalut_key_name: add_defalut_fontinfo()
	
	
func add_defalut_fontinfo() -> void:
	if get_font_dict().has(Constants.defalut_key_name):
		if is_instance_valid(get_font_dict().get_value(Constants.defalut_key_name)): return
		else: get_font_dict().erase_key(Constants.defalut_key_name)
	
	var defalut_fontinfo = EditorFontInfo.new()
	defalut_fontinfo.set_font_type("res://UI/Fonts/FinladicaFont/Finlandica-Regular.ttf")
	defalut_fontinfo.set_font_type("res://UI/Fonts/FinladicaFont/Finlandica-Italic.ttf", EditorFontInfo.TYPE.ITALIC)
	defalut_fontinfo.set_font_type("res://UI/Fonts/FinladicaFont/Finlandica-Bold.ttf", EditorFontInfo.TYPE.BOLD)
	defalut_fontinfo.set_font_type("res://UI/Fonts/FinladicaFont/Finlandica-BoldItalic.ttf", EditorFontInfo.TYPE.ITALIC_BOLD)
	add_fontinfo(Constants.defalut_key_name, defalut_fontinfo)


func add_fontinfo(font_name : String, font_info : EditorFontInfo) -> void:
	get_font_dict().add_key(font_name, font_info)


func get_fontinfo(font_name : String) -> EditorFontInfo:
	return get_font_dict().get_value(font_name)

	
func rename_fontinfo(font_name : String, new_fontname : String) -> void:
	get_font_dict().rename_key(font_name, new_fontname)

	
func erase_fontinfo(font_name : String) -> void:
	get_font_dict().erase(font_name)
