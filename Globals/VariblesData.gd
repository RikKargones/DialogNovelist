extends Node

var bool_list	: Array
var num_list	: Array
var str_list 	: Array

signal varible_aded(var_name)
signal varible_renamed(old_var_name, new_var_name)
signal varible_deleted(var_name)

signal signal_defalut_values_changed(signal_name)


func get_varibles_dict() -> UnicDict:
	if !is_instance_valid(Project): return UnicDict.new()
	return Project.get_project_info().varibles_data as UnicDict


func get_signals_dict() -> UnicDict:
	if !is_instance_valid(Project): return UnicDict.new()
	return Project.get_project_info().signals_data as UnicDict


func get_varibles_list() -> Array:
	return get_varibles_dict().keys()


func get_bool_list() -> Array:
	return bool_list.duplicate()
	
	
func get_number_list() -> Array:
	return num_list.duplicate()
	
	
func get_string_list() -> Array:
	return str_list.duplicate()


func get_varibles_and_signals_list() -> Array:
	var full_list = get_varibles_list()
	full_list.append_array(get_signals_dict().keys())
	
	return full_list


func add_varible(var_name : String, value) -> void:
	if get_varibles_and_signals_list().has(var_name): return
	
	var aded = true
	
	if value is bool:
		bool_list.append(var_name)
	elif value is float || value is int:
		num_list.append(var_name)
	elif value is String:
		 str_list.append(var_name) 
	else:
		aded = false
		
	if aded:
		get_varibles_dict().add_key(var_name, value)
		emit_signal("varible_aded", var_name)


func has_varible(varible_name : String) -> bool:
	return get_varibles_dict().has(varible_name)
	

func has_custom_signal(varible_name : String) -> bool:
	return get_signals_dict().has(varible_name)
	
	
func set_varible(var_name : String, value) -> void:
	get_varibles_dict().set_key(var_name, value)


func erase_varible(var_name : String) -> void:
	get_varibles_dict().erase(var_name)
	
	bool_list.erase(var_name)
	num_list.erase(var_name)
	str_list.erase(var_name)
	
	emit_signal("varible_deleted", var_name)

	
func get_varible(var_name : String):
	return get_varibles_dict().get_value(var_name)
	

func rename_varible(old_var_name : String, new_var_name : String) -> void:
	if get_varibles_and_signals_list().has(new_var_name): return
	
	if bool_list.has(old_var_name):
		bool_list[bool_list.find(old_var_name)] = new_var_name
	elif num_list.has(old_var_name):
		num_list[num_list.find(old_var_name)] = new_var_name
	elif str_list.has(old_var_name):
		str_list[str_list.find(old_var_name)] = new_var_name
	
	get_varibles_dict().rename_key(old_var_name, new_var_name)
	
	emit_signal("varible_renamed", old_var_name, new_var_name)
	
	
func add_signal(signal_name : String, default_varibles = []) -> void:
	if get_varibles_and_signals_list().has(signal_name): return
	
	get_signals_dict().add_key(signal_name, default_varibles)
	
	
func set_signal_default_data(signal_name : String, default_varibles : Array) -> void:
	get_signals_dict().set_key(signal_name, default_varibles)
	emit_signal("signal_defalut_values_changed", signal_name)


func get_signal_defalut_data(signal_name : String) -> Array:
	var value = get_signals_dict().get_value(signal_name)
	
	if typeof(value) == TYPE_ARRAY: return value
	return []
	
	
func rename_signal(old_signal_name : String, new_signal_name : String) -> void:
	get_signals_dict().rename_key(old_signal_name, new_signal_name)


func erase_signal(signal_name : String) -> void:
	get_signals_dict().erase(signal_name)
