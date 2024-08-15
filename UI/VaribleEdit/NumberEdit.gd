extends GridContainer

onready var number 	= $Number
onready var point	= $FloatPoint

signal number_changed(num)


func get_number() -> float:
	return number.value


func set_number(by : float) -> void:
	var number_split = str(by).split(".", true, 1)
	
	if number_split.size() == 1:
		point.value = 0
		number.value = int(by)
	elif number_split.size() == 2:
		point.value = number_split[2].length()
		number.step = pow(10, -point.value)
		number.value = by


func _on_Number_value_changed(value : float) -> void:
	emit_signal("number_changed", value)


func _on_FloatPoint_value_changed(value : int) -> void:
	number.step = pow(10, -value)
	number.value = number.value
