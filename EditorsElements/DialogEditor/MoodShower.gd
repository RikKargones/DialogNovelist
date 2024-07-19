extends VBoxContainer

onready var picture_aspect	= $Aspect
onready var picture 		= $Aspect/Shower/Picture
onready var variant_picker 	= $VariantPicker

var block_path	 			: NodeBlockPath 			= NodeBlockPath.new()
var mood_variants_list 		: UnicDict = UnicDict.new()
var respond_buffer			: Dictionary


func _ready():
	variant_picker.connect_to_unicdict(mood_variants_list)


func bound_to_block(new_path : NodeBlockPath) -> void:
	if !is_instance_valid(new_path): return
	
	EditLibraly.disconect_incoming_signals(["msg_recived"], self)
	
	var nodeinfo = new_path.get_node_info()
	
	if !is_instance_valid(nodeinfo): return
	
	block_path = new_path
	
	nodeinfo.connect("msg_recived", self, "on_msg_recive")
	#nodeinfo.connect("msg_recived_from_back", self, "_on_msg_recive_from_back")
	#nodeinfo.connect("msg_recived_from_next", self, "_on_msg_recive_from_next")
	update_variants()


func on_msg_recive(msg : NodeInfoMsg) -> void:
	if msg.origin != block_path.node: return
	
	var blockinfo = block_path.get_block_info()
	
	if !is_instance_valid(blockinfo): return
	
	if msg is MoodBlockFetchRespond:
		if blockinfo is NBI_Mood:
			if msg.person != blockinfo.person: return
			
			var add_new = true
			
			for respond in respond_buffer.keys():
				if respond.size() >= msg.respond_list.size(): continue
				
				var this_has = true
				
				for respond_elem in respond:
					if !msg.respond_list.has(respond_elem):
						this_has = false
						break
				
				if this_has:
					var final_mood = msg.mood
					var final_group = msg.group
					
					if final_mood == "": final_mood = msg.mood
					if final_group == "": final_group = msg.group
					
					respond_buffer[msg.respond_list] = [final_mood, final_group]
					respond_buffer.erase(respond)
					add_new = false
					break
			
			if add_new: respond_buffer[msg.respond_list] = [msg.mood, msg.group]


func update_variants() -> void:
	var blockinfo = block_path.get_block_info()
	
	mood_variants_list.clear()
	variant_picker.visible = false
	
	if blockinfo is NBI_Mood:
		if PersonsData.get_persons_list().has(blockinfo.person) && (blockinfo.mood == Constants.keep_key_name || blockinfo.group == Constants.keep_key_name):
			var dialog = block_path.get_dialog_info()
			respond_buffer.clear()
			
			var msg = MoodBlockFetchRequest.new()
			msg.origin = block_path.node
			msg.person = blockinfo.person
			msg.set_mood(blockinfo.mood)
			msg.set_group(blockinfo.group)
			
			var diainfo	= block_path.get_dialog_info()
			
			diainfo.send_msg_to_back_nodes(msg)
			
			for respond in respond_buffer.keys():
				var variant_name : String = "Variant " + str(mood_variants_list.keys().size() + 1)
				mood_variants_list.add_key(variant_name, respond_buffer[respond])
				
			variant_picker.visible = mood_variants_list.keys().size() > 1
			
			respond_buffer.clear()
	update_shower()


func update_shower() -> void:
	var blockinfo = block_path.get_block_info()
	
	if blockinfo is NBI_Mood:
		var person_profile = PersonsData.get_personinfo(blockinfo.person)
		
		match blockinfo.align:
			PersonProfile.ALIGN_LIST.LEFT:
				picture_aspect.alignment_horizontal = AspectRatioContainer.ALIGN_BEGIN
			PersonProfile.ALIGN_LIST.CENTER:
				picture_aspect.alignment_horizontal = AspectRatioContainer.ALIGN_CENTER
			PersonProfile.ALIGN_LIST.RIGHT:
				picture_aspect.alignment_horizontal = AspectRatioContainer.ALIGN_END
		
		if !is_instance_valid(person_profile):
			picture.texture = null
			return
		
		if mood_variants_list.keys().size() == 0:
			picture.texture = person_profile.get_mood_texture(blockinfo.mood, blockinfo.group)
		else:
			var mood_variant = mood_variants_list.get_value(variant_picker.get_selected_item_text())
			
			if !(mood_variant is Array && mood_variant.size() == 2):
				picture.texture = null
				return
			
			picture.texture = person_profile.get_mood_texture(mood_variant[0], mood_variant[1])
	else:
		picture.texture = null


func _on_VariantPicker_item_selected(_item_name : String) -> void:
	update_shower()
