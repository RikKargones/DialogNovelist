extends EditVaribleBase

onready var line_edit 	= $Edits/StringEdit
onready var expand_edit = $Edits/ExpandEdit
onready var expand_bt	= $ExpandBt

var updating = false


func _ready():
	_on_ExpandBt_toggled(expand_bt.pressed)


func _set_value(value) -> bool:
	if !value is String: return false
	
	updating = true
	line_edit.text 		= value
	expand_edit.text 	= value
	updating = false
	
	return true


func _on_search_call(search_text : String) -> bool:
	return line_edit.text.begins_with(search_text)


func _on_StringEdit_text_changed(new_text : String) -> void:
	if updating: return
	
	VariblesData.set_varible(varible_name, line_edit.text)
	updating = true
	expand_edit.text = line_edit.text
	updating = false
	emit_signal("varible_edited", line_edit.text)


func _on_ExpandEdit_text_changed() -> void:
	if updating: return
	
	VariblesData.set_varible(varible_name, expand_edit.text)
	updating = true
	line_edit.text = expand_edit.text
	updating = false
	emit_signal("varible_edited", expand_edit.text)


func _on_ExpandBt_toggled(button_pressed : bool) -> void:
	line_edit.visible 	= !button_pressed
	expand_edit.visible = button_pressed
