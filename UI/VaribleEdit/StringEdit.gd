extends GridContainer

onready var line_edit 	= $TextEdit/LineEdit
onready var expand_edit	= $TextEdit/BBCodeEditor

var sinhronizing : bool = false

signal text_changed(new_text)


func set_text(new_text : String) -> void:
	sinhronizing = true
	
	line_edit.text = new_text
	expand_edit.set_text(new_text)
	
	sinhronizing = false
	
	
func get_text() -> String:
	return expand_edit.text
	

func _on_LineEdit_text_changed(new_text : String) -> void:
	if sinhronizing: return
	sinhronizing = true
	
	expand_edit.set_text(new_text)
	
	emit_signal("text_changed", expand_edit.text)
	sinhronizing = false


func _on_BBCodeEditor_text_changed() -> void:
	if sinhronizing: return
	sinhronizing = true
	
	line_edit.text = expand_edit.text
	
	emit_signal("text_changed", expand_edit.text)
	sinhronizing = false
