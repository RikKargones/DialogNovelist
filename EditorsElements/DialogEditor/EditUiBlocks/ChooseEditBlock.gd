extends "res://EditorsElements/DialogEditor/EditUiBlocks/BranchEditBlock.gd"


func _ready() -> void:
	should_localise = true


func on_option_name_change(new_name : String, option : EditOptionUi) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_EditorBranch:
		var opt_id = get_option_id(option)
		
		if opt_id == -1: return
		
		LocalesData.set_locale_msg(Project.current_edit_locale, blockinfo.option_names[opt_id], new_name)
		
		save_changes(blockinfo)


func _add_new_option(set_as_defalut = false) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_EditorBranch:
		blockinfo.add_new_option()
		
		var new_opt_ui = add_option_ui()
		
		var last_opt_idx = blockinfo.option_names.size() - 1
		blockinfo.option_names[last_opt_idx] = add_locale_key("OPTION" + str(last_opt_idx))
		
		if set_as_defalut:
			new_opt_ui.set_as_defalut(true)
			on_option_defalut_set(new_opt_ui)
		else:
			save_changes(blockinfo)
		
		
func _on_option_delete(option : EditOptionUi) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_EditorBranch:
		var opt_id = get_option_id(option)
		
		if opt_id == -1: return
		
		blockinfo.remove_option(opt_id)
		option_instances.erase(option)
		
		for opt_idx in blockinfo.option_names.size():
			if opt_id > opt_idx: continue
			blockinfo.option_names[opt_idx] = rename_locale_key(blockinfo.option_names[opt_idx], "OPTION" + str(opt_idx))
		
		var new_def_id_opt = get_option_instance(blockinfo.defalut_id)
		
		if is_instance_valid(new_def_id_opt):
			new_def_id_opt.set_as_defalut(true)
		else:
			Ui.popup_error("CAN'T SET A DEFALUT OPTION.\nADD NEW OPTION OR RELOAD THIS NODE BY RESELECTING!", "BLOCKINFO_СHOOSE_EDIT")
		
		save_changes(blockinfo)
