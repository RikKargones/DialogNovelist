extends BlockInfoEditUi

var option_pck 			: PackedScene	= preload("res://EditorsElements/DialogEditor/Option.tscn")
var option_instances 	: Array
var should_localise		: bool


func add_option_ui() -> EditOptionUi:
	var new_opt = option_pck.instance()
	
	new_opt.connect("option_set_as_defalut", self, "on_option_defalut_set", [new_opt])
	new_opt.connect("conditions_edited", self, "on_option_conditions_changed", [new_opt])
	new_opt.connect("conditions_parse_result_gained", self, "on_option_conditions_parse", [new_opt])
	new_opt.connect("option_name_changed", self, "on_option_name_change", [new_opt])
	new_opt.connect("option_deleted", self, "on_option_delete", [new_opt])
	
	add_child(new_opt)
	
	option_instances.append(new_opt)
	
	return new_opt


func get_option_instance(id : int) -> EditOptionUi:
	if id < -1 || id >= option_instances.size(): return null
	return option_instances[id]


func get_option_id(option : EditOptionUi) -> int:
	return option_instances.find(option)


func on_option_defalut_set(option : EditOptionUi) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_EditorBranch:
		var opt_id = get_option_id(option)
		var cur_defalut = get_option_instance(blockinfo.defalut_id)
		
		if opt_id == -1: return
		
		if is_instance_valid(cur_defalut):
			cur_defalut.set_as_defalut(false)
		
		option.set_as_defalut(true)
		blockinfo.defalut_id = opt_id
		
		save_changes(blockinfo)


func on_option_name_change(new_name : String, option : EditOptionUi) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_EditorBranch:
		var opt_id = get_option_id(option)
		
		if opt_id == -1: return
		
		blockinfo.option_names[opt_id] = new_name
		
		save_changes(blockinfo)
	
	
func on_option_conditions_changed(new_condition_text : String, option : EditOptionUi) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_EditorBranch:
		var opt_id = get_option_id(option)
		
		if opt_id == -1: return
		
		blockinfo.conditions[opt_id] = new_condition_text
		
		save_changes(blockinfo)


func on_option_conditions_parse(parse_error_string : String, option : EditOptionUi) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_EditorBranch:
		var opt_id = get_option_id(option)
		
		if opt_id == -1: return
		
		blockinfo.parse_results[opt_id] = parse_error_string
		
		save_changes(blockinfo)


func on_option_delete(option : EditOptionUi) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_EditorBranch:
		var opt_id = get_option_id(option)
		
		if opt_id == -1: return
		
		blockinfo.remove_option(opt_id)
		option_instances.erase(option)
		
		var new_def_id_opt = get_option_instance(blockinfo.defalut_id)
		
		if is_instance_valid(new_def_id_opt):
			new_def_id_opt.set_as_defalut(true)
		else:
			Ui.popup_error("CAN'T SET A DEFALUT OPTION.\nADD NEW OPTION OR RELOAD THIS NODE BY RESELECTING!", "BLOCKINFO_BRANCH_EDIT")
		
		save_changes(blockinfo)


func _update_ui() -> void:
	var blockinfo = get_blockinfo_copy()
	
	for opt in option_instances:
		if !is_instance_valid(opt): continue
		opt.queue_free()
		
	option_instances.clear()
	
	if blockinfo is NBI_EditorBranch:
		if is_block_fresh() && should_localise:
			blockinfo.has_locales = true
			save_changes(blockinfo)
		
		for opt_id in blockinfo.option_names.size():
			var new_opt = add_option_ui()
			
			if blockinfo.has_locales:
				new_opt.set_text(LocalesData.get_locale_msg_text(Project.current_edit_locale, blockinfo.get_option_name(opt_id)))
			else:
				new_opt.set_text(blockinfo.get_option_name(opt_id))
				
			new_opt.set_conditions(blockinfo.get_option_condition(opt_id))
			
			if opt_id == blockinfo.defalut_id: new_opt.set_as_defalut(true)
		
		if option_instances.size() == 0:
			_add_new_option(true)
		elif blockinfo.defalut_id == -1 || blockinfo.defalut_id >= option_instances.size():
			on_option_defalut_set(get_option_instance(option_instances.size() - 1))


func _add_new_option(set_as_defalut = false) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_EditorBranch:
		blockinfo.add_new_option()
		var new_opt_ui = add_option_ui()
		
		if set_as_defalut:
			new_opt_ui.set_as_defalut(true)
			on_option_defalut_set(new_opt_ui)
			
		save_changes(blockinfo)
		

func _get_blockinfo_script() -> GDScript:
	return NBI_EditorBranch


func _on_AddBt_pressed() -> void:
	_add_new_option()
