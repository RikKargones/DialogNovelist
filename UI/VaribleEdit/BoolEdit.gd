extends CheckBox

class_name BoolEdit

func _ready() -> void:
	_toggled(pressed)

func _toggled(button_pressed : bool) -> void:
	text = str(button_pressed).capitalize()
