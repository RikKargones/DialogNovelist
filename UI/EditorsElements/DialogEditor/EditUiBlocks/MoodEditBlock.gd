extends BlockInfoEditUi

onready var person_picker 	= $Pickers/PersonPicker
onready var mood_picker		= $Pickers/MoodPicker
onready var group_picker	= $Pickers/MoodGroupPicker
onready var align_picker	= $Pickers/AlignPicker
onready var mood_shower		= $MoodShower


func _ready() -> void:
	person_picker.connect_to_unicdict(PersonsData.person_dict)
	person_picker.set_placeholder(Constants.none_key_name)
	mood_picker.set_placeholder(Constants.keep_key_name)
	group_picker.set_placeholder(Constants.keep_key_name)
	align_picker.update_items(DialogDispetcher.PersonProfile.ALIGN_LIST.keys())


func reconnect_ui_by_selected_person() -> void:
	var personinfo = PersonsData.get_personinfo(person_picker.get_selected_item_text())
	
	if is_instance_valid(personinfo):
		mood_picker.connect_to_unicdict(personinfo.moods)
		group_picker.connect_to_unicdict(personinfo.get_groups_unicdict())
		align_picker.select_item_by_index(personinfo.defalut_align)
	else:
		mood_picker.disconect_from_unicdict()
		group_picker.disconect_from_unicdict()
		align_picker.select_item_by_index(DialogDispetcher.PersonProfile.ALIGN_LIST.CENTER)
	
	mood_shower.update_shower()


func send_update_msg() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is DialogDispetcher.NBI_MoodGroup:
		var msg = MoodUpdateMsg.new()
		msg.person = blockinfo.person
		msg.set_group(blockinfo.group)
	
		send_msg_to_next_nodes(msg)


func _on_connections_update() -> void:
	mood_shower.update_variants()
			

func _on_msg_recive_from_back(msg : NodeInfoMsg) -> void:
	if msg is ConnectionMsg: mood_shower.update_variants()


func _update_ui() -> void:
	if mood_shower.block_path != block_path: mood_shower.bound_to_block(block_path)
	
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is DialogDispetcher.NBI_Mood:
		if is_block_fresh():
			blockinfo.person = Constants.none_key_name
			blockinfo.mood = Constants.keep_key_name
			blockinfo.group = Constants.keep_key_name
			blockinfo.align = DialogDispetcher.PersonProfile.ALIGN_LIST.CENTER
			save_changes(blockinfo)
		
		person_picker.select_item(blockinfo.person)
		reconnect_ui_by_selected_person()
		mood_picker.select_item(blockinfo.mood)
		group_picker.select_item(blockinfo.group)
		align_picker.select_item(EditLibraly.get_align_name(blockinfo.align))
	
	mood_shower.update_variants()
	

func _get_blockinfo_script() -> GDScript:
	return DialogDispetcher.NBI_Mood


func _on_PersonPicker_item_selected(item_name : String) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is DialogDispetcher.NBI_Mood:
		var person_profile = PersonsData.get_personinfo(item_name)
		
		if blockinfo.person == item_name: return
			
		reconnect_ui_by_selected_person()
		
		blockinfo.person = item_name
		
		save_changes(blockinfo)
	
	mood_shower.update_variants()
	
	send_update_msg()
	

func _on_MoodPicker_item_selected(item_name : String) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is DialogDispetcher.NBI_Mood:
		blockinfo.mood = item_name
		save_changes(blockinfo)
	
	mood_shower.update_variants()
	
	send_update_msg()


func _on_MoodGroupPicker_item_selected(item_name : String) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is DialogDispetcher.NBI_Mood:
		blockinfo.group = item_name
		save_changes(blockinfo)
	
	mood_shower.update_variants()
	
	send_update_msg()


func _on_AlignPicker_item_selected(item_name : String) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is DialogDispetcher.NBI_Mood:
		blockinfo.align = EditLibraly.get_align_index(item_name)
		save_changes(blockinfo)
		
	mood_shower.update_shower()
	
	send_update_msg()
