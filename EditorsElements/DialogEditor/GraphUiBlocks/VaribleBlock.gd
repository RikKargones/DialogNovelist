extends BlockInfoGraphUi


onready var varible_name 	= $Varible/VaribleName
onready var varible_info	= $Values/ValuesInfo


func _update_ui() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_Varible:
		varible_name.text = blockinfo.varible_name
		
		if blockinfo is NBI_V_Bool:
			varible_info.text = "Action: "
			
			match blockinfo.action:
				NBI_V_Bool.ACTION.FLIP:
					varible_info.text += "Flip value"
				NBI_V_Bool.ACTION.TO_TRUE:
					varible_info.text += "Set to True"
				NBI_V_Bool.ACTION.TO_FALSE:
					varible_info.text += "Set to False"
		elif blockinfo is NBI_V_Number:
			varible_info.text = "Action: "
			
			match blockinfo.action:
				NBI_V_Number.ACTIONS.SET:
					varible_info.text += "Set value to " + str(blockinfo.value)
				NBI_V_Number.ACTIONS.ADD:
					varible_info.text += "Add " + str(blockinfo.value) + " to value"
				NBI_V_Number.ACTIONS.SUBSTRACT:
					varible_info.text += "Substract " + str(blockinfo.value) + " from value"
				NBI_V_Number.ACTIONS.DIVIDE:
					varible_info.text += "Divide value by " + str(blockinfo.value)
				NBI_V_Number.ACTIONS.MULTYPLY:
					varible_info.text += "Multyply value by " + str(blockinfo.value)
		elif blockinfo is NBI_V_String:
			varible_info.text = "Set text to: \"" + blockinfo.value + "\""
		else:
			varible_info.text = "Undifined varible!"
	
	
func _get_blockinfo_script() -> GDScript:
	return NBI_Varible

