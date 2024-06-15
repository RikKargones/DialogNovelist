extends EditVaribleBase

onready var number 		= $Num
onready var float_mode 	= $Float
onready var float_pow	= $Pow


func _ready():
	_on_Float_toggled(float_mode.pressed)


func _set_value(value) -> bool:
	if !(value is int || value is float): return false
	
	if value is float:
		var str_value_split	= String(value).split(".", false, 1)
		
		if str_value_split.size() > 1:
			float_mode.pressed 	= true
			float_pow.value		= clamp(str_value_split[1].length(), 1, 5)
			number.value 		= value
			return true
	
	number.value = int(value)
	
	return true


func save_value() -> void:
	VariblesData.set_varible(varible_name, number.value)
	emit_signal("varible_edited", number.value)


func _on_search_call(search_text : String) -> bool:
	return search_text.is_valid_float() && float(search_text) == number.value
	

func _on_Num_value_changed(value : float) -> void:
	save_value()


func _on_Float_toggled(button_pressed : bool) -> void:
	float_pow.visible = button_pressed
	
	if button_pressed: number.step = pow(10, -float_pow.value)
	else: number.step = 1
	
	number.value = number.value
	
	save_value()


func _on_Pow_value_changed(value : int) -> void:
	if float_mode.pressed: number.step = pow(10, -value)
	else: number.step = 1
	
	number.value = number.value
	
	save_value()
