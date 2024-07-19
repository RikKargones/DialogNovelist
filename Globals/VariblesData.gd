extends Node

var number_dict		: UnicDict = UnicDict.new()
var string_dict		: UnicDict = UnicDict.new()
var bool_dict		: UnicDict = UnicDict.new()
var signal_dict		: UnicDict = UnicDict.new()

signal varible_aded(var_name)
signal varible_renamed(old_var_name, new_var_name)
signal varible_deleted(var_name)


func setup() -> void:
	number_dict.clear()
	string_dict.clear()
	bool_dict.clear()
	signal_dict.clear()


func get_varibles_list() -> Array:
	var full_list = number_dict.keys()
	full_list.append_array(string_dict.keys())
	full_list.append_array(bool_dict.keys())
	return full_list


func get_varibles_and_signals_list() -> Array:
	var full_list = get_varibles_list()
	full_list.append_array(signal_dict.keys())
	
	return full_list


func add_varible(var_name : String, value) -> void:
	if get_varibles_and_signals_list().has(var_name): return
	
	var not_aded = false
	
	if value is bool: bool_dict.add_key(var_name, value)
	elif value is float || value is int: number_dict.add_key(var_name, value)
	elif value is String: string_dict.add_key(var_name, value)
	else: not_aded = true

	if !not_aded: emit_signal("varible_aded", var_name)


func has_varible(varible_name : String) -> bool:
	return bool_dict.has(varible_name) || number_dict.has(varible_name) || string_dict.has(varible_name)
	

func has_signal(varible_name : String) -> bool:
	return signal_dict.has(varible_name)
	
	
func set_varible(var_name : String, value) -> void:
	if bool_dict.has(var_name) && value is bool: bool_dict.set_key(var_name, value)
	elif number_dict.has(var_name) && (value is float || value is int): number_dict.set_key(var_name, value)
	elif string_dict.has(var_name) && value is String: string_dict.set_key(var_name, value)


func erase_varible(var_name : String) -> void:
	if !has_varible(var_name): return
	
	bool_dict.erase(var_name)
	number_dict.erase(var_name)
	string_dict.erase(var_name)
	
	emit_signal("varible_deleted", var_name)

	
func get_varible(var_name : String):
	if bool_dict.has(var_name): return bool_dict.get_value(var_name)
	if number_dict.has(var_name): return number_dict.get_value(var_name)
	if string_dict.has(var_name): return string_dict.get_value(var_name)
	return null
	

func rename_varible(old_var_name : String, new_var_name : String) -> void:
	if !has_varible(old_var_name) || has_varible(new_var_name): return
	
	bool_dict.rename_key(old_var_name, new_var_name)
	number_dict.rename_key(old_var_name, new_var_name)
	string_dict.rename_key(old_var_name, new_var_name)
	
	emit_signal("varible_renamed", old_var_name, new_var_name)
	
	
func add_signal(signal_name : String, default_varibles = []) -> void:
	if get_varibles_list().has(signal_name): return
	
	signal_dict.add_key(signal_name, default_varibles)
	
	
func set_signal_default_data(signal_name : String, default_varibles : Array) -> void:
	signal_dict.set_key(signal_name, default_varibles)
	

func get_signal_defalut_data(signal_name : String) -> Array:
	var value = signal_dict.get_value(signal_name)
	
	if typeof(value) == TYPE_ARRAY: return value
	return []
	
	
func rename_signal(old_signal_name : String, new_signal_name : String) -> void:
	signal_dict.rename_key(old_signal_name, new_signal_name)


func erase_signal(signal_name : String) -> void:
	signal_dict.erase(signal_name)
