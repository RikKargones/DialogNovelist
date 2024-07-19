extends BlockInfoGraphUi

onready var group_label = $GroupName


func _update_ui() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_MoodGroup:
		group_label.text = "PERSON: " + blockinfo.person + "\nGROUP: " + blockinfo.group


func _on_msg_recive_from_next(msg : NodeInfoMsg) -> void:
	if msg is MoodBlockFetchRequest:
		var blockinfo = get_blockinfo_copy()
		
		if !is_instance_valid(blockinfo): return
	
		if blockinfo is NBI_MoodGroup:
			if blockinfo.person != msg.person || blockinfo.group == "":
				return
			
			send_msg_back(msg.generate_respond(block_path.node, "", blockinfo.group))


func _get_blockinfo_script() -> GDScript:
	return NBI_MoodGroup
