extends BlockInfoGraphUi

onready var label = $SignalInfo

func _update_ui() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_Signal:
		if !VariblesData.has_custom_signal(blockinfo.varible_name):
			label.text = "SIGNAL NOT EXIST!"
			return
		
		label.text = "Emmit signal " + blockinfo.varible_name
		if blockinfo.signal_vars.size() > 0:
			label.text += "\nWith parameters: ( "
			
			for value_idx in blockinfo.signal_vars.size():
				var value = blockinfo.signal_vars[value_idx]
				
				if value is bool: label.text += str(value).capitalize()
				elif value is float || value is int: label.text += str(value)
				elif value is String: label.text += value
				else: label.text += "!" + str(value) + "!"
				
				if value_idx != blockinfo.signal_vars.size() - 1: label.text += "; "
			
			label.text += ")"
	

func _get_blockinfo_script() -> GDScript:
	return NBI_Signal
