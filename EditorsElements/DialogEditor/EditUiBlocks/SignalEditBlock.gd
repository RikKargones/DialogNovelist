extends BlockInfoEditUi

onready var set_section			= $SetSection
onready var varibles_sender 	= $SetSection/ScrollContainer/VariblesSender
onready var varibles_scroller 	= $SetSection/ScrollContainer
onready var signal_picker		= $SignalPick

var number_edit_pck = preload("res://UI/VaribleEdit/NumberEdit.tscn")
var string_edit_pck = preload("res://UI/VaribleEdit/StringEdit.tscn")

func _ready():
	signal_picker.connect_to_unicdict(VariblesData.signal_dict)
	VariblesData.connect("signal_defalut_values_changed", self, "on_signal_defalut_vals_change")


func _update_ui() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_Signal:
		signal_picker.select_item(blockinfo.varible_name)
		_on_SignalPick_item_selected(signal_picker.get_selected_item_text())
	

func _get_blockinfo_script() -> GDScript:
	return NBI_Signal


func on_signal_defalut_vals_change(signal_name : String) -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_Signal:
		if blockinfo.varible_name != signal_name: return
		
		_on_SignalPick_item_selected(signal_name)


func on_def_value_change(value, idx : int) -> void:
	if idx < 0: return
	
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_Signal:
		var def_data = VariblesData.get_signal_defalut_data(blockinfo.varible_name)
		
		if blockinfo.signal_vars.size() != def_data.size():
			blockinfo.signal_vars = def_data.duplicate(true)
		
		var same_type = typeof(def_data[idx]) == typeof(value)
		var simular_type = (def_data[idx] is float || def_data[idx] is int) && (value is float || value is int)
		
		if def_data.size() > idx && (same_type || simular_type):
			blockinfo.signal_vars[idx] = value
		
		save_changes(blockinfo)


func _on_SignalPick_item_selected(item_name : String) -> void:
	var blockinfo = get_blockinfo_copy()
	
	for child in varibles_sender.get_children():
		child.queue_free()
	
	if blockinfo is NBI_Signal:
		blockinfo.signal_vars.clear()
		
		if VariblesData.has_custom_signal(item_name):
			blockinfo.varible_name = item_name
			blockinfo.signal_vars = VariblesData.get_signal_defalut_data(item_name).duplicate(true)
			
			for def_value_idx in blockinfo.signal_vars.size():
				var def_value = blockinfo.signal_vars[def_value_idx]
				
				if def_value is bool:
					var new_bool_edit = BoolEdit.new()
					varibles_sender.add_child(new_bool_edit)
					new_bool_edit.pressed = def_value
					new_bool_edit.connect("toggled", self, "on_def_value_change", [def_value_idx])
				elif def_value is int || def_value is float:
					var new_number_edit = number_edit_pck.instance()
					varibles_sender.add_child(new_number_edit)
					new_number_edit.columns = 2
					new_number_edit.set_number(def_value)
					new_number_edit.connect("number_changed", self, "on_def_value_change", [def_value_idx])
				elif def_value is String:
					var new_str_edit = string_edit_pck.instance()
					varibles_sender.add_child(new_str_edit)
					new_str_edit.set_text(def_value)
					new_str_edit.connect("text_changed", self, "on_def_value_change", [def_value_idx])
					
				if def_value_idx != blockinfo.signal_vars.size() - 1:
					varibles_sender.add_child(HSeparator.new())
			
			set_section.visible = blockinfo.signal_vars.size() > 0
			varibles_scroller.scroll_vertical_enabled = varibles_sender.get_combined_minimum_size().y > 300
			varibles_scroller.rect_min_size.y = int(varibles_scroller.scroll_vertical_enabled) * 300
			
		else:
			blockinfo.varible_name = ""
			set_section.visible = false
		
		save_changes(blockinfo)
