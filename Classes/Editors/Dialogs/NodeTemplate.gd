extends Resource

class_name NodeTemplate

export var pcks_path : Resource = UnicDict.new()

func add_pck_path(block_key : String, path : String) -> void:
	pcks_path.add_key(block_key, path)
	
func get_keys() -> Array:
	return pcks_path.keys()
	
func get_pck_path(block_key : String) -> String:
	var pck_path = pcks_path.get_value(block_key)
	
	if pck_path is String: return pck_path
	return ""
