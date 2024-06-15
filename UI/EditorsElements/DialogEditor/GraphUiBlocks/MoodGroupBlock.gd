extends BlockInfoGraphUi

onready var group_label = $GroupName


func _update_ui() -> void:
	var blockinfo = path_to_block.get_block_info()
	
	if blockinfo is DialogDispetcher.NBI_MoodGroup:
		group_label.text = "PERSON: " + blockinfo.person + "\nGROUP: " + blockinfo.group


func _on_msg_recive_from_next(msg : NodeInfoMsg) -> void:
	if msg is MoodBlockFetchRequest:
		var blockinfo = path_to_block.get_block_info()
		
		if !is_instance_valid(blockinfo): return
	
		if blockinfo is DialogDispetcher.NBI_MoodGroup:
			if blockinfo.person != msg.person || blockinfo.group == "":
				return
			
			send_msg_back(msg.generate_respond(path_to_block.node, "", blockinfo.group))


func _get_blockinfo_script() -> GDScript:
	return DialogDispetcher.NBI_MoodGroup
