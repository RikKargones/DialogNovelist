extends VBoxContainer

onready var code_edit		= $CodeEdit
onready var bbcode_show 	= $Control/PanelContainer/ScrollContainer/RichTextLabel
onready var popup_scroll	= $Control/PanelContainer/ScrollContainer
onready var popup_panel		= $Control/PanelContainer

var text 		: String 	setget set_text
var on_popup 	: bool
var on_edit		: bool

signal text_changed


func _ready():
	popup_panel.hide()


func set_text(new_text : String, silent = false) -> void:
	text = new_text
	bbcode_show.bbcode_text = text
	
	if !silent: code_edit.text = text
	else: emit_signal("text_changed")
	
	ajust_popup()


func set_font(fontdata : FontsData.EditorFontInfo) -> void:
	bbcode_show.remove_font_override("normal_font")
	bbcode_show.remove_font_override("bold_font")
	bbcode_show.remove_font_override("italics_font")
	bbcode_show.remove_font_override("bold_italics_font")
	
	if !is_instance_valid(fontdata): return
	
	bbcode_show.add_font_override("normal_font", fontdata.normal)
	bbcode_show.add_font_override("bold_font", fontdata.bold)
	bbcode_show.add_font_override("italics_font", fontdata.italic)
	bbcode_show.add_font_override("bold_italics_font", fontdata.italic_bold)


func ajust_popup() -> void:
	if is_queued_for_deletion(): return
	
	popup_panel.visible = (text.strip_edges() != "")
	
	if !popup_panel.visible: return
	
	yield(get_tree(), "idle_frame")
	
	var height_diff = bbcode_show.rect_global_position.y - popup_panel.rect_global_position.y
	var fin_y		= code_edit.rect_global_position.y + code_edit.rect_size.y / 2
	
	popup_panel.rect_size.y = clamp(bbcode_show.rect_size.y + height_diff * 2, 0, OS.window_size.y)
	fin_y -= popup_panel.rect_size.y / 2
	
	popup_panel.rect_global_position.x = code_edit.rect_global_position.x
	
	popup_panel.rect_global_position.y = clamp(fin_y, 0, OS.window_size.y - popup_panel.rect_size.y)
	
	popup_panel.rect_size.x = code_edit.rect_size.x
	
	if popup_panel.rect_global_position.x + code_edit.rect_size.x * 2 < OS.window_size.x:
		popup_panel.rect_global_position.x += code_edit.rect_size.x
	elif popup_panel.rect_global_position.x - code_edit.rect_size.x < 0:
		popup_panel.rect_global_position.x = 0
		popup_panel.rect_size.x = code_edit.rect_global_position.x
	else:
		popup_panel.rect_global_position.x -= code_edit.rect_size.x


func is_on_edit() -> bool:
	if !code_edit.visible: return false
	
	return code_edit.get_global_rect().has_point(get_global_mouse_position())


func is_on_popup() -> bool:
	if !popup_panel.visible: return false
	
	return popup_panel.get_global_rect().has_point(get_global_mouse_position())


func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed:
			if text.strip_edges() == "": return
			
			if popup_panel.visible:
				if !is_on_popup() && !is_on_edit(): popup_panel.hide()
				else: ajust_popup()
			elif is_on_edit():
				ajust_popup()
				popup_panel.show()


func _on_CodeEdit_text_changed():
	set_text(code_edit.text, true)
