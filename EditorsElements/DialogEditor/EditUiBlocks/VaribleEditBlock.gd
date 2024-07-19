extends BlockInfoEditUi

onready var varible_pick 		= $Varible/VariblePick
onready var set_tab				= $Set

onready var bool_state			= $Set/Bool/BoolState

onready var string_edit_line	= $Set/String/EditLine
onready var string_expand_edit	= $Set/String/ExpandEdit

onready var number				= $Set/Number/Number
onready var number_float		= $Set/Number/FloatPoint
onready var num_actions			= $Set/Number/NumberActions

var sinhronizing = false


func _ready() -> void:
	for state_idx in NBI_V_Bool.ACTION.keys().size():
		bool_state.add_item(NBI_V_Bool.ACTION.keys()[state_idx].capitalize(), NBI_V_Bool.ACTION.values()[state_idx])
	
	for state_idx in NBI_V_Number.ACTIONS.keys().size():
		num_actions.add_item(NBI_V_Number.ACTIONS.keys()[state_idx].capitalize(), NBI_V_Number.ACTIONS.values()[state_idx])
	
	VariblesData.connect("varible_aded", self, "on_varible_add_delete")
	VariblesData.connect("varible_deleted", self, "on_varible_add_delete")
	VariblesData.connect("varible_renamed", self, "on_varible_rename")


func on_varible_add_delete(_var_name : String) -> void:
	varible_pick.update_items(VariblesData.get_varibles_list())


func on_varible_rename(old_var_name : String, new_var_name : String) -> void:
	if varible_pick.get_selected_item_text() == old_var_name:
		varible_pick.update_items(VariblesData.get_varibles_list(), new_var_name)
	else:
		varible_pick.update_items(VariblesData.get_varibles_list())


func _update_ui() -> void:
	var blockinfo = get_blockinfo_copy()
	
	if blockinfo is NBI_Varible:
		varible_pick.select_item(blockinfo.varible_name)
		
		if blockinfo is NBI_V_Bool:
			set_tab.current_tab = 0
			bool_state.select(blockinfo)
			
		if blockinfo is NBI_V_Number:
			var str_value_split	= String(blockinfo.value).split(".", false, 1)
			
			set_tab.current_tab = 1
		
			if str_value_split.size() > 1:
				number_float.value	= clamp(str_value_split[1].length(), 0, 5)
				number.step = pow(10, -number_float.value)
				
			number.value = blockinfo.value
		
		if blockinfo is NBI_V_String:
			set_tab.current_tab = 2
			
			string_expand_edit.set_text(blockinfo.value)


func _get_blockinfo_script() -> GDScript:
	return NBI_Varible


func save() -> void:
	var blockinfo = get_blockinfo_copy()
	
	blockinfo.varible_name = varible_pick.get_selected_item_text()
	
	if blockinfo is NBI_V_Bool:
		blockinfo.action = bool_state.get_selected_id()
			
	if blockinfo is NBI_V_Number:
		blockinfo.action 	= num_actions.get_selected_id()
		blockinfo.value		= number.value
		
	if blockinfo is NBI_V_String:
		blockinfo.value		= string_expand_edit.text
	
	save_changes(blockinfo)


func _on_NumberActions_item_selected(_index : int) -> void:	
	if get_blockinfo_copy() is NBI_V_Number:
		save()


func _on_BoolState_item_selected(_index : int) -> void:
	if get_blockinfo_copy() is NBI_V_Bool:
		save()


func _on_Number_value_changed(_value : float) -> void:
	if get_blockinfo_copy() is NBI_V_Number:
		save()


func _on_FloatPoint_value_changed(_value : float) -> void:
	if get_blockinfo_copy() is NBI_V_Number:
		save()


func _on_EditLine_text_changed(new_text : String) -> void:
	if sinhronizing: return
	sinhronizing = true
	string_expand_edit.set_text(new_text)
	sinhronizing = false
	
	if get_blockinfo_copy() is NBI_V_String:
		save()


func _on_ExpandEdit_text_changed() -> void:
	if sinhronizing: return
	sinhronizing = true
	string_edit_line.text = string_expand_edit.text
	sinhronizing = false
	
	if get_blockinfo_copy() is NBI_V_String:
		save()
