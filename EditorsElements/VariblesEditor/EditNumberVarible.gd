extends EditVaribleBase

onready var number = $NumberEdit


func _set_value(value) -> bool:
	if !(value is int || value is float): return false
	
	number.set_number(value)
	
	return true


func save_value() -> void:
	if varible_name != "": VariblesData.set_varible(varible_name, number.get_number())
	emit_signal("varible_edited", number.get_number())


func _on_search_call(search_text : String) -> bool:
	return search_text.is_valid_float() && float(search_text) == number.get_number()


func _on_NumberEdit_number_changed(_num : float):
	save_value()
