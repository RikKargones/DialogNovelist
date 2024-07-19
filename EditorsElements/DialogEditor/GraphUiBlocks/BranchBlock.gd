extends BlockInfoGraphUi

onready var def_opt_name 	= $OptionName

func _update_ui() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_EditorBranch:
		var labels = []
		
		for label_id in blockinfo.option_names.size() - 1:
			var label = Label.new()
			label.autowrap = true
			labels.append(label)
		
		resize_ports(labels)

		for opt_id in blockinfo.option_names.size():
			if opt_id == blockinfo.defalut_id:
				if blockinfo.has_locales:
					def_opt_name.text = LocalesData.get_locale_msg_text(Project.current_edit_locale, blockinfo.get_option_name(opt_id))
				else:
					def_opt_name.text = blockinfo.get_option_name(opt_id)
					
				if def_opt_name.text.strip_edges() == "":
					def_opt_name.text = "<Unnamed option>"
			else:
				var cur_opt_id		: int		= opt_id - 1 * int(opt_id > blockinfo.defalut_id && blockinfo.defalut_id != -1)
				var block_opt_name 	: String 	= blockinfo.get_option_name(opt_id)
				var block_opt_cond 	: String 	= blockinfo.get_option_condition(opt_id)
				var parse_result	: String 	= blockinfo.get_option_parse_results(opt_id)
				
				set_option(cur_opt_id, blockinfo.has_locales, block_opt_name, block_opt_cond, parse_result)


func set_option(opt_id : int, is_localed : bool, opt_name : String, opt_cond : String, parse_result : String) -> void:
	var opt : Label = get_port(opt_id)
	
	if !is_instance_valid(opt):
		Ui.popup_error("Can't load option data becouse option instance is lost!")
		return
	
	opt.text = "Option: "
	
	if is_localed:
		opt_name = LocalesData.get_locale_msg_text(Project.current_edit_locale, opt_name)
	
	if opt_name.strip_edges() == "": opt.text += "<Unnamed option>"
	else: opt.text += opt_name
	
	opt.text += "\nCondition: "
	
	if opt_cond.strip_edges() == "": opt.text += "<Empty>"
	else: opt.text += opt_cond
	
	if parse_result != "": opt.text += "PARSE FAILED! (" + parse_result + ")"


func _get_blockinfo_script() -> GDScript:
	return NBI_EditorBranch
