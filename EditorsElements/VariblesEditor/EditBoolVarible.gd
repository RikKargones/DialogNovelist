extends EditVaribleBase

onready var switch = $Switch


func _set_value(value) -> bool:
	if !value is bool: return false
	
	switch.pressed = value
	
	return true


func _on_search_call(search_text : String) -> bool:
	return search_text.to_lower() == "true" || search_text.to_lower() == "false"


func _on_Switch_toggled(button_pressed : bool):
	if button_pressed: switch.text = "True"
	else: switch.text = "False"
	VariblesData.set_varible(varible_name, button_pressed)
	emit_signal("varible_edited")
