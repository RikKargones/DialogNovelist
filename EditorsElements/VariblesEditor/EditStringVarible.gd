extends EditVaribleBase

onready var text_edit = $StringEdit


func _set_value(value) -> bool:
	if !value is String: return false
	
	text_edit.set_text(value)
	
	return true


func _on_search_call(search_text : String) -> bool:
	return text_edit.text.begins_with(search_text)


func _on_StringEdit_text_changed(new_text : String) -> void:
	if varible_name != "": VariblesData.set_varible(varible_name, new_text)
	emit_signal("varible_edited", new_text)
