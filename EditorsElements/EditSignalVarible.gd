extends EditVaribleBase

onready var varible_list = $All/Scroll/VariblesList

var pck_bool_edit 	= preload("res://EditorsElements/VariblesEditor/Bool.tscn")
var pck_string_edit = preload("res://EditorsElements/VariblesEditor/String.tscn")
var pck_number_edit	= preload("res://EditorsElements/VariblesEditor/Number.tscn")

var values = []


func _set_value(value) -> bool:
	if !value is Array: return false
		
	for item in value:
		if item is int || item is float: add_number(item)
		elif item is String: add_string(item)
		elif item is bool: add_bool(item)
	
	return true


func add_element(new_element : EditVaribleBase, value) -> void:
	var up_bt 	= Button.new()
	var down_bt = Button.new()
	var cont	= HBoxContainer.new()
	
	up_bt.text = "/\\"
	down_bt.text = "\\/"
	
	varible_list.add_child(new_element)
	new_element.add_child(cont)
	cont.add_child(up_bt)
	cont.add_child(down_bt)
	
	new_element.move_child(cont, 0)
	
	new_element.connect("varible_edited", self, "on_varible_edit", [new_element])
	new_element.connect("varible_deleted", self, "on_varible_delete", [new_element])
	up_bt.connect("pressed", self, "on_varible_up_call", [new_element])
	down_bt.connect("pressed", self, "on_varible_down_call", [new_element])
	
	new_element._set_value(value)
	new_element.hide_rename()
	
	values.append(value)


func add_bool(value = false) -> void:
	var element = pck_bool_edit.instance()
	add_element(element, value)


func add_string(value = "") -> void:
	var element = pck_string_edit.instance()
	add_element(element, value)
	
	
func add_number(value = 0) -> void:
	var element = pck_number_edit.instance()
	add_element(element, value)


func save_value() -> void:
	VariblesData.set_signal_default_data(varible_name, values)


func on_varible_up_call(element : EditVaribleBase) -> void:
	var index = element.get_index()
	
	if index == 0: return
	
	varible_list.move_child(element, index - 1)
	
	var first_value 	= values[index]
	var second_value 	= values[index - 1]
	values[index] 		= second_value
	values[index - 1]		= first_value
	
	save_value()


func on_varible_down_call(element : EditVaribleBase) -> void:
	var index = element.get_index()
	
	if index == varible_list.get_child_count() - 1: return
	
	varible_list.move_child(element, index + 1)
	
	var first_value 	= values[index]
	var second_value 	= values[index + 1]
	values[index] 		= second_value
	values[index + 1]		= first_value
	
	save_value()


func on_varible_edit(value, element : EditVaribleBase) -> void:
	values[element.get_index()] = value


func on_varible_delete(element : EditVaribleBase) -> void:
	values.remove(element.get_index())


func _on_AddBool_pressed() -> void:
	add_bool()


func _on_AddNumber_pressed() -> void:
	add_number()


func _on_AddString_pressed() -> void:
	add_string()
