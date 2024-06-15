extends BlockInfoGraphUi

onready var person_label		= $GridContainer/PersonName
onready var mood_group_label	= $GridContainer/MoodGroup
onready var mood_label			= $GridContainer/MoodName
onready var mood_align			= $GridContainer/Align
onready var tex_shower			= $MoodShower


func _update_ui() -> void:
	if tex_shower.block_path != path_to_block: tex_shower.bound_to_block(path_to_block)
	
	var blockinfo = path_to_block.get_block_info()
	
	if blockinfo is DialogDispetcher.NBI_Mood:
		person_label.text 		= blockinfo.person
		mood_label.text 		= blockinfo.mood
		mood_group_label.text 	= blockinfo.group
		mood_align.text 		= EditLibraly.get_align_name(blockinfo.align)
	
	tex_shower.update_variants()


func _get_blockinfo_script() -> GDScript:
	return DialogDispetcher.NBI_Mood
	
	
func _on_msg_recive_from_next(msg : NodeInfoMsg) -> void:
	if msg is MoodBlockFetchRequest:
		var blockinfo = path_to_block.get_block_info()
		
		if !is_instance_valid(blockinfo): return
	
		if blockinfo is DialogDispetcher.NBI_Mood:
			if blockinfo.person != msg.person || (blockinfo.mood == Constants.keep_key_name && blockinfo.group == Constants.keep_key_name):
				return
			
			send_msg_back(msg.generate_respond(path_to_block.node, blockinfo.mood, blockinfo.group))


func _on_msg_recive_from_back(msg : NodeInfoMsg) -> void:
	if msg is MoodUpdateMsg:
		tex_shower.update_variants()
