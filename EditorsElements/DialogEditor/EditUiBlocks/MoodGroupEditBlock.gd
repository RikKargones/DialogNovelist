extends BlockInfoEditUi

onready var person_picker 		= $Grid/PersonPicker
onready var mood_group_picker	= $Grid/MoodGroupPicker


func _ready() -> void:
	person_picker.connect_to_unicdict(PersonsData.person_dict)
	person_picker.set_placeholder(Constants.none_key_name)


func _update_ui() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_MoodGroup:
		if is_block_fresh():
			blockinfo.person = Constants.none_key_name
			blockinfo.group = Constants.none_key_name
			save_changes(blockinfo)
			
		_on_PersonPicker_item_selected(blockinfo.person)
		_on_MoodGroupPicker_item_selected(blockinfo.group)


func _get_blockinfo_script() -> GDScript:
	return NBI_MoodGroup


func send_update_msg() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_MoodGroup:
		var msg = MoodUpdateMsg.new()
		msg.person = blockinfo.person
		msg.set_group(blockinfo.group)
	
		send_msg_to_next_nodes(msg)


func _on_PersonPicker_item_selected(item_name : String) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_MoodGroup:
		var person_info = PersonsData.get_personinfo(item_name)
		
		blockinfo.person = item_name
		
		if is_instance_valid(person_info):
			mood_group_picker.set_placeholder("")
			mood_group_picker.connect_to_unicdict(person_info.get_groups_unicdict())
			blockinfo.group = Constants.defalut_key_name
		else:
			mood_group_picker.disconect_from_unicdict()
			mood_group_picker.set_placeholder(Constants.none_key_name)
			mood_group_picker.select_item(Constants.none_key_name)
		
		save_changes(blockinfo)
		
		send_update_msg()


func _on_MoodGroupPicker_item_selected(item_name : String) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_MoodGroup:
		var personinfo = PersonsData.get_personinfo(person_picker.get_selected_item_text())
		
		if is_instance_valid(personinfo) && personinfo.get_groups_list().has(item_name):
			blockinfo.group = item_name
		else:
			blockinfo.group = Constants.none_key_name
		
		save_changes(blockinfo)
		
		send_update_msg()
