extends DialogDispetcher.NBI_Choose

class_name NBI_EditorBranch

export var parse_results 	: Array
export var has_locales		: bool


func add_new_option() -> void:
	conditions.append("")
	option_names.append("")
	parse_results.append("")
	if conditions.size() == 1: defalut_id = 0
	

func remove_option(opt_id : int) -> void:
	if opt_id >= option_names.size() || opt_id < 0: return
	
	conditions.remove(opt_id)
	option_names.remove(opt_id)
	parse_results.remove(opt_id)
	
	if defalut_id >= opt_id: defalut_id -= 1
	if defalut_id == -1 && option_names.size() > 0: defalut_id = 0


func get_option_name(opt_id : int) -> String:
	if opt_id >= option_names.size() || opt_id < 0: return ""
	return option_names[opt_id]
	

func get_option_condition(opt_id : int) -> String:
	if opt_id >= conditions.size() || opt_id < 0: return ""
	return conditions[opt_id]
	

func get_option_parse_results(opt_id : int) -> String:
	if opt_id >= parse_results.size() || opt_id < 0: return ""
	return parse_results[opt_id]
