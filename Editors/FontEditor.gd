extends HBoxContainer

onready var font_list			= $FontList

onready var font_normal_bt		= $SettingsBackground/Settings/Scroll/FontBlocks/FilesBlock/Files/NormalFontChange
onready var font_italic_bt 		= $SettingsBackground/Settings/Scroll/FontBlocks/FilesBlock/Files/ItalicFontChange
onready var font_bold_bt		= $SettingsBackground/Settings/Scroll/FontBlocks/FilesBlock/Files/BoldFontChange
onready var font_bold_italic_bt	= $SettingsBackground/Settings/Scroll/FontBlocks/FilesBlock/Files/ItalicBoldFontChange

onready var font_size_box		= $SettingsBackground/Settings/Scroll/FontBlocks/FontSettingsBlock/FontMetrics/FontSize
onready var outline_size_box	= $SettingsBackground/Settings/Scroll/FontBlocks/FontSettingsBlock/FontMetrics/OutlineSize
onready var outline_color_pic	= $SettingsBackground/Settings/Scroll/FontBlocks/FontSettingsBlock/FontMetrics/OutlineColor
onready var minmaps_check		= $SettingsBackground/Settings/Scroll/FontBlocks/FontSettingsBlock/FontMetrics/MinimapsCheck
onready var filter_check		= $SettingsBackground/Settings/Scroll/FontBlocks/FontSettingsBlock/FontMetrics/FilterCheck

onready var top_spacing			= $SettingsBackground/Settings/Scroll/FontBlocks/ExtraSpacingBlock/ExtraSpacing/Top
onready var bottom_spacing		= $SettingsBackground/Settings/Scroll/FontBlocks/ExtraSpacingBlock/ExtraSpacing/Bottom
onready var char_spacing		= $SettingsBackground/Settings/Scroll/FontBlocks/ExtraSpacingBlock/ExtraSpacing/Char
onready var space_spacing		= $SettingsBackground/Settings/Scroll/FontBlocks/ExtraSpacingBlock/ExtraSpacing/Space

onready var paronimas			= $Left/List/PanelContainer/Paronimas
onready var test_edit			= $Left/List/TestEdit

onready var compare_field		= $Left/List/CompareSetting
onready var compare_font_picker	= $Left/List/CompareSetting/TestField/Setting/FontPick
onready var compare_type_picker	= $Left/List/CompareSetting/TestField/Setting/TypePick
onready var compare_font_up		= $Left/List/CompareSetting/TestField/CompareUp
onready var compare_font_left	= $Left/List/CompareSetting/TestField/CompareLeft
onready var main_font_compare	= $Left/List/CompareSetting/TestField/WithFont

onready var cur_font_label		= $SettingsBackground/Settings/CurFontName

var updating_font_compare 		= false

signal font_list_updated

func _ready():	
	font_list.connect_to_unicdict(FontsData.font_dict)
	font_list.set_unchangable_items([Constants.defalut_key_name])
	compare_type_picker.update_items(FontsData.EditorFontInfo.TYPE.keys())


func get_fontinfo() -> FontsData.EditorFontInfo:
	return FontsData.get_fontinfo(font_list.get_selected_item())


func get_font_type(type : int) -> DynamicFont:
	var fontinfo = get_fontinfo()
	
	if !is_instance_valid(fontinfo): return null
			
	return fontinfo.get_font_type(type)


func open_font(font_id = FontsData.EditorFontInfo.TYPE.NORMAL):
	var selected_item = font_list.get_selected_item()
	var font_info : FontsData.EditorFontInfo = FontsData.get_fontinfo(selected_item)
	
	if !is_instance_valid(font_info): return
	
	var popup = FilePopup.new("", ["*.otf ; Open Type Font", "*.ttf ; True Type Font"])
	var title = "Pick {type} variant for " + selected_item + " font..."
	
	match font_id:
		FontsData.EditorFontInfo.TYPE.NORMAL:
			popup.window_title = title.format(["NORMAL"],"{type}")
		FontsData.EditorFontInfo.TYPE.BOLD:
			popup.window_title = title.format(["BOLD"],"{type}")
		FontsData.EditorFontInfo.TYPE.ITALIC:
			popup.window_title = title.format(["ITALIC"],"{type}")
		FontsData.EditorFontInfo.TYPE.ITALIC_BOLD:
			popup.window_title = title.format(["ITALIC-BOLD"],"{type}")
		_:
			popup.queue_free()
			return

	Ui.add_popup(popup, "file_selected", font_info, "set_font_type", [font_id])


func load_metrics():
	if !is_instance_valid(get_fontinfo()): return
	
	var font = get_font_type(FontsData.EditorFontInfo.TYPE.NORMAL)
	
	if is_instance_valid(font):		
		font_size_box.value 	= font.size
		outline_size_box.value 	= font.outline_size
		outline_color_pic.color = font.outline_color
		minmaps_check.pressed 	= font.use_mipmaps
		filter_check.pressed 	= font.use_filter
		
		top_spacing.value 		= font.extra_spacing_top
		bottom_spacing.value 	= font.extra_spacing_bottom
		char_spacing.value 		= font.extra_spacing_char
		space_spacing.value 	= font.extra_spacing_space
	else:
		Ui.popup_error("Normal not seted!")


func update_fonts():
	var fontinfo = get_fontinfo()
	
	test_edit.remove_font_override("font")
	paronimas.remove_font_override("normal_font")
	paronimas.remove_font_override("bold_font")
	paronimas.remove_font_override("italics_font")
	paronimas.remove_font_override("bold_italics_font")
	
	font_normal_bt.disabled 		= (font_list.get_selected_item() == Constants.defalut_key_name || !is_instance_valid(fontinfo))
	font_italic_bt.disabled 		= (font_list.get_selected_item() == Constants.defalut_key_name || !is_instance_valid(fontinfo))
	font_bold_bt.disabled 			= (font_list.get_selected_item() == Constants.defalut_key_name || !is_instance_valid(fontinfo))
	font_bold_italic_bt.disabled 	= (font_list.get_selected_item() == Constants.defalut_key_name || !is_instance_valid(fontinfo))
	compare_field.visible			= FontsData.get_fonts_list().size() > 1
	
	if is_instance_valid(fontinfo):
		if is_instance_valid(fontinfo.normal.font_data): font_normal_bt.text = "Change font file..."
		else: font_normal_bt.text = "Set font file..."
		
		if is_instance_valid(fontinfo.italic.font_data): font_italic_bt.text = "Change font file..."
		else: font_italic_bt.text = "Set font file..."
		
		if is_instance_valid(fontinfo.bold.font_data): font_bold_bt.text = "Change font file..."
		else: font_bold_bt.text = "Set font file..."
		
		if is_instance_valid(fontinfo.italic_bold.font_data): font_bold_italic_bt.text = "Change font file..."
		else: font_bold_italic_bt.text = "Set font file..."
		
		test_edit.add_font_override("font", fontinfo.normal)
		paronimas.add_font_override("normal_font", fontinfo.normal)
		paronimas.add_font_override("bold_font", fontinfo.bold)
		paronimas.add_font_override("italics_font", fontinfo.italic)
		paronimas.add_font_override("bold_italics_font", fontinfo.italic_bold)
	
	paronimas.bbcode_text = paronimas.bbcode_text


func _on_NormalFontChange_pressed():
	open_font(FontsData.EditorFontInfo.TYPE.NORMAL)


func _on_ItalicFontChange_pressed():
	open_font(FontsData.EditorFontInfo.TYPE.ITALIC)

	
func _on_BoldFontChange_pressed():
	open_font(FontsData.EditorFontInfo.TYPE.BOLD)


func _on_ItalicBoldFontChange_pressed():
	open_font(FontsData.EditorFontInfo.TYPE.ITALIC_BOLD)


func _on_FontSize_value_changed(value : int):
	for type in FontsData.EditorFontInfo.TYPE.values():
		var font = get_font_type(type)
	
		if is_instance_valid(font):
			font.size = value
	
	update_fonts()


func _on_OutlineSize_value_changed(value : int):
	for type in FontsData.EditorFontInfo.TYPE.values():
		var font = get_font_type(type)
		
		if is_instance_valid(font):
			font.outline_size = value
			
	update_fonts()


func _on_OutlineColor_color_changed(color : Color):
	for type in FontsData.EditorFontInfo.TYPE.values():
		var font = get_font_type(type)
		
		if is_instance_valid(font):
			font.outline_color = color
	
	update_fonts()


func _on_MinimapsCheck_toggled(button_pressed : bool):
	for type in FontsData.EditorFontInfo.TYPE.values():
		var font = get_font_type(type)
	
		if is_instance_valid(font):
			font.use_mipmaps = button_pressed
	
	update_fonts()


func _on_FilterCheck_toggled(button_pressed : bool):
	for type in FontsData.EditorFontInfo.TYPE.values():
		var font = get_font_type(type)
	
		if is_instance_valid(font):
			font.use_filter = button_pressed
	
	update_fonts()


func _on_Top_value_changed(value : int):
	for type in FontsData.EditorFontInfo.TYPE.values():
		var font = get_font_type(type)
	
		if is_instance_valid(font):
			font.extra_spacing_top = value
	
	update_fonts()
	

func _on_Bottom_value_changed(value : int):
	for type in FontsData.EditorFontInfo.TYPE.values():
		var font = get_font_type(type)
		
		if is_instance_valid(font):
			font.extra_spacing_bottom = value
	
	update_fonts()


func _on_Char_value_changed(value : int):
	for type in FontsData.EditorFontInfo.TYPE.values():
		var font = get_font_type(type)
	
		if is_instance_valid(font):
			font.extra_spacing_char = value
	
	update_fonts()


func _on_Space_value_changed(value : int):
	for type in FontsData.EditorFontInfo.TYPE.values():
		var font = get_font_type(type)
		
		if is_instance_valid(font):
			font.extra_spacing_space = value
			
	update_fonts()


func on_add_font_name(font_path : String) -> void:
	var fontinfo = FontsData.EditorFontInfo.new()
	var file_name = FilesData.make_string_nambered(font_path.get_file().rsplit(".", false, 1)[0], FontsData.font_dict.keys())
	fontinfo.set_font_type(font_path)
	FontsData.add_fontinfo(file_name, fontinfo)


func _on_FontList_add_item_request():
	var popup = FilePopup.new("Pick a font file", ["*.otf ; Open Type Font", "*.ttf ; True Type Font"])
	Ui.add_popup(popup, "file_selected", self, "on_add_font_name")


func _on_FontList_delete_item_request(item_name : String):
	if item_name == Constants.defalut_key_name: return
	
	var popup = ConfirmPopup.new("Do you want delete this font (" + item_name + ")?")
	Ui.add_popup(popup, "confirmed", FontsData, "erase_fontinfo", [item_name])


func _on_FontList_rename_item_request(item_name : String):
	if item_name == Constants.defalut_key_name: return
	
	var popup = NameDialog.new("Rename " + item_name + " to...", Project.Fonts.keys(), "", true)
	Ui.add_popup(popup, "name_confurmed", FontsData, "rename_fontinfo", [item_name])


func _on_FontList_item_selected(item_name : String):
	compare_font_picker.set_banned_items([item_name])
	compare_font_picker.update_items(FontsData.get_fonts_list())
	cur_font_label.text = item_name
	load_metrics()
	update_fonts()


func _on_CompareUp_text_changed(new_text : String):
	if updating_font_compare: return
	
	updating_font_compare = true
	compare_font_left.text = new_text
	main_font_compare.text = new_text
	updating_font_compare = false


func _on_CompareLeft_text_changed(new_text : String):
	if updating_font_compare: return
	
	updating_font_compare = true
	compare_font_up.text = new_text
	main_font_compare.text = new_text
	updating_font_compare = false


func _on_WithFont_text_changed(new_text : String):
	if updating_font_compare: return
	
	updating_font_compare = true
	compare_font_left.text = new_text
	compare_font_up.text = new_text
	updating_font_compare = false


func update_compare_fonts() -> void:
	var compare_font_info 	: FontsData.EditorFontInfo = FontsData.get_fontinfo(compare_font_picker.get_selected_item_text())
	var main_font_info		: FontsData.EditorFontInfo = get_fontinfo()
	
	compare_font_up.remove_font_override("font")
	compare_font_left.remove_font_override("font")
	main_font_compare.remove_font_override("font")
	
	if is_instance_valid(compare_font_info):
		var compare_font = compare_font_info.get_font_type(compare_type_picker.get_selected_item())
		compare_font_up.add_font_override("font", compare_font)
		compare_font_left.add_font_override("font", compare_font)
		
	if is_instance_valid(main_font_info):
		main_font_compare.add_font_override("font", main_font_info.get_font_type(compare_type_picker.get_selected_item()))


func _on_FontPick_item_selected(_item_name):
	update_compare_fonts()
	
	
func _on_TypePick_item_selected(_item_name):
	update_compare_fonts()
