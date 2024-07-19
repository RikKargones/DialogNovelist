extends Resource

class_name UnicDict

export var dict : Dictionary

signal key_aded(key)
signal key_renamed(old_key, new_key)
signal key_deleted(key)
signal cleared()

func keys() -> Array:
	return dict.keys()
	
func values() -> Array:
	return dict.values()
	
func get_value(key : String):
	if !dict.has(key): return null
	return dict[key]
	
func has(key : String) -> bool:
	return dict.has(key)		

func move_key_position(key : String, position : int) -> void:
	if !has(key): return
	
	var new_keys_list = []
	
	for old_key_idx in dict.keys().size():
		if dict.keys()[old_key_idx] == key && old_key_idx == position:
			return
		
		if dict.keys()[old_key_idx] != key:
			new_keys_list.append(dict.keys()[old_key_idx])
	
	if new_keys_list.size() > position && position > -1:
		new_keys_list.insert(position, key)
	elif position < 0:
		new_keys_list.insert(0, key)
	else:
		new_keys_list.append(key)
	
	var new_dict = {}
	
	for new_key in new_keys_list:
		new_dict[new_key] = dict[new_key]
	
	dict = new_dict
	
func add_key(key : String, value) -> void:
	if dict.has(key): return
	dict[key] = value
	emit_signal("key_aded", key)
	
func set_key(key : String, value) -> void:
	if !dict.has(key): return
	dict[key] = value
	
func rename_key(old_key : String, new_key : String) -> void:
	if !dict.has(old_key) || dict.has(new_key): return
	dict[new_key] = dict[old_key]
	dict.erase(old_key)
	emit_signal("key_renamed", old_key, new_key)

func clear() -> void:
	dict.clear()
	emit_signal("cleared")

func erase(key : String) -> void:
	if !dict.has(key): return
	dict.erase(key)
	emit_signal("key_deleted", key)
	
func _to_string() -> String:
	return str(dict)
